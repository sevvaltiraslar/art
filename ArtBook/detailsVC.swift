//
//  detailsVC.swift
//  ArtBook
//
//  Created by SEVVAL on 22.09.2021.
//

import UIKit
import CoreData

class detailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    let pickerController = UIImagePickerController()
    
    var chosenPainting = ""
    var chosenId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.isHidden = true
        
        if chosenPainting != "" {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            fetchRequest.returnsObjectsAsFaults = false
            let idString = chosenId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            do {
                let result = try context.fetch(fetchRequest)
                if result.count > 0 {
                    for result in result as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String {
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            } catch {
                print("Error")
            }
            
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            nameText.text = ""
        }

        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func selectImage() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info [.originalImage] as? UIImage
        saveButton.isEnabled = true
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text!, forKey: "artist")
        if let year = Int(yearText.text!) {
            newPainting.setValue(year, forKey: "year")
        }
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        newPainting.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            print("Success")
        } catch {
            print("Error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
  

}
