//
//  ViewController.swift
//  GuideRestaurant
//
//  Created by Tech on 2021-04-11.
//  Copyright © 2021 GBC. All rights reserved.
//

import UIKit
import CoreData
import CoreMotion
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

     var res:NSManagedObject!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var record: UILabel!
    @IBOutlet weak var tag: UILabel!
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var x: UILabel!
    @IBOutlet weak var y: UILabel!
    
    var motionManager:CMMotionManager!
    var locationManager:CLLocationManager!
    var timer:Timer!
    
    
    
    @IBAction func Share(_ sender: Any) {
        let activityController = UIActivityViewController(activityItems: [name.text!,address.text!,phone.text!,record.text!,tag.text!,#imageLiteral(resourceName: "logo")],applicationActivities: nil)
        
        present(activityController, animated: true, completion: nil)

    }
    
    
    @IBAction func Edit(_ sender: Any) {
        
        let alert = UIAlertController(title: "Edit", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {(textFieldName) in
            textFieldName.placeholder = self.res.value(forKey: "name") as? String
        })
        alert.addTextField(configurationHandler: {(textFieldAddress) in
            textFieldAddress.placeholder = self.res.value(forKey: "address") as? String
        })
        alert.addTextField(configurationHandler: {(textFieldDes) in
            textFieldDes.placeholder = self.res.value(forKey: "phone") as? String
        })
        alert.addTextField(configurationHandler: {(textFieldDes) in
            textFieldDes.placeholder = self.res.value(forKey: "record") as? String
        })
        alert.addTextField(configurationHandler: {(textFieldTag) in
            textFieldTag.placeholder = self.res.value(forKey: "tag") as? String
        })
        // present(alert, animated: true)
        let save = UIAlertAction(title: "Save", style: .default){
            [unowned self] action in
            
            
            let textFieldName = alert.textFields![0]
            var nameToSave = ""
            if (textFieldName.text == ""){
                nameToSave = self.res.value(forKey: "name") as! String
            } else{
                nameToSave = textFieldName.text!
            }
            
            var addressToSave = ""
            let textFieldAddress = alert.textFields![1]
            if(textFieldAddress.text == ""){
                addressToSave = self.res.value(forKey: "address") as! String
            } else {
                addressToSave = textFieldAddress.text!
            }
            
            
            var phoneToSave = ""
            let textFieldPhone = alert.textFields![2]
            if(textFieldPhone.text == ""){
                phoneToSave = self.res.value(forKey: "phone") as! String
            } else {
                phoneToSave = textFieldPhone.text!
            }
            
            
            
            var recordToSave = ""
            let textFieldRecord = alert.textFields![3]
            if(textFieldRecord.text == ""){
                recordToSave = self.res.value(forKey: "record") as! String
            } else {
                recordToSave = textFieldRecord.text!
            }
            
            
            
            var tagsToSave = ""
            let textFieldTags = alert.textFields![4]
            if(textFieldTags.text == ""){
                tagsToSave = self.res.value(forKey: "tag") as! String
            } else {
                tagsToSave = textFieldTags.text!
            }
            
            
            
            self.save(name: nameToSave, address: addressToSave,phone:phoneToSave, record: recordToSave, tag: tagsToSave)
            self.viewWillAppear(true)
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(save)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func save(name:String, address:String,phone:String, record: String, tag: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return }
        
        let context = appDelegate.persistentContainer.viewContext
        res.setValue(name, forKey: "name")
        res.setValue(address, forKey: "address")
        res.setValue(phone, forKey: "phone")
        res.setValue(record, forKey: "record")
        res.setValue(tag, forKey: "tag")
        do{
            try context.save()
            
        } catch let error as NSError{ print("Could not save, \(error), \(error.userInfo)")
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        motionManager = CMMotionManager()
        if motionManager.isAccelerometerAvailable{
            motionManager.accelerometerUpdateInterval = 1.0/60.0
            motionManager.startAccelerometerUpdates()
            
            timer = Timer(fire: Date(), interval: (1.0/60.0), repeats: true, block:{(timer) in
                if let data = self.motionManager.accelerometerData{
                    self.x.text = String(data.acceleration.x)
                    self.y.text = String(data.acceleration.y)
                }
            })
        }else{
            print("Accelerometer is not available")
        }
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        locationManager.requestAlwaysAuthorization()
        
        locationManager.startUpdatingLocation()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if (res != nil) {
            name.text = res.value(forKey: "name") as? String
            address.text = res.value(forKey: "address") as? String
            phone.text = res.value(forKey: "phone") as? String
            record.text = res.value(forKey: "record") as? String
            tag.text = res.value(forKey: "tag") as? String
            
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for l in locations{
            //map.centerCoordinate = l.coordinate
            x.text = String(l.coordinate.latitude)
            y.text = String(l.coordinate.longitude)
            
            let region = MKCoordinateRegion(
                center: l.coordinate,
                latitudinalMeters: 100,
                longitudinalMeters: 100
            )
            map.setRegion(region, animated: true)
            map.addAnnotation(PointOfInterest(location: l.coordinate, title: "Destination here"))
        }
    }
    
}


class PointOfInterest: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(location: CLLocationCoordinate2D, title: String){
        self.coordinate = location
        self.title = title
    }
}
