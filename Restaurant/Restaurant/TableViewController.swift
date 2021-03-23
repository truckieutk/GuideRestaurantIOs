//
//  TableViewController.swift
//  Restaurant
//
//  Created by Tech on 2021-03-22.
//  Copyright © 2021 GBC. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {
    
    
    var restaurants: [NSManagedObject] = []
    @IBAction func addRestaurand(_ sender: Any) {
        let alert = UIAlertController(title: "Add a new Restaurant", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {(textFieldName) in
            textFieldName.placeholder = "Name of Restaurant"
        })
        alert.addTextField(configurationHandler: {(textFieldAddress) in
            textFieldAddress.placeholder = "Address"
        })
        alert.addTextField(configurationHandler: {(textFieldTag) in
            textFieldTag.placeholder = "Phone"
        })
        alert.addTextField(configurationHandler: {(textFieldDes) in
            textFieldDes.placeholder = "Record"
        })
        alert.addTextField(configurationHandler: {(textFieldTag) in
            textFieldTag.placeholder = "Tags"
        })
        
        
        let saveAction = UIAlertAction(title: "Save", style: .default){
            [unowned self] action in
            guard let textFieldName = alert.textFields?[0], let nameToSave = textFieldName.text else {return}
            guard let textFieldAddress = alert.textFields?[1], let addressToSave = textFieldAddress.text else {return}
            guard let textFieldPhone = alert.textFields?[2], let phoneToSave = textFieldPhone.text else {return}
            guard let textFieldRecord = alert.textFields?[3], let recordToSave = textFieldRecord.text else {return}
            guard let textFieldTags = alert.textFields?[4], let tagsToSave = textFieldTags.text else {return}
            self.save(name: nameToSave, address: addressToSave, phone: phoneToSave, record: recordToSave, tag: tagsToSave)
            self.tableView.reloadData()
        }
        alert.addAction(saveAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        present(alert, animated: true)
        
    }
    func save(name:String, address: String, phone: String, record: String, tag: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        
        
        if let  entity = NSEntityDescription.entity(forEntityName: "Restaurant", in: context){
            let res = NSManagedObject(entity: entity, insertInto: context)
            res.setValue(name, forKey: "name")
            res.setValue(address, forKey: "address")
            res.setValue(phone, forKey: "phone")
            res.setValue(record, forKey: "record")
            res.setValue(tag, forKey: "tag")
            do{
                try context.save()
                restaurants.append(res)
            } catch let error as NSError{ print("Cannot save, \(error), \(error.userInfo)")
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "Restaurant")
        do{
            restaurants = try context.fetch(request)
        } catch let error as NSError{
            print("Cannot fetch, \(error), \(error.userInfo)")
        }
        tableView.reloadData()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return restaurants.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let res = restaurants[indexPath.row]
        cell.textLabel?.text = (res.value(forKey:"name") as! String)
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return }
            
            let context = appDelegate.persistentContainer.viewContext
            let res = restaurants[indexPath.row]
            
            context.delete(res)
            restaurants.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            do{
                try context.save()
            }catch let error as NSError{
                print("Cannot delete, \(error), \(error.userInfo)")
            }
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 
         let res = restaurants[tableView.indexPathForSelectedRow!.row]
         let d = segue.destination as! ViewController
         d.res = res
         }

}
