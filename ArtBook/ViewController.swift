//
//  ViewController.swift
//  ArtBook
//
//  Created by SEVVAL on 22.09.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var nameArray = [String]()
    var idArray = [UUID]()
    
    var selectPainting = ""
    var selectId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        getData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
    }
    
    
    @objc func getData() {
        
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(fetchRequest)
            
            if result.count > 0 {
                
                for result in result as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String {
                        self.nameArray.append(name)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                    }
                }
            }
            
            tableView.reloadData()
            
        } catch {
            print("Error")
        }
        
    }
    
    @objc func addButtonClicked() {
        selectPainting = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell ()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! detailsVC
            destinationVC.chosenPainting = selectPainting
            destinationVC.chosenId = selectId
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectPainting = nameArray[indexPath.row]
        selectId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            fetchRequest.returnsObjectsAsFaults = false
            let idString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            
            
            do {
                let result = try context.fetch(fetchRequest)
                if result.count > 0 {
                    for result in result as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID {
                            if id == idArray[indexPath.row] {
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                do{
                                    try context.save()
                                } catch {
                                    print("Error")
                                }
                                break
                            }
                        }
                    }
                    
                }
                
            } catch {
                print("Error")
            }
        }
    }


}

