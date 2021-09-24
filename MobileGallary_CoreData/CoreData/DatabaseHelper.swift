//
//  DatabaseHelper.swift
//  MobileGallary_CoreData
//
//  Created by Hiral Jahlani on 23/09/21.
//

import Foundation
import CoreData
import UIKit

class DatabaseHelper {
    
    //Single Tone Declartion
    var shareInstance = DatabaseHelper()
    
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    func save(object:[String:String]) -> Media? {
        
        let media = NSEntityDescription.insertNewObject(forEntityName: "Media", into: context!) as! Media
        media.photo = object["photo"]
        media.date = object["date"]
        media.time = object["time"]
        do {
            try context!.save()
            return media
        } catch {
            print("Data is not save")
            return nil
        }
    }
    
    func getMediaData() -> [Media] {
        var media:[Media] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Media")
        do{
            media = try context!.fetch(fetchRequest) as! [Media]
        }catch{
            print("Not get data")
        }
        return media
    }
    
}
