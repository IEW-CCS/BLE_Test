//
//  CloudBLETableViewController.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/8/24.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import Charts
import CoreData
import CoreBluetooth
import MQTTClient

class CloudBLETableViewController: UITableViewController {
    @IBOutlet weak var samplingRatePicker: UIPickerView!
    @IBOutlet weak var profilePicker: UIPickerView!
    @IBOutlet weak var switchBLE: UISwitch!
    @IBOutlet weak var switchMQTT: UISwitch!
    
    private  let myAlert = UIAlertController(title: "Scanning...",message: "\n\n\n",preferredStyle: .alert)

    private var transport = MQTTCFSocketTransport()
    fileprivate var session = MQTTSession()
    
    enum SendDataError: Error {
        case CharacteristicNotFound
    }

    let secondsData = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30"]
    let DATA_MAX_COUNT = 30
    
    var samplingRate: String = "1"
    var chartHeight = CGFloat()
    var categoryArray = [String]()
    var deviceArray = [[String]]()
    var category: String = ""
    var device: String = ""
    var itemCount: Int = -1
    var activeDataItemRow: Int = 0
    var activeDataItemArray = [Bool]()
    var selectedProfile: ProfileObject?
    var timer_ble = Timer()
    var timer_mqtt = Timer()
    //var bleDataValueList: BLEReceivedDataList!
    var bleDataValueList = [BLEReceivedDataValue]()
    var bleChartDataArray = [[String]]()
    var bleChartDataLabel = [String]()
    
    // GATT
    //let C001_CHARACTERISTIC = "C001"
    let SAMPLING_RATE_CHARACTERISTIC = "B001"
    var Service_UUID: String = ""
    var Characteristic_UUID: String = ""
    
    var centralManager: CBCentralManager!
    
    // Storeed the connected peripheral
    var connectPeripheral: CBPeripheral!
    var charDictionary = [String: CBCharacteristic]()

    let app = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        self.samplingRatePicker.delegate = self
        self.profilePicker.delegate = self
        
        let nibProfile = UINib(nibName: "BLEDataItemTableViewCell", bundle: nil)
        self.tableView.register(nibProfile, forCellReuseIdentifier: "BLEDataItemTableViewCell")

