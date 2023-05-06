//
//  Photo.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 4/5/23.
//

import CoreData
import UIKit

@objc(Photo)
class Photo: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var content: UIImage?
    @NSManaged public var key: String?

}

extension Photo : Identifiable {

}
