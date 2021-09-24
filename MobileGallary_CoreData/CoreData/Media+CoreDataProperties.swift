//
//  Media+CoreDataProperties.swift
//  MobileGallary_CoreData
//
//  Created by Hiral Jahlani on 23/09/21.
//
//

import Foundation
import CoreData


extension Media {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Media> {
        return NSFetchRequest<Media>(entityName: "Media")
    }

    @NSManaged public var photo: String?
    @NSManaged public var date: String?
    @NSManaged public var time: String?

}

extension Media : Identifiable {

}
