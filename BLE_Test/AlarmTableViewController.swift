//
//  AlarmTableViewController.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/9/4.
//  Copyright © 2019 JStudio. All rights reserved.
//
import UIKit
import CoreData

class AlarmTableViewController: UITableViewController {
    var sectionDataList = [[String]]()
    var cellDataList = [[String]]()
    var isExpendDataList = [Bool]()
    var uuidDataList = [String]()
    var alarmList: WebResponseAlarmList!
    
    let headerDataList: [String] = ["Alarm Code", "Alarm Level", "Alarm App", "Message"]

    let app = UIApplication.shared.delegate as! AppDelegate
    var viewContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let sectionViewNib: UINib = UINib(nibName: "AlarmSectionView", bundle: nil)
        self.tableView.register(sectionViewNib, forHeaderFooterViewReuseIdentifier: "AlarmSectionView")
        
        let cellViewNib: UINib = UINib(nibName: "AlarmDetailTableViewCell", bundle: nil)
        self.tableView.register(cellViewNib, forCellReuseIdentifier: "AlarmDetailTableViewCell")
        
        viewContext = app.persistentContainer.viewContext

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.receiveRemoveSectionNotify(_:)),
            name: NSNotification.Name(rawValue: "RemoveSection"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.receiveAlarmNotify(_:)),
            name: NSNotification.Name(rawValue: "ReceiveAlarm"),
            object: nil
        )

        deleteAllAlarmData()
        queryAlarmData()
        
        UIApplication.shared.applicationIconBadgeNumber = getBadgeNumber()
    }
    
    func queryAlarmData() {
        let sessionHttp = URLSession(configuration: .default)
        let url = getUrlForRequest(uri: "CCS_Alarm_List")
        
        let UrlRequest = URLRequest(url: URL(string: url)!)
        
        //var gatewayList: WebResponseGatewayList?
        print("requestDeviceDetail")
        let task = sessionHttp.dataTask(with: UrlRequest) {(data, response, error) in
            do {
                let outputStr  = String(data: data!, encoding: String.Encoding.utf8) as String?
                //print("Received device detail data: \(String(describing: outputStr))")
                let jsonData = outputStr!.data(using: String.Encoding.utf8, allowLossyConversion: true)
                let decoder = JSONDecoder()
                self.alarmList = try decoder.decode(WebResponseAlarmList.self, from: jsonData!)
                if self.alarmList.alarm_list.count > 0 {
                    print("queryAlarmData: receive data from Http Server")
                    for alarm_info in self.alarmList.alarm_list {
                        self.insertAlarmData(alarm_info: alarm_info)
                    }
                }
                self.queryAlarmFromCoreData()
                DispatchQueue.main.async {
                    UIApplication.shared.applicationIconBadgeNumber = self.getBadgeNumber()
                    self.tableView.reloadData()
                }
            } catch {
                print(error.localizedDescription)
                
                return
            }
        }
        task.resume()
    }
    
    func queryAlarmFromCoreData() {
        let fetchSortRequest: NSFetchRequest<AlarmNotificationHistory> = AlarmNotificationHistory.fetchRequest()
        let predicate = NSPredicate(format: "is_archived == 0")
        fetchSortRequest.predicate = predicate
        let sort = NSSortDescriptor(key: "alarm_datetime", ascending: false)
        fetchSortRequest.sortDescriptors = [sort]

        do {
            let alarm_list = try viewContext.fetch(fetchSortRequest)
            for alarm_data in alarm_list {
                let dateFormat: DateFormatter = DateFormatter()
                dateFormat.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
                var tmpSectionData = [String]()
                tmpSectionData.append(dateFormat.string(from: alarm_data.alarm_datetime! as Date))
                tmpSectionData.append(alarm_data.gateway_id!)
                tmpSectionData.append(alarm_data.device_id!)
                tmpSectionData.append(alarm_data.alarm_level!)
                tmpSectionData.append(String(alarm_data.badge_number))
                sectionDataList.append(tmpSectionData)
                isExpendDataList.append(false)
                uuidDataList.append(alarm_data.id!)

                var tmpCellData = [String]()
                tmpCellData.append(alarm_data.alarm_code!)
                tmpCellData.append(alarm_data.alarm_level!)
                tmpCellData.append(alarm_data.alarm_app!)
                tmpCellData.append(alarm_data.alarm_message!)
                cellDataList.append(tmpCellData)
                
                print("Alarm UUID: \(alarm_data.id!)")
            }
        } catch {
            print(error)
        }
    }
    
    func insertAlarmData(alarm_info: AlarmNotification) {
        let identifier = UUID()
        let alarm_data = NSEntityDescription.insertNewObject(forEntityName: "AlarmNotificationHistory", into: viewContext) as! AlarmNotificationHistory
        alarm_data.gateway_id = alarm_info.GatewayID
        alarm_data.device_id = alarm_info.DeviceID
        alarm_data.alarm_code = alarm_info.AlarmCode
        alarm_data.alarm_level = alarm_info.AlarmLevel
        alarm_data.alarm_app = alarm_info.AlarmApp
        alarm_data.alarm_message = alarm_info.AlarmDesc
        let dateFormat: DateFormatter = DateFormatter()
        dateFormat.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
        alarm_data.alarm_datetime = dateFormat.date(from: alarm_info.DateTime)! as NSDate
        alarm_data.badge_number = 1
        alarm_data.is_archived = false
        alarm_data.id = identifier.uuidString

        app.saveContext()
    }

    func deleteAllAlarmData() {
        do {
            let alarm_list = try viewContext.fetch(AlarmNotificationHistory.fetchRequest())
            for alarm_data in alarm_list as! [AlarmNotificationHistory] {
                viewContext.delete(alarm_data)
            }
        } catch {
            print(error)
        }

        app.saveContext()
    }
    
    func getBadgeNumber() -> Int {
        let model = app.persistentContainer.managedObjectModel
        if let fetchRequest = model.fetchRequestTemplate(forName: "Fetch_Badge_Number") {
            do {
                //let alarm_list = try viewContext.fetch(AlarmNotificationHistory.fetchRequest())
                let alarm_list = try viewContext.fetch(fetchRequest)
                print("Return badge number: \(alarm_list.count)")
                return alarm_list.count
            } catch {
                print(error)
                return 0
            }
        }
        
        return 0
    }
    
    func updateBadgeNumber(section: Int) {
        print("Section \(section) updateBadgeNumber here")
        print("reloadData")
        
        let model = app.persistentContainer.managedObjectModel
        print("Section uuid: \(self.uuidDataList[section])")
        let uuidString = self.uuidDataList[section]
        
        if let fetchRequest = model.fetchRequestFromTemplate(withName: "Fetch_By_UUID", substitutionVariables: ["ID": uuidString]) {
            do {
                let alarm_list = try viewContext.fetch(fetchRequest)
                for alarm_data in alarm_list as! [AlarmNotificationHistory] {
                    print("Fetched gateway_id: \(alarm_data.gateway_id!)")
                    print("Fetched device_id: \(alarm_data.device_id!)")
                    alarm_data.badge_number = 0
                    self.sectionDataList[section][4] = "0"
                    app.saveContext()
                }
            } catch {
                print(error)
            }
        }
        self.tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        UIApplication.shared.applicationIconBadgeNumber = getBadgeNumber()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.isExpendDataList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isExpendDataList[section] {
            return self.cellDataList[section].count
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmDetailTableViewCell", for: indexPath) as! AlarmDetailTableViewCell

        cell.setData(item_name: self.headerDataList[indexPath.row], information: self.cellDataList[indexPath.section][indexPath.row])
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionView: AlarmSectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AlarmSectionView") as! AlarmSectionView
        
        sectionView.isExpand = self.isExpendDataList[section]
        sectionView.buttonTag = section
        sectionView.delegate = self as SectionViewDelegate
        
        sectionView.setData(date_time: self.sectionDataList[section][0], gateway_id: self.sectionDataList[section][1], device_id: self.sectionDataList[section][2], alarm_level: self.sectionDataList[section][3], badge_number: self.sectionDataList[section][4])
        sectionView.tag = section
        
        return sectionView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    @objc func receiveRemoveSectionNotify(_ notification: Notification) {
        if let sectionIndex = notification.object as? Int {
            print("AlarmTableViewController Receive Section remove notification, section number is \(sectionIndex)")

            let model = app.persistentContainer.managedObjectModel
            let uuidString = self.uuidDataList[sectionIndex]
            
            if let fetchRequest = model.fetchRequestFromTemplate(withName: "Fetch_By_UUID", substitutionVariables: ["ID": uuidString]) {
                do {
                    let alarm_list = try viewContext.fetch(fetchRequest)
                    for alarm_data in alarm_list as! [AlarmNotificationHistory] {
                        alarm_data.is_archived = true
                        alarm_data.badge_number = 0
                        app.saveContext()
                        
                        self.sectionDataList.remove(at: sectionIndex)
                        self.cellDataList.remove(at: sectionIndex)
                        self.isExpendDataList.remove(at: sectionIndex)
                        self.uuidDataList.remove(at: sectionIndex)

                    }
                } catch {
                    print(error)
                }
            }
            UIApplication.shared.applicationIconBadgeNumber = getBadgeNumber()
            self.tableView.reloadData()
        }
    }
    
    @objc func receiveAlarmNotify(_ notification: Notification) {
        if let aData = notification.object as? AlarmNotification {
            print("AlarmTableViewController Receive alarm notification")
            insertAlarmData(alarm_info: aData)
            UIApplication.shared.applicationIconBadgeNumber = getBadgeNumber()
            self.tableView.reloadData()

            /*
            let identifier = UUID()
            let alarm_data = NSEntityDescription.insertNewObject(forEntityName: "AlarmNotificationHistory", into: viewContext) as! AlarmNotificationHistory
            alarm_data.gateway_id = aData.GatewayID
            alarm_data.device_id = aData.DeviceID
            alarm_data.alarm_code = aData.AlarmCode
            alarm_data.alarm_level = aData.AlarmLevel
            alarm_data.alarm_app = aData.AlarmApp
            alarm_data.alarm_message = aData.AlarmDesc
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = ""
            alarm_data.alarm_datetime = (dateFormatter.date(from: aData.DateTime)! as NSDate)
            alarm_data.badge_number = 1
            alarm_data.is_archived = false
            alarm_data.id = identifier.uuidString

            app.saveContext()
            self.tableView.reloadData()
            */
        }
    }
}

extension AlarmTableViewController: SectionViewDelegate {
    func sectionView(_ sectionView: AlarmSectionView, _ didPressTag: Int, _ isExpand: Bool) {
        
        self.isExpendDataList[didPressTag] = !isExpand
        self.tableView.reloadSections(IndexSet(integer: didPressTag), with: .automatic)
        if self.isExpendDataList[didPressTag] {
            updateBadgeNumber(section: didPressTag)
        }
    }
}
