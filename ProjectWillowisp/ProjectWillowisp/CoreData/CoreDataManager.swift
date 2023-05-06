//
//  CoreDataManager.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 4/5/23.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    lazy var context = persistentContainer.newBackgroundContext()
    let persistentContainer: NSPersistentContainer
    static let shared: CoreDataManager = CoreDataManager()
    
    private init() {
        
        ValueTransformer.setValueTransformer(UIImageTransformer(), forName: NSValueTransformerName("UIImageTransformer"))
        
        persistentContainer = NSPersistentContainer(name: "PhotosModel")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to initialize Core Data \(error)")
            }
        }
    }
    
    func downloadOrRetrieveImage(imageUrl: String) async -> UIImage? {
        do {
            let request: NSFetchRequest<Photo> = NSFetchRequest(entityName: "Photo")
            request.predicate = NSPredicate(format: "key == %@", imageUrl)
            let photos: [Photo] = try context.fetch(request)
            if let photo = photos.first(where: {
                $0.key == imageUrl
            }) {
                return photo.content
            } else {
                let storageClient = await SupabaseProvider.shared.storageClient()
                guard let data = try? await storageClient?.download(path: imageUrl) else { return nil }
                
                guard let image = UIImage(data: data) else { return nil }
                let photo = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: context) as! Photo
                photo.key = imageUrl
                photo.content = image
                
                try? context.save()
                return image
            }
        } catch {
            print(error)
            return nil
        }
    }
    
    func saveOrRetrieveVideoReference(path: String) async -> Video? {
        do {
            let request: NSFetchRequest<Video> = NSFetchRequest(entityName: "Video")
            request.predicate = NSPredicate(format: "path == %@", path)
            let videos: [Video] = try context.fetch(request)
            if let video = videos.first(where: {
                $0.path == path
            }) {
                return video
            } else {
                let storageClient = await SupabaseProvider.shared.storageClient(bucketName: "videos")
                guard let data = try await storageClient?.download(path: path) else { return nil }
                let contentPath = "\(UUID()).mp4"
                let url = getDocumentsDirectory().appendingPathComponent(contentPath)
                try data.write(to: url)
                let video = NSEntityDescription.insertNewObject(forEntityName: "Video", into: context) as! Video
                video.path = path
                video.contentPath = contentPath
                try context.save()
                return video
            }
        } catch {
            print(error)
            return nil
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
