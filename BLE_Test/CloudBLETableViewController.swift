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

class CloudBLETableViewController: UITableViewController {
    @IBOutlet weak var samplingRatePicker: UIPickerView!
    @IBOutlet weak var profilePicker: UIPickerView!
    
    let secondsData = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30"]
    var samplingRate: String = "1"
    var chartHeight = CGFloat()
    var categoryArray = [String]()
    var deviceArray = [[String]]()
    var category: String = ""
    var device: String = ""
    var itemCount: Int = 0
    var selectedProfile: ProfileObject?
    
    let app = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        self.samplingRatePicker.delegate = self
        self.profilePicker.delegate = self
        
        let nibProfile = UINib(nibName: "BLEDataItemTableViewCell", bundle: nil)
        self.tableView.register(nibProfile, forCellReuseIdentifier: "BLEDataItemTableViewCell")

        let nibChart = UINib(nibName: "CustomChartCell", bundle: nil)
        self.tableView.register(nibChart, forCellReuseIdentifier: "CustomChartCell")

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tap)

        loadProfileData()
        selectedProfile = requestSelectedProfile(category: self.category, profile_name: self.device)
        self.tableView.reloadData()
    }

    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            print("Section 2 numberOfRowsInSection: \(self.itemCount + 1)")
            return self.itemCount + 1
        }
        
        //return self.tableView.numberOfRows(inSection: section)
        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRoawAt: Section: \(indexPath.section), Row: \(indexPath.row)")
        
        if indexPath.section == 2 {
            if indexPath.row == self.itemCount {
                return super.tableView(tableView, cellForRowAt: indexPath)
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "CustomChartCell", for: indexPath) as! CustomChartCell
                
                cell.yValues = [76, 61, 89, 12, 20, 69, 60, 53, 45, 56, 11, 48, 48, 93, 46, 38, 72, 42, 37, 27, 24, 79, 19, 62, 78, 97, 67, 70, 36, 41, 43, 40, 80, 89, 56, 90, 99, 63, 13, 51, 74, 94, 50, 32, 64, 66, 68, 18, 54, 73, 14, 26, 29, 49, 56, 47, 39, 83, 84, 92, 34, 65, 52, 82, 57, 41, 33, 26, 96, 10, 31, 77, 91, 87, 57, 81, 59, 85, 47, 65, 44, 86, 21, 22, 23, 35, 55, 25, 59, 98, 71, 95, 88, 28, 43, 30, 58, 35, 78, 44, 48, 64]
                cell.xValues = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "60", "61", "62", "63", "64", "65", "66", "67", "68", "69", "70", "71", "72", "73", "74", "75", "76", "77", "78", "79", "80", "81", "82", "83", "84", "85", "86", "87", "88", "89", "90", "91", "92", "93", "94", "95", "96", "97", "98", "99"]
                
                cell.chtChart.leftAxis.axisMaximum = cell.yValues.max()! + 1
                cell.chtChart.leftAxis.axisMinimum = cell.yValues.min()! - 1
                
                cell.chtChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: cell.xValues)
                cell.setChart(dataPoints: cell.xValues, values: cell.yValues)
                
                self.chartHeight = cell.chtChart.frame.size.height
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "BLEDataItemTableViewCell", for: indexPath) as! BLEDataItemTableViewCell

                //Temp solution, currently onlu support one Characteristic Service UUID
                //Multiple Characteristic Services will be supported in the future
                cell.setData(item_name: (selectedProfile?.CharacteristicUUID![0].ItemList![indexPath.row].DataName)!, item_value: "")
                
                return cell
            }
        }
        
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 && indexPath.row == self.itemCount {
            return 360
        }else{
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    func loadProfileData() {
        let viewContext = app.persistentContainer.viewContext
        do {
            let fetchRequest = NSFetchRequest<BLEProfileTable>(entityName: "BLEProfileTable")
            let profile_list = try viewContext.fetch(fetchRequest)
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
        
        let viewContext = app.persistentContainer.viewContext
        do {
            let fetchRequest = NSFetchRequest<BLEProfileTable>(entityName: "BLEProfileTable")
            let profile_list = try viewContext.fetch(fetchRequest)
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
        }

        if pickerView == profilePicker {
            if component == 0 {
                self.category = self.categoryArray[row]
                self.profilePicker.reloadComponent(1)
                let selectedIndex = self.profilePicker.selectedRow(inComponent: 1)
                self.device = self.deviceArray[row][selectedIndex]
                print("Selected category: \(self.category), device: \(self.device)")
                self.selectedProfile = self.requestSelectedProfile(category: self.category, profile_name: self.device)
                self.tableView.reloadData()
            }
            else {
                let selectedIndex = self.profilePicker.selectedRow(inComponent: 0)
                self.device = self.deviceArray[selectedIndex][row]
                print("Selected category: \(self.category), device: \(self.device)")
                self.selectedProfile = self.requestSelectedProfile(category: self.category, profile_name: self.device)
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

class MyIndexFormatter: IndexAxisValueFormatter {
    
    open override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return "\(value)"
        
    }
}
