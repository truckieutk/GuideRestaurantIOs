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
            guard let textFieldName = alert.textFields?[0], let nameToSave = textFieldName.text else {return}
            guard let textFieldAddress = alert.textFields?[1], let addressToSave = textFieldAddress.text else {return}
            guard let textFieldPhone = alert.textFields?[2], let phoneToSave = textFieldPhone.text else {return}
            guard let textFieldRecord = alert.textFields?[3], let recordToSave = textFieldRecord.text else {return}
            guard let textFieldTag = alert.textFields?[4], let tagsToSave = textFieldTag.text else {return}
            self.save(name: nameToSave, address: addressToSave,phone:phoneToSave, record: recordToSave, tag: tagsToSave)
            
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
