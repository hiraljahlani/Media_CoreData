//
//  ViewController.swift
//  MobileGallary_CoreData
//
//  Created by Hiral Jahlani on 21/09/21.
//

import UIKit
import Photos
import CoreData

class MediaSelectionViewController: UIViewController {
    
    var allPhotos : PHFetchResult<PHAsset>? = nil
    var arrayOfPHAsset : [PHAsset] = []
    var SelectedPhoto : PHFetchResult<PHAsset>? = nil
    var selectedPhotoIndexes = [IndexPath]()
    var arrSelectedData = [String]() // This is selected cell data array
    
    @IBOutlet weak var photoCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width/4, height: UIScreen.main.bounds.size.width/4)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        photoCollection!.collectionViewLayout = layout
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        // Do any additional setup after loading the view.
        requestPhotos()
        photoCollection.register(UINib(nibName: "PhotoCell", bundle: .main), forCellWithReuseIdentifier: "PhotoCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectedPhotoIndexes.removeAll()
        photoCollection.reloadData()
    }
    
    
    //MARK: BUTTON ACTION
    
    @IBAction func btnCopytoMyAlbum(_ sender: UIButton) {
        
        //SAVE DATA TO COREDATA
        //NAME, TIME AND DATE AND PHOTO
        //VERIFY DUPLICATE DATA ON SELECTION
        if arrayOfPHAsset.count == 00 {
            showAlert(title: "Oops", message: "Please select atleast one image to copy into album.")
            return
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: "Media", in: managedContext)!
        for images_ in arrayOfPHAsset {
            
            let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
            let imageData: Data? = getAssetThumbnail(asset: images_, size: CGFloat(images_.pixelHeight)).jpegData(compressionQuality: 0.4)
            let imageBase64String = imageData?.base64EncodedString()
            if verifyDataAvailable(imageID: images_.localIdentifier) {
                //VALUE AVAILABLE
                if arrayOfPHAsset.count == 1 {
                    showAlert(title: "Duplicate Data", message: "Selected image available in coreData!!.")
                    return
                }
                showAlert(title: "Duplicate Data", message: "One of the Selected image available in coreData!!.")
                return
                
            }
            else{
                user.setValue(imageBase64String, forKeyPath: "photo")
                user.setValue(images_.localIdentifier, forKeyPath: "fileID")
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let current_date = dateFormatter.string(from: date)
                user.setValue(current_date, forKey: "date")
                user.setValue(currentTime(), forKey: "time")
                do {
                    try managedContext.save()
                    
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                
            }
            
        }
        
        if let signupVC = self.storyboard?.instantiateViewController(identifier: "HistoryViewController") as? HistoryViewController{
            self.navigationController?.pushViewController(signupVC, animated: true)
        }
    }
    
    
}

extension MediaSelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.allPhotos?.count ?? 0
    }
    
    // Or Display image in Collection View cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.photoCollection.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        let asset = allPhotos?.object(at: indexPath.item)
        cell.imgPicture.fetchImage(asset: asset!, contentMode: .aspectFit, targetSize: cell.imgPicture.frame.size)
        
        if selectedPhotoIndexes.contains(indexPath) {
            cell.selectImg.backgroundColor = UIColor.blue
        } else {
            cell.selectImg.backgroundColor = UIColor.clear
        }
        cell.layoutSubviews()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if selectedPhotoIndexes.contains(indexPath) {
            selectedPhotoIndexes = selectedPhotoIndexes.filter { $0 != indexPath}
            arrayOfPHAsset.removeAll(where: { $0 == allPhotos?.object(at: indexPath.row)})
            let selectedcell = self.photoCollection.cellForItem(at: indexPath) as? PhotoCell
            selectedcell?.selectImg.backgroundColor = UIColor.clear
        }
        else {
            
            let selectedcell = self.photoCollection.cellForItem(at: indexPath) as? PhotoCell
            selectedcell?.selectImg.backgroundColor = UIColor.blue
            selectedPhotoIndexes.append(indexPath)
            arrayOfPHAsset.append((allPhotos?.object(at: indexPath.row))!)
        }
        
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MediaSelectionViewController: UICollectionViewDelegateFlowLayout {
        
    private func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width/3, height: UIScreen.main.bounds.size.width/3);

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
}

extension UIImageView{
    
    func fetchImage(asset: PHAsset, contentMode: PHImageContentMode, targetSize: CGSize) {
        let options = PHImageRequestOptions()
        options.version = .original
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options) { image, _ in
            guard let image = image else { return }
            switch contentMode {
            case .aspectFill:
                self.contentMode = .scaleAspectFill
            case .aspectFit:
                self.contentMode = .scaleAspectFit
            @unknown default:
                fatalError()
            }
            self.image = image
        }
    }
}

extension PHAsset {
    
    func image(completionHandler: @escaping (UIImage) -> ()){
        var thumbnail = UIImage()
        let imageManager = PHCachingImageManager()
        imageManager.requestImage(for: self, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: nil, resultHandler: { img, _ in
            thumbnail = img!
        })
        completionHandler(thumbnail)
    }
}
extension MediaSelectionViewController {
    
    
    //MARK: CUSTOM FUNCTION
    
    func getAssetThumbnail(asset: PHAsset, size: CGFloat) -> UIImage {
        let retinaScale = UIScreen.main.scale
        let retinaSquare = CGSize(width: size * retinaScale, height: size * retinaScale)
        let cropSizeLength = min(asset.pixelWidth, asset.pixelHeight)
        let square = CGRect(x: 0, y: 0, width: CGFloat(cropSizeLength), height: CGFloat(cropSizeLength))
        let cropRect = square.applying(CGAffineTransform(scaleX: 1.0/CGFloat(asset.pixelWidth), y: 1.0/CGFloat(asset.pixelHeight)))
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        var thumbnail = UIImage()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.normalizedCropRect = cropRect
        manager.requestImage(for: asset, targetSize: retinaSquare, contentMode: .aspectFit, options: options, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    // RETRIVE PHOTOS FROM GALLARY
    
    func requestPhotos() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                let fetchOptions = PHFetchOptions()
                self.allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                DispatchQueue.main.async {
                    self.photoCollection.reloadData()
                }
            case .denied, .restricted:
                print("Not allowed")
            case .notDetermined:
                // Should not see this when requesting
                print("Not determined yet")
            case .limited:
                break
            @unknown default:
                break
            }
        }
    }
    
    //VERIFY DATA AVAILABLE IN COREDATA
    
    func verifyDataAvailable(imageID:String)-> Bool {
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return true }
        //We need to create a context from this container
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Media")
        fetchRequest.predicate = NSPredicate(format: "fileID == %@", imageID)
        let managedContext = appDelegate.persistentContainer.viewContext
        do {
            let result = try managedContext.fetch(fetchRequest)
            if result.count > 0 {
                return true
            }
            return false
            
        } catch {
            return false
        }
    }
    
    func currentTime() -> String {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        return "\(hour):\(minutes)"
    }
    
    func showAlert(title:String, message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (_) in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}
