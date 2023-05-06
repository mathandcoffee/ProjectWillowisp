//
//  Video.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 4/7/23.
//

import CoreData
import AVFoundation

@objc(Video)
class Video: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Video> {
        return NSFetchRequest<Video>(entityName: "Video")
    }

    @NSManaged public var contentPath: String?
    @NSManaged public var path: String?
}

extension Video : Identifiable {

}
