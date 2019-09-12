//
//  StatusDetailTableViewController.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/8/25.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class StatusDetailTableViewController: UITableViewController {
    let headerArray = ["GatewayID", "DeviceID", "Type", "Virtual", "PLC IP", "PLC Port", "Status", "IOT Status", "HB Status", "Location", "EDC Time", "HB Time", "Alarm Code", "Alarm App", "Message", "Alarm Time"]

    var infoArray: [String]?
    var received_device_id: String?
    var device_detail: WebResponseDeviceDetail?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Received device id is: \(self.received_device_id!)")
        requestDeviceDetail(device_id: self.received_device_id!)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.infoArray == nil {
            print("numberOfRowsInSection returns: 0")
            return 0
        }

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return headerArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatusDetailTableViewCell", for: indexPath) as! StatusDetailTableViewCell
        
        if self.infoArray != nil {
            cell.setData(item: self.headerArray[indexPath.row], information: self.infoArray![indexPath.row])
        }
        
        return cell
    }
    
    func requestDeviceDetail(device_id: String) {
        let sessionHttp = URLSession(configuration: .default)
        let url = getUrlForRequest(uri: "CCS_Device_Detail") + "/\(device_id)"
        
        let UrlRequest = URLRequest(url: URL(string: url)!)
        
        //var gatewayList: WebResponseGatewayList?
        print("requestDeviceDetail")
        let task = sessionHttp.dataTask(with: UrlRequest) {(data, response, error) in
            do {
                let outputStr  = String(data: data!, encoding: String.Encoding.utf8) as String?
                //print("Received device detail data: \(String(describing: outputStr))")
                let jsonData = outputStr!.data(using: String.Encoding.utf8, allowLossyConversion: true)
                let decoder = JSONDecoder()
                self.device_detail = try decoder.decode(WebResponseDeviceDetail.self, from: jsonData!)
                //print("json decoding seems OK!!")
                if self.device_detail != nil {
                    self.prepareDetailData(detail_data: self.device_detail!)
                }
                DispatchQueue.main.async {self.tableView.reloadData()}
            } catch {
                print(error.localizedDescription)

                return
            }
        }
        task.resume()
        
        return
    }

    func prepareDetailData(detail_data: WebResponseDeviceDetail) {
        self.infoArray = [detail_data.gateway_id, detail_data.device_id, detail_data.device_type, detail_data.virtual_flag, detail_data.plc_ip, detail_data.plc_port, detail_data.device_status, detail_data.iotclient_status, detail_data.hb_status, detail_data.device_location, detail_data.last_edc_time, detail_data.hb_report_time, detail_data.last_alarm_code, detail_data.last_alarm_app, detail_data.last_alarm_message, detail_data.last_alarm_datetime]
    }
}
