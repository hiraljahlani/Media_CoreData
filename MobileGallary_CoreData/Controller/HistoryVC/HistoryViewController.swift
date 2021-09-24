//
//  HistoryViewController.swift
//  MobileGallary_CoreData
//
//  Created by Hiral Jahlani on 22/09/21.
//

import UIKit
import Photos
import CoreData

class HistoryViewController: UIViewController , UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedItems!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : HistoryCell? = (tableView.dequeueReusableCell(withIdentifier: "HistoryCell") as! HistoryCell)
        let dataDecoded : Data = Data(base64Encoded:(selectedItems?[indexPath.row].photo ?? " ")!, options: .ignoreUnknownCharacters) ?? Data()
        let decodedimage = UIImage(data: dataDecoded)
        cell?.imgPicture.image = decodedimage
        cell?.lblDate.text = selectedItems?[indexPath.row].date
        cell?.lblTime.text = selectedItems?[indexPath.row].time
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Swift 4.2 onwards
        return UITableView.automaticDimension
    }


    @IBOutlet var tableData: UITableView!

    var documentobjDict:NSDictionary = [:];
    var selectedItems: [Media]? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedItems = getSavedData()
        tableData.reloadData()
        // Do any additional setup after loading the view.
    }

    //MARK: BUTTON ACTION
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    //MARK: COREDATA FUNCTION
    func getSavedData() -> [Media] {
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Media")
        do {
            let result = try managedContext.fetch(fetchRequest) as! [Media]
            return result
        } catch {
            
            print("Failed")
        }
        return []
    }
    
    func retrieveData() {
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Media")
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "photo")!)
            }
        } catch {
            
            print("Failed")
        }
    }

}
