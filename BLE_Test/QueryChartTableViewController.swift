//
//  QueryChartTableViewController.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/8/26.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class QueryChartTableViewController: UITableViewController {
    @IBOutlet weak var devicePicker: UIPickerView!
    
    //let gatewayArray = ["gateway001", "gateway002", "gateway003", "gateway004", "gateway005"]
    //let deviceArray = ["device001", "device002", "device003"]
    var gatewayArray = [String]()
    var deviceArray = [[String]]()
    // this is testing
    var deviceID = "this is test"
    var itemArray = [WebResponseChartItem]()
    
    var listDictionary: Dictionary<String, [String]> = [:]
    
    private  let _myalert = UIAlertController(title: "Loading...",message: "\n\n\n",preferredStyle: .alert)
    
    private var itemDefs = [ItemDef(title: "Time Line Chart",
                                    subtitle: "Simple demonstration of a time-chart.",
                                    class: LineChartTimeViewController.self),
                            ItemDef(title: "Combined Chart",
                                    subtitle: "Demonstrates how to create a combined chart (bar and line in this case).",
                                    class: CombinedChartViewController.self),
                            ItemDef(title: "Colored Line Chart",
                                    subtitle: "Shows a LineChart with different background and line color.",
                                    class: ColoredLineChartViewController.self),
                            ItemDef(title: "Sinus Bar Chart",
                                    subtitle: "A Bar Chart plotting the sinus function with 8.000 values.",
                                    class: SinusBarChartViewController.self),
                            ItemDef(title: "Pie Chart",
                                    subtitle: "A simple demonstration of the pie chart.",
                                    class: PieChartViewController.self)
    ]
    
    override func viewWillAppear(_ animated: Bool) {
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.devicePicker.delegate = self
        self.devicePicker.dataSource = self

        
        //self.tableView.register(ChartItemTableViewCell.self, forCellReuseIdentifier: "ChartItem")
        
        let nib = UINib(nibName: "ChartItemTableViewCell", bundle: nil)
        //註冊，forCellReuseIdentifier是你的TableView裡面設定的Cell名稱
        self.tableView.register(nib, forCellReuseIdentifier: "ChartItem")
        
       // requestGatewayList()
        
        let _loadingIndicator =  UIActivityIndicatorView(frame: _myalert.view.bounds)
        _loadingIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _loadingIndicator.color = UIColor.blue
        _loadingIndicator.startAnimating()
        _myalert.view.addSubview(_loadingIndicator)
        present(_myalert, animated : true, completion : requestGatewayList)
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            print("Section 1 numberOfRowsInSection: \(self.itemArray.count)")
            //return self.itemArray.count
            let count = self.itemArray.count
            return count
        }else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            if self.itemArray.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChartItem", for: indexPath) as! ChartItemTableViewCell

                print("Section 1 row: \(indexPath.row)")
                print("self.itemArray[indexPath.row].item_name: \(self.itemArray[indexPath.row].item_name)")
                let name = "\(self.itemArray[indexPath.row].item_name) -- \(self.itemDefs[Int(self.itemArray[indexPath.row].chart_type)!].title)"
                print("name = \(name)")
                //cell.setData(item_name: "\(self.itemArray[indexPath.row].item_name) -- \(self.itemDefs[Int(self.itemArray[indexPath.row].chart_type)!].title)")
                cell.setData(item_name: name)
                //cell.txtLabel.text = name

                return cell
            } else {
                return super.tableView(tableView, cellForRowAt: indexPath)
            }
        }else{
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    /*
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPath.section == 1 {
            let newIndexPath = IndexPath(row: 0, section: indexPath.section)
            return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
        }else{
            return super.tableView(tableView, indentationLevelForRowAt: indexPath)
        }
    }
    */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let alertController = UIAlertController(title: "Information", message: msg, preferredStyle: .alert)
        //let defaultAction = UIAlertAction(title: "Close Alert", style: .default, handler: nil)
        //alertController.addAction(defaultAction)
        //present(alertController, animated: true, completion: nil)
        
        if indexPath.section == 1 {
            //let def = self.itemDefs[indexPath.row]
            print("Chart type is: \(Int(self.itemArray[indexPath.row].chart_type)!)")
            
            let def = self.itemDefs[Int(self.itemArray[indexPath.row].chart_type)!]
            let vcClass = def.class as! UIViewController.Type
            let vc = vcClass.init()
            
            AppDelegate.select_DeviceID = deviceID
            AppDelegate.select_EDCItem = self.itemArray[indexPath.row].item_name

            self.navigationController?.pushViewController(vc, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func requestGatewayList() {
        let sessionHttp = URLSession(configuration: .default)
        let url = getUrlForRequest(uri: "CCS_Gateway_List")
        let UrlRequest = URLRequest(url: URL(string: url)!)
        var gatewayList: WebResponseGatewayList?
        
        //var gatewayList: WebResponseGatewayList?
        print("requestGatewayList")
        let task = sessionHttp.dataTask(with: UrlRequest) {(data, response, error) in
            do {
                if error != nil{
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                    let _httpalert = UIAlertController(title: "Error",message: (error?.localizedDescription) ,preferredStyle: .alert)
                    let _OKaction = UIAlertAction(title:"OK",style: .default ){(UIAlertAction) in self.dismiss(animated: false, completion:nil)}
                    _httpalert.addAction(_OKaction)
                    self.present(_httpalert, animated : false, completion : nil)
                    
                }else{
                    
                    let outputStr  = String(data: data!, encoding: String.Encoding.utf8) as String?
                    let jsonData = outputStr!.data(using: String.Encoding.utf8, allowLossyConversion: true)
                    let decoder = JSONDecoder()
                    gatewayList = try decoder.decode(WebResponseGatewayList.self, from: jsonData!)
                    print("json decoding seems OK!!")
                    
                   // if gatewayList != nil {
                    if gatewayList != nil {
                        self.prepareListDictionary(dic_data: gatewayList!)
                     }
                   //}
                    DispatchQueue.main.async {
                      self.devicePicker.reloadAllComponents()
                      self.devicePicker.selectRow(0, inComponent: 0, animated: false)
                      self.devicePicker.selectRow(0, inComponent: 1, animated: false)
                      //self.devicePicker(pickerView: self.devicePicker, row: 0, component: 0)
                      print("Initial deviceID is: \(self.deviceID)")
                      self.requestDeviceItem(device_id: self.deviceID)
                      //self.tableView.reloadData()
                    }
                }
            } catch {
                print(error.localizedDescription)

                return
            }
        }
        task.resume()
        
        return
    }
    
    func prepareListDictionary(dic_data: WebResponseGatewayList) {
        for index in 0...dic_data.gateway_list.count - 1 {
            let tmpGateway = self.listDictionary[dic_data.gateway_list[index].gateway_id]
            if tmpGateway == nil {
                self.listDictionary.updateValue([dic_data.gateway_list[index].device_id], forKey: dic_data.gateway_list[index].gateway_id)
                //print("prepareListDictionary add -> index: \(index)")
                self.gatewayArray.append(dic_data.gateway_list[index].gateway_id)
                self.deviceArray.append([dic_data.gateway_list[index].device_id])
            }
            else {
                var tmpDeviceList: [String]?
                tmpDeviceList = self.listDictionary[dic_data.gateway_list[index].gateway_id]
                tmpDeviceList!.append(dic_data.gateway_list[index].device_id)
                self.listDictionary.updateValue(tmpDeviceList!, forKey: dic_data.gateway_list[index].gateway_id)
                //print("prepareListDictionary update -> index: \(index)")
                var deviceArrayIndex = 0
                for gw_index in 0...self.gatewayArray.count - 1 {
                    if self.gatewayArray[gw_index] == dic_data.gateway_list[index].gateway_id {
                        deviceArrayIndex = gw_index
                        break
                    }
                }
                self.deviceArray[deviceArrayIndex] = tmpDeviceList!
            }
        }
        
        if self.listDictionary.count > 0 {
            self.deviceID  = self.deviceArray[0][0]
        }
    }
    
    func requestDeviceItem(device_id: String) {
        let sessionHttp = URLSession(configuration: .default)
        let url = getUrlForRequest(uri: "CCS_Chart_Item_List") + "/\(device_id)"
        let UrlRequest = URLRequest(url: URL(string: url)!)
        var deviceItem: WebResponseDeviceItem?
        
        //var gatewayList: WebResponseGatewayList?
        print("requestGatewayList")
        let task = sessionHttp.dataTask(with: UrlRequest) {(data, response, error) in
            do {
                
                if error != nil{
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                    let _httpalert = UIAlertController(title: "Error",message: (error?.localizedDescription) ,preferredStyle: .alert)
                    let _OKaction = UIAlertAction(title:"OK",style: .default ){(UIAlertAction) in self.dismiss(animated: false, completion:nil)}
                    _httpalert.addAction(_OKaction)
                    self.present(_httpalert, animated : false, completion : nil)
                    
                }else{
                    let outputStr  = String(data: data!, encoding: String.Encoding.utf8) as String?
                    let jsonData = outputStr!.data(using: String.Encoding.utf8, allowLossyConversion: true)
                    let decoder = JSONDecoder()
                    deviceItem = try decoder.decode(WebResponseDeviceItem.self, from: jsonData!)
                    print("json decoding seems OK!!")
                    if deviceItem != nil {
                        //self.prepareListDictionary(dic_data: gatewayList!)
                        self.itemArray.removeAll()
                        self.itemArray = deviceItem!.item_list
                        DispatchQueue.main.async {
                            self.presentedViewController?.dismiss(animated: false, completion: nil)
                            self.tableView.reloadData()
                            
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
                
                return
            }
        }
        task.resume()
        
        return
    }
}

extension QueryChartTableViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        //print("numberOfComponents")
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //print("numberOfRowsInComponent: \(component)")
        if self.listDictionary.count > 0 {
            if component == 0 {
                return self.listDictionary.count
            } else {
                let selectedIndex = self.devicePicker.selectedRow(inComponent: 0)
                return self.deviceArray[selectedIndex].count
            }
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //print("titleForRow: \(row), component: \(component)")

        if self.listDictionary.count > 0 {
            if component == 0 {
                return self.gatewayArray[row]
            } else {
                let selectedIndex = self.devicePicker.selectedRow(inComponent: 0)
                return self.deviceArray[selectedIndex][row]
            }
        }
        
        return " "
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if self.listDictionary.count > 0 {
            print("didSelectRow: \(row), component: \(component)")
            if component == 0 {
                print("Selected gateway is: \(self.gatewayArray[row])")
                self.devicePicker.reloadComponent(1)
                let selectedIndex = self.devicePicker.selectedRow(inComponent: 1)
                print("Selected device is: \(self.deviceArray[row][selectedIndex])")
                self.deviceID = self.deviceArray[row][selectedIndex]
                self.requestDeviceItem(device_id: self.deviceID)
            }
            else {
                let selectedIndex = self.devicePicker.selectedRow(inComponent: 0)
                print("Selected device is: \(self.deviceArray[selectedIndex][row])")
                self.deviceID = self.deviceArray[selectedIndex][row]
                self.requestDeviceItem(device_id: self.deviceID)
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var title = UILabel()
        if let v = view as? UILabel { title = v }
        title.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold)
        title.textColor = UIColor.blue
        title.textAlignment = .center
        
        if component == 0 {
            title.text = self.gatewayArray[row]
        } else {
            let selectedIndex = self.devicePicker.selectedRow(inComponent: 0)
            title.text = self.deviceArray[selectedIndex][row]
        }
        
        return title
    }

}
