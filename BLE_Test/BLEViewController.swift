//
//  BLEViewController.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/8/18.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLEViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    var str: String? = nil

    @IBOutlet weak var labelBLE: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textField: UITextField!
    
    enum SendDataError: Error {
        case CharacteristicNotFound
    }
    
    // GATT
    let C001_CHARACTERISTIC = "C001"
    
    var centralManager: CBCentralManager!
    
    // Storeed the connected peripheral
    var connectPeripheral: CBPeripheral!
    var charDictionary = [String: CBCharacteristic]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let str = str {
            print("BLEViewController viewDidLoad: " + str)
        }
        labelBLE.text = str
        
        let queue = DispatchQueue.global()
        centralManager = CBCentralManager(delegate: self, queue: queue)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            return
        }
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        guard let deviceName = peripheral.name else {
            return
        }
        print("Bluetooth peripheral found: \(deviceName)")
        
        guard deviceName.range(of: "BLE_Simulator") != nil || deviceName.range(of: "MacBook") != nil
            else {
                return
        }
        
        central.stopScan()
        
        connectPeripheral = peripheral
        connectPeripheral.delegate = self
        
        centralManager.connect(connectPeripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        charDictionary = [:]
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            //print("ERROR: \(#file, #function)")
            print(error!.localizedDescription)
            return
        }
        
        for service in peripheral.services! {
            connectPeripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print(error!.localizedDescription)
            return
        }
        
        for characteristic in service.characteristics! {
            let uuidString = characteristic.uuid.uuidString
            charDictionary[uuidString] = characteristic
            print("Found: \(uuidString)")
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
        
        if characteristic.uuid.uuidString == C001_CHARACTERISTIC {
            let data = characteristic.value! as NSData
            let string = "> " + String(data: data as Data, encoding: .utf8)!
            print(string)
            
            DispatchQueue.main.async {
                if self.textView.text.isEmpty {
                    self.textView.text = string
                } else {
                    self.textView.text = self.textView.text + "\n" + string
                }
            }
        }
    }
    
    @IBAction func subscribeValue(_ sender: UISwitch) {
        connectPeripheral.setNotifyValue(sender.isOn, for: charDictionary[C001_CHARACTERISTIC]!)
    }
    
    @IBAction func sendClick(_ sender: Any) {
        let string = textField.text ?? ""
        if textView.text.isEmpty {
            textView.text = string
        } else {
            textView.text = textView.text + "\n" + string
        }
        
        do {
            let data = string.data(using: .utf8)
            try sendData(data!, uuidString: C001_CHARACTERISTIC, writeType: .withResponse)
        } catch {
            print(error)
        }
    }
    
    @IBAction func readDataClick(_ sender: Any) {
        let characteristic = charDictionary[C001_CHARACTERISTIC]!
        connectPeripheral.readValue(for: characteristic)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.3) {
            self.view.endEditing(true)
        }
    }
}
