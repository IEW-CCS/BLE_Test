//
//  SetupTableViewController.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/8/25.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import CoreData

class SetupTableViewController: UITableViewController{

    @IBOutlet weak var txtHttpServer: UITextField!
    @IBOutlet weak var txtHttpServerPort: UITextField!
        
    @IBOutlet weak var txtBrokerIP: UITextField!
    @IBOutlet weak var txtBrokerPort: UITextField!
    
    @IBOutlet weak var txtDBType: UITextField!
    @IBOutlet weak var txtDBSource: UITextField!
    @IBOutlet weak var txtDBPort: UITextField!
    @IBOutlet weak var txtDBName: UITextField!
    @IBOutlet weak var txtDBUserName: UITextField!
    @IBOutlet weak var txtDBPassword: UITextField!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var switchSimulation: UISwitch!
    
    var profileList: WebResponseBLEProfileList!
    let app = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSetupConfig()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tap)
    }

    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            saveSetupConfig()
        }
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
    @IBAction func updateBLEProfiles(_ sender: Any) {
       
        let _Activityalert = Activityalert(title: "Loading")
        present(_Activityalert, animated : true, completion : updateBLEProfile)
    }
    
    func updateBLEProfile() {
        let sessionConf = URLSessionConfiguration.default
        sessionConf.timeoutIntervalForRequest = HTTP_REQUEST_TIMEOUT
        sessionConf.timeoutIntervalForResource = HTTP_REQUEST_TIMEOUT
        let sessionHttp = URLSession(configuration: sessionConf)
        //let sessionHttp = URLSession(configuration: .default)
        let url = getUrlForRequest(uri: "CCS_BLE_Profile_List")
        
        let UrlRequest = URLRequest(url: URL(string: url)!)
        
        let task = sessionHttp.dataTask(with: UrlRequest) {(data, response, error) in
            do {
                
                if error != nil{
                    DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                    let _httpalert = alert(message: error!.localizedDescription, title: "Http Error")
                    self.present(_httpalert, animated : false, completion : nil)
                }
                else{
                    
                    guard let httpResponse = response as? HTTPURLResponse,
                        (200...299).contains(httpResponse.statusCode) else {
                            
                            let errorResponse = response as? HTTPURLResponse
                            let message: String = String(errorResponse!.statusCode) + " - " + HTTPURLResponse.localizedString(forStatusCode: errorResponse!.statusCode)
                            DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                            let _httpalert = alert(message: message, title: "Http Error")
                            self.present(_httpalert, animated : false, completion : nil)
                            return
                    }
                    
                    DispatchQueue.main.async { self.presentedViewController?.dismiss(animated: false, completion: nil)}
                    //Temp function, needs to remove in the future
                    self.deleteProfileData()
                    let outputStr  = String(data: data!, encoding: String.Encoding.utf8) as String?
                    let jsonData = outputStr!.data(using: String.Encoding.utf8, allowLossyConversion: true)
                    let decoder = JSONDecoder()
                    self.profileList = try decoder.decode(WebResponseBLEProfileList.self, from: jsonData!)
                    if self.profileList.profile_list.count > 0 {
                        print("updateBLEProfiles: receive data from Http Server")
                        for profile_info in self.profileList.profile_list {
                            print("Insert data for catetory: \(profile_info.BLECategory), name: \(profile_info.BLEName)")
                            self.saveProfilesData(data: profile_info)
                        }
                        //self.loadProfileData()
                    }
                }
            } catch {
                print(error.localizedDescription)
                
                return
            }
        }
        task.resume()
    }

    func saveProfilesData(data: BLEProfile) {
        let viewContext = app.persistentContainer.viewContext
        let entity = NSEntityDescription.insertNewObject(forEntityName: "BLEProfileTable", into: viewContext) as! BLEProfileTable
        
        entity.category = data.BLECategory
        entity.name = data.BLEName
        let pData = ProfileObject(data: data)
        entity.profileObject = pData
        for tmp in pData.CharacteristicUUID! {
            print("saveProfilesData: cat: \(pData.BLECategory), name: \(pData.BLEName), CharService: \(tmp.UUID), ItemCount: \(tmp.ItemList!.count)")
        }
        app.saveContext()
    }
    
    func deleteProfileData() {
        let viewContext = app.persistentContainer.viewContext
        do {
            let fetchRequest = NSFetchRequest<BLEProfileTable>(entityName: "BLEProfileTable")
            let profile_list = try viewContext.fetch(fetchRequest)
            print("Delete data for transformable object!!")
            for profile_data in profile_list {
                let tmp = profile_data.profileObject as! ProfileObject
                print("Delete data for catetory: \(tmp.BLECategory), name: \(tmp.BLEName)")
                viewContext.delete(profile_data)
            }
        } catch {
            print(error.localizedDescription)
        }
        app.saveContext()
    }
    
    func loadSetupConfig() {
        let path = NSHomeDirectory() + "/Documents/Setup.plist"
        if let plist = NSMutableDictionary(contentsOfFile: path) {
            if let httpServer = plist["HttpServer"] {txtHttpServer.text = httpServer as? String}
            if let httpPort = plist["HttpPort"] {txtHttpServerPort.text = httpPort as? String}
            if let httpSimulation = plist["HttpSimulation"]{ switchSimulation.isOn = (httpSimulation as! Bool) }

            if let brokerIP = plist["MQTTBrokerIP"] {txtBrokerIP.text = brokerIP as? String}
            if let brokerPort = plist["MQTTBrokerPort"] {txtBrokerPort.text = brokerPort as? String}

            if let dbType = plist["DatabaseType"] {txtDBType.text = dbType as? String}
            if let dbSource = plist["DatabaseSource"] {txtDBSource.text = dbSource as? String}
            if let dbPort = plist["DatabasePort"] {txtDBPort.text = dbPort as? String}
            if let dbName = plist["DatabaseName"] {txtDBName.text = dbName as? String}
            if let dbUserName = plist["DBUserName"] {txtDBUserName.text = dbUserName as? String}
            if let dbPassword = plist["DBPassword"] {txtDBPassword.text = dbPassword as? String}
            
        }
    }
    
    func saveSetupConfig() {
        let path = NSHomeDirectory() + "/Documents/Setup.plist"
        if let plist = NSMutableDictionary(contentsOfFile: path) {
            plist["HttpServer"] = txtHttpServer.text
            plist["HttpPort"] = txtHttpServerPort.text
            plist["HttpSimulation"] = switchSimulation.isOn
            plist["MQTTBrokerIP"] = txtBrokerIP.text
            plist["MQTTBrokerPort"] = txtBrokerPort.text
            plist["DatabaseType"] = txtDBType.text
            plist["DatabaseSource"] = txtDBSource.text
            plist["DatabasePort"] = txtDBPort.text
            plist["DatabaseName"] = txtDBName.text
            plist["DBUserName"] = txtDBUserName.text
            plist["DBPassword"] = txtDBPassword.text
            
            if !plist.write(toFile: path, atomically: true) {
                print("Save Seypy.plist failed")
            }
        }
    }
}