        let nibChart = UINib(nibName: "CustomChartCell", bundle: nil)
        self.tableView.register(nibChart, forCellReuseIdentifier: "CustomChartCell")

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.receiveTurnOnChartNotify(_:)),
            name: NSNotification.Name(rawValue: "TurnOnChartHistory"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.receiveTurnOffChartNotify(_:)),
            name: NSNotification.Name(rawValue: "TurnOffChartHistory"),
            object: nil
        )

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tap)
        
        let queue = DispatchQueue.global()
        centralManager = CBCentralManager(delegate: self, queue: queue)

        loadProfileData()
        selectedProfile = requestSelectedProfile(category: self.category, profile_name: self.device)
        self.tableView.reloadData()
    }

    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
    @IBAction func subscribeBLE(_ sender: UISwitch) {
        if self.selectedProfile != nil {
            if sender.isOn {
                startScan()
            } else {
                //Disconnect the peripheral
                if self.connectPeripheral != nil {
                    print("Disconnect the peripheral")
                    centralManager.cancelPeripheralConnection(self.connectPeripheral)
                }
            }
        } else {
            print("selectedProfile is nil")
            sender.isOn = false
        }
    }

    func startScan() {
        print("Now Scanning...")
        self.timer_ble.invalidate()

        centralManager.scanForPeripherals(withServices: [CBUUID(string: self.Service_UUID)], options: nil)

        self.timer_ble = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.cancelScan), userInfo: nil, repeats: false)
        
        let scanningIndicator =  UIActivityIndicatorView(frame: myAlert.view.bounds)
        scanningIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scanningIndicator.color = UIColor.blue
        scanningIndicator.startAnimating()
        myAlert.title = "Scanning..."
        myAlert.view.addSubview(scanningIndicator)
        present(myAlert, animated : true, completion : nil)
    }

    // If the BLE timer is time-out, then call this function to display alert message
    @objc func cancelScan() {
        self.centralManager?.stopScan()
        print("Scan Stopped")
        
        self.presentedViewController?.dismiss(animated: false, completion: nil)
        let alertVC = UIAlertController(title: "Scan Stopped", message: "BLE with Service UUID: \(self.Service_UUID) is not found", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) -> Void in
        self.dismiss(animated: true, completion: nil)
        })
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
        self.switchBLE.isOn = false
    }

    @objc func receiveTurnOnChartNotify(_ notification: Notification) {
        if let rowIndex = notification.object as? Int {
            print("receiveTurnOnChartNotify receive turn on notification, turn-on row: \(rowIndex)")
            //self.activeDataItemRow = rowIndex
            self.activeDataItemArray[rowIndex] = true
        }
    }
    
    @objc func receiveTurnOffChartNotify(_ notification: Notification) {
        if let rowIndex = notification.object as? Int {
            print("receiveTurnOffChartNotify receive turn off notification, turn-off row: \(rowIndex)")
            //self.activeDataItemRow = rowIndex
            self.activeDataItemArray[rowIndex] = false
        }
    }
    
    func displayChartHistory(data: [BLEReceivedDataValue]) {
        prepareChartData(data_value: data)
        
        let indexPath = IndexPath(row: self.itemCount, section: 2)
        let cell = self.tableView.cellForRow(at: indexPath) as! CustomChartCell
        
        var validChartDataArray = [[String]]()
        var validDataLabel = [String]()
        
        for i in 0...(self.itemCount - 1) {
            if self.activeDataItemArray[i] {
                validChartDataArray.append(self.bleChartDataArray[i])
                validDataLabel.append(self.bleChartDataLabel[i])
            }
        }
        
        //cell.setChartData(value: self.bleChartDataArray, data_label: self.bleChartDataLabel)
        if !validChartDataArray.isEmpty {
            cell.setChartData(value: validChartDataArray, data_label: validDataLabel)
        } else {
            cell.setChartDataNil()
        }
    }

    func prepareChartData(data_value: [BLEReceivedDataValue]) {
        if self.bleChartDataArray.isEmpty {
            for index in 0...self.itemCount - 1 {
                self.bleChartDataLabel.append(data_value[index].DataName)
                self.bleChartDataArray.append([data_value[index].DataValue])
            }
        } else {
            for index in 0...self.itemCount - 1 {
                if self.bleChartDataArray[index].count == self.DATA_MAX_COUNT {
                    self.bleChartDataArray[index].remove(at: 0)
                    self.bleChartDataArray[index].append(data_value[index].DataValue)
                } else {
                    self.bleChartDataArray[index].append(data_value[index].DataValue)
                }
            }
        }
    }
    @IBAction func connectMQTT(_ sender: UISwitch) {
        if sender.isOn {
            establishMQTTConnection()
        } else {
            self.session?.disconnect()
        }
    }
    
    func establishMQTTConnection() {
        let mqttIP = getMQTT_IP()
        let mqttPort = getMQTT_Port()
        
        print("MQTT Broker IP: \(mqttIP)")
        print("MQTT Broker Port: \(mqttPort)")
        
        self.session?.delegate = self as? MQTTSessionDelegate
        self.transport.host = mqttIP
        self.transport.port = mqttPort
        session?.transport = transport
        
        let connectingIndicator =  UIActivityIndicatorView(frame: myAlert.view.bounds)
        connectingIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        connectingIndicator.color = UIColor.blue
        connectingIndicator.startAnimating()
        myAlert.title = "Connecting..."
        myAlert.view.addSubview(connectingIndicator)
        present(myAlert, animated : true, completion : nil)

        session?.connect() { error in
            print("connection completed with status \(String(describing: error))")
            if error != nil {
                let alertVC = UIAlertController(title: "Connect to MQTT Broker Failed", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let action = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) -> Void in
                    self.dismiss(animated: true, completion: nil)
                })
                alertVC.addAction(action)
                self.present(alertVC, animated: true, completion: nil)

            } else {
                print("Connect to MQTT Broker successful")
                //self.timer_mqtt.invalidate()
                self.presentedViewController?.dismiss(animated: false, completion: nil)

                //self.publishTestMessage()
            }
        }
    }
    
    // If the MQTT timer is time-out, then call this function to display alert message
    /*
    @objc func cancelConnect() {
        print("MQTT Connection time out")
        
        self.presentedViewController?.dismiss(animated: false, completion: nil)
        let alertVC = UIAlertController(title: "Connection Time Out", message: "Cannot connect to MQTT Broker, please check the config", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
        self.switchMQTT.isOn = false
    }*/

    func publishMessage(data_list: [BLEReceivedDataValue]) {
        //print("Publish a Test Message!!")
        if self.switchMQTT.isOn {
            guard self.session?.status == .connected else {
                let alertVC = UIAlertController(title: "MQTT Broker is not connected", message: "Please re-connect to MQTT Server", preferredStyle: UIAlertController.Style.alert)
                let action = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) -> Void in
                    self.dismiss(animated: true, completion: nil)
                })
                alertVC.addAction(action)
                self.present(alertVC, animated: true, completion: nil)
                
                return
            }
            
            do {
                let topic = getMQTTPublishTopic(device_id: self.device)
                var replyData = ReplyBLEData()
                replyData.Device_ID = self.device
                replyData.IP_Address = "10.0.0.1"
                let dateFormat: DateFormatter = DateFormatter()
                dateFormat.dateFormat = "yyyyMMddHHmmssSSS"
                //tmpSectionData.append(dateFormat.string(from: alarm_data.alarm_datetime! as Date))
                replyData.Time_Stamp = dateFormat.string(from: Date())
                for index in 0...(data_list.count - 1) {
                    var edcItem = EDC_Item()
                    edcItem.DATA_NAME = data_list[index].DataName
                    edcItem.DATA_VALUE = data_list[index].DataValue
                    replyData.EDC_Data?.append(edcItem)
                }
                
                let jsonEncoder = JSONEncoder()
                let data = try jsonEncoder.encode(replyData)
                //let json_string = String(data: data, encoding: .utf8)!
                
                self.session?.publishData(data, onTopic: topic, retain: false, qos: .exactlyOnce)

            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            //print("Section 2 numberOfRowsInSection: \(self.itemCount + 1)")
            return self.itemCount + 1
        }
        
        //return self.tableView.numberOfRows(inSection: section)
        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("cellForRoawAt: Section: \(indexPath.section), Row: \(indexPath.row)")

        if indexPath.section == 2 {
            if indexPath.row == self.itemCount {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "CustomChartCell", for: indexPath) as! CustomChartCell
                
                self.chartHeight = cell.chtChart.frame.size.height
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "BLEDataItemTableViewCell", for: indexPath) as! BLEDataItemTableViewCell

                //Temp solution, currently onlu support one Characteristic Service UUID
                //Multiple Characteristic Services will be supported in the future
                cell.setData(item_name: (selectedProfile?.CharacteristicUUID![0].ItemList![indexPath.row].DataName)!, item_value: "")
                cell.tag = indexPath.row
                self.activeDataItemArray.append(false)
                
                return cell
            }
        }
        
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            if indexPath.row == self.itemCount {
                return 360
            }
            else {
                return 44
            }
        }else{
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPath.section == 2 {
            let newIndexPath = IndexPath(row: 0, section: indexPath.section)
            return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
        }else{
            return super.tableView(tableView, indentationLevelForRowAt: indexPath)
        }
    }
    
    func loadProfileData() {
        do {
            let vc = app.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<BLEProfileTable>(entityName: "BLEProfileTable")
            let profile_list = try vc.fetch(fetchRequest)
            print("Get data from transformable object!!")
            for profile_data in profile_list {
                let tmp = profile_data.profileObject as! ProfileObject
                print("Get data for catetory: \(tmp.BLECategory), name: \(tmp.BLEName)")
                if !self.categoryArray.contains(profile_data.category!) {
                    self.categoryArray.append(profile_data.category!)
                    self.deviceArray.append([profile_data.name!])
                } else {
                    if let index = self.categoryArray.firstIndex(of: profile_data.category!) {
                        //print("loadProfileData category index: \(index)")
                        self.deviceArray[index].append(profile_data.name!)
                    }
                }
            }
            if self.categoryArray.count > 0 {
                self.category = self.categoryArray[0]
                self.device = self.deviceArray[0][0]
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func requestSelectedProfile(category: String, profile_name: String) -> ProfileObject? {
        print("Enter requestSelectedProfile")
        
        let vc = app.persistentContainer.viewContext
        do {
            let fetchRequest = NSFetchRequest<BLEProfileTable>(entityName: "BLEProfileTable")
            let profile_list = try vc.fetch(fetchRequest)
            for profile_data in profile_list {
                if profile_data.category == category && profile_data.name == profile_name {
                    print("Fetched category: \(profile_data.category!)")
                    print("Fetched name: \(profile_data.name!)")
                    let profileDetail = profile_data.profileObject as! ProfileObject
                    for charService in profileDetail.CharacteristicUUID! {
                        print("Characteristic UUIS: \(charService.UUID)")
                        for charItem in charService.ItemList! {
                            print("Data Name: \(charItem.DataName), Data Type: \(charItem.DataType)")
                        }
                    }
                    
                    //Temp solution, currently onlu support one Characteristic Service UUID
                    //Multiple Characteristic Services will be supported in the future
                    self.itemCount = profileDetail.CharacteristicUUID![0].ItemList!.count
                    self.Service_UUID = profileDetail.ServiceUUID
                    self.Characteristic_UUID = profileDetail.CharacteristicUUID![0].UUID
                    return profileDetail
                }
            }
            return nil
        } catch {
            print(error.localizedDescription)
            return nil
        }

        /*
        let model = app.persistentContainer.managedObjectModel
        var requestArgs: [String: Any] = [String : Any]()
        requestArgs["CAT"] = category
        requestArgs["NAME"] = profile_name

        //if let fetchRequest = model.fetchRequestFromTemplate(withName: "Fetch_Specific_Profile", substitutionVariables: ["CAT": category, "NAME": profile_name]) {
        if let fetchRequest = model.fetchRequestFromTemplate(withName: "Fetch_Specific_Profile", substitutionVariables: requestArgs) {
            do {
                let profile_list = try viewContext.fetch(fetchRequest)
                for profile_data in profile_list as! [BLEProfileTable] {
                    print("Fetched category: \(profile_data.category!)")
                    print("Fetched name: \(profile_data.name!)")
                    let profileDetail = profile_data.profileObject as! ProfileObject
                    for charService in profileDetail.CharacteristicUUID! {
                        print("Characteristic UUIS: \(charService.UUID)")
                        for charItem in charService.ItemList! {
                            print("Data Name: \(charItem.DataName), Data Type: \(charItem.DataType)")
                        }
                    }
                    app.saveContext()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        */
    }
}

extension CloudBLETableViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == samplingRatePicker {
            return 1
        }
        
        if pickerView == profilePicker {
            return 2
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == samplingRatePicker {
            return self.secondsData.count
        }
        
        if pickerView == profilePicker {
            if component == 0 {
                return self.categoryArray.count
            } else {
                let selectedIndex = self.profilePicker.selectedRow(inComponent: 0)
                return self.deviceArray[selectedIndex].count
            }
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == samplingRatePicker {
            return self.secondsData[row]
        }
        
        if pickerView == profilePicker {
            if component == 0 {
                return self.categoryArray[row]
            } else {
                let selectedIndex = self.profilePicker.selectedRow(inComponent: 0)
                return self.deviceArray[selectedIndex][row]
            }
        }
        
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == samplingRatePicker {
            self.samplingRate = self.secondsData[row]
            print("Selected items is: \(self.samplingRate)")
            if self.connectPeripheral != nil {
                let string = self.samplingRate
                
                do {
                    let data = string.data(using: .utf8)
                    try sendData(data!, uuidString: self.SAMPLING_RATE_CHARACTERISTIC, writeType: .withResponse)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }

        if pickerView == profilePicker {
            if component == 0 {
                self.category = self.categoryArray[row]
                self.profilePicker.reloadComponent(1)
                let selectedIndex = self.profilePicker.selectedRow(inComponent: 1)
                self.device = self.deviceArray[row][selectedIndex]
                print("Selected category: \(self.category), device: \(self.device)")
                self.selectedProfile = self.requestSelectedProfile(category: self.category, profile_name: self.device)
                self.activeDataItemArray.removeAll()
                self.bleChartDataArray.removeAll()
                self.bleChartDataLabel.removeAll()
                self.tableView.reloadData()
            }
            else {
                let selectedIndex = self.profilePicker.selectedRow(inComponent: 0)
                self.device = self.deviceArray[selectedIndex][row]
                print("Selected category: \(self.category), device: \(self.device)")
                self.selectedProfile = self.requestSelectedProfile(category: self.category, profile_name: self.device)
                self.activeDataItemArray.removeAll()
                self.bleChartDataArray.removeAll()
                self.bleChartDataLabel.removeAll()
                self.tableView.reloadData()
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var title = UILabel()
        if let v = view as? UILabel { title = v }
        title.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold)
        title.textColor = UIColor.blue
        title.textAlignment = .center

        if pickerView == samplingRatePicker {
            title.text =  self.secondsData[row]
        }
        
        if pickerView == profilePicker {
            if component == 0 {
                title.text = self.categoryArray[row]
            } else {
                let selectedIndex = self.profilePicker.selectedRow(inComponent: 0)
                title.text = self.deviceArray[selectedIndex][row]
            }
        }

        return title
    }
}

extension CloudBLETableViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            print("Bluetooth Disabled- Make sure your Bluetooth is turned on")
            return
        }
        
        print("Bluetooth Enabled")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        
        guard let deviceName = peripheral.name else {
            return
        }
        
        print("Bluetooth peripheral found: \(deviceName)")
        
        central.stopScan()
        self.timer_ble.invalidate()
        
        self.presentedViewController?.dismiss(animated: false, completion: nil)

        print("Specific BLE device found, stop scan and start to connect...")
        
        connectPeripheral = peripheral
        connectPeripheral.delegate = self
        
        centralManager.connect(connectPeripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        charDictionary = [:]
        //peripheral.discoverServices(nil)
        print("BLE connected, start to discover Services...")
        peripheral.discoverServices([CBUUID(string: self.Service_UUID)])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            let alertVC = UIAlertController(title: "Discover Services Failed", message: "BLE with Service UUID: \(self.Service_UUID) is not found", preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) -> Void in
                self.dismiss(animated: true, completion: nil)
            })
            alertVC.addAction(action)
            self.present(alertVC, animated: true, completion: nil)

            print(error!.localizedDescription)
            return
        }
        
        for service in peripheral.services! {
            connectPeripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        var isCharServiceFound: Bool = false
        
        guard error == nil else {
            let alertVC = UIAlertController(title: "Discover Characteristic Service Failed", message: "BLE with Characteristic UUID: \(self.Characteristic_UUID) is not found", preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) -> Void in
                self.dismiss(animated: true, completion: nil)
            })
            alertVC.addAction(action)
            self.present(alertVC, animated: true, completion: nil)

            print(error!.localizedDescription)
            return
        }
        
        for characteristic in service.characteristics! {
            let uuidString = characteristic.uuid.uuidString
            if uuidString == self.Characteristic_UUID {
                charDictionary[uuidString] = characteristic
                connectPeripheral.setNotifyValue(true, for: charDictionary[self.Characteristic_UUID]!)
                print("Found specific data characteristic service uuid: \(uuidString)")
            }
            
            if uuidString == self.SAMPLING_RATE_CHARACTERISTIC {
                print("Found specific sampling rate characteriscit service uuid: \(uuidString)")
                charDictionary[uuidString] = characteristic
                isCharServiceFound = true
            }
        }
        
        // Write Sampling Rate to Peripheral
        if isCharServiceFound {
            let string = self.samplingRate
            
            do {
                let data = string.data(using: .utf8)
                try sendData(data!, uuidString: self.SAMPLING_RATE_CHARACTERISTIC, writeType: .withResponse)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // Send data to peripheral
    func sendData(_ data: Data, uuidString: String, writeType: CBCharacteristicWriteType) throws {
        guard let characteristic = charDictionary[uuidString] else {
            throw SendDataError.CharacteristicNotFound
        }
        
        connectPeripheral.writeValue(
            data,
            for: characteristic,
            type: writeType
        )
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("Write data error: \(error!)")
        }
    }
    
    // Get data from peripheral
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print(error!)
            return
        }
        
        if characteristic.uuid.uuidString == self.Characteristic_UUID {
            do {
                let data = characteristic.value! as Data
                let outputStr  = String(data: data, encoding: String.Encoding.utf8) as String?
                let jsonData = outputStr!.data(using: String.Encoding.utf8, allowLossyConversion: true)
                let decoder = JSONDecoder()
                self.bleDataValueList = try decoder.decode([BLEReceivedDataValue].self, from: jsonData!)
                
                let string = String(data: data as Data, encoding: .utf8)!
                print(string)

            } catch {
                print(error.localizedDescription)
                return
            }
            
            DispatchQueue.main.async {
                for index in 0...self.itemCount - 1 {
                    let indexPath = IndexPath(row: index, section: 2)
                    let cell = self.tableView.cellForRow(at: indexPath) as! BLEDataItemTableViewCell
                    cell.setValue(item_value: self.bleDataValueList[index].DataValue)
                }
                self.displayChartHistory(data: self.bleDataValueList)
                self.publishMessage(data_list: self.bleDataValueList)
            }
        }
    }
}

class MyIndexFormatter: IndexAxisValueFormatter {
    
    open override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return "\(value)"
        
    }
}
