//
//  StatusTableViewController.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/8/25.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class StatusTableViewController: UITableViewController {
    private var gatewayList: WebResponseGatewayList?
    private var isFirstLoad: Bool = true

    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.title = self.title
        if self.isFirstLoad {
            self.isFirstLoad = false
            return
        }

        requestGatewayList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        let loadalert = Activityalert(title: "Loading")
        present(loadalert, animated : true, completion : requestGatewayList)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        print("numberOfSections")
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("numberOfRowsInSection")
        
        if !HTTP_SERVER_ONLINE_STATUS {
            print("StatusTableViewController server is off-line")
            return 0
        }
        
        if self.gatewayList == nil {
            print("numberOfRowsInSection returns: 0")
            return 0
        }

        return (self.gatewayList?.gateway_list.count)!
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatusTableViewCell", for: indexPath) as! StatusTableViewCell

        if !(self.gatewayList?.gateway_list.isEmpty)! {
            cell.setData(gateway_id: (self.gatewayList!.gateway_list[indexPath.row].gateway_id), device_id: (self.gatewayList!.gateway_list[indexPath.row].device_id), status: self.gatewayList!.gateway_list[indexPath.row].status)
            cell.AdjustAutoLayout()
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (self.gatewayList?.gateway_list.isEmpty)! {
            return
        }
        
        guard let detailViewController = segue.destination as? StatusDetailTableViewController,
            let index = tableView.indexPathForSelectedRow?.row
            else {
                return
            }
        
        detailViewController.received_device_id = self.gatewayList!.gateway_list[index].device_id
    }
    
    func requestGatewayList() {
        self.gatewayList?.gateway_list.removeAll()
        
        let sessionConf = URLSessionConfiguration.default
        sessionConf.timeoutIntervalForRequest = HTTP_REQUEST_TIMEOUT
        sessionConf.timeoutIntervalForResource = HTTP_REQUEST_TIMEOUT
        let sessionHttp = URLSession(configuration: sessionConf)
        //let sessionHttp = URLSession(configuration: .default)
        let url = getUrlForRequest(uri: "CCS_Gateway_List")
        let UrlRequest = URLRequest(url: URL(string: url)!)
        
        //var gatewayList: WebResponseGatewayList?
        print("requestGatewayList")
        let task = sessionHttp.dataTask(with: UrlRequest) {(data, response, error) in
            do {
                
                if error != nil{
                    DispatchQueue.main.async { self.presentedViewController?.dismiss(animated: false, completion: nil)}
                    let _httpalert = alert(message: error!.localizedDescription, title: "Http Error")
                    self.present(_httpalert, animated : false, completion : nil)
                    DispatchQueue.main.async {self.tableView.reloadData()}
                }
                else{
                    guard let httpResponse = response as? HTTPURLResponse,
                        (200...299).contains(httpResponse.statusCode) else {
                            
                            let errorResponse = response as? HTTPURLResponse
                            let message: String = String(errorResponse!.statusCode) + " - " + HTTPURLResponse.localizedString(forStatusCode: errorResponse!.statusCode)
                            DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                            let _httpalert = alert(message: message, title: "Http Error")
                            self.present(_httpalert, animated : false, completion : nil)
                            DispatchQueue.main.async {self.tableView.reloadData()}
                            return
                    }
                    
                    DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                    let outputStr  = String(data: data!, encoding: String.Encoding.utf8) as String?
                    let jsonData = outputStr!.data(using: String.Encoding.utf8, allowLossyConversion: true)
                    let decoder = JSONDecoder()
                    self.gatewayList = try decoder.decode(WebResponseGatewayList.self, from: jsonData!)
                    print("json decoding seems OK!!")
                    DispatchQueue.main.async {self.tableView.reloadData()}
                }
                //self.tableView.reloadData()
            } catch {
                print("Cannot connect to server")
                print(error.localizedDescription)
                return
            }
        }
        task.resume()
        
        return
    }
}

extension URLSession {
    func dataTask(with url: URL, result: @escaping (Result<(URLResponse, Data), Error>) -> Void) -> URLSessionDataTask {
        return dataTask(with: url) { (data, response, error) in
            if let error = error {
                result(.failure(error))
                return
            }
            guard let response = response, let data = data else {
                let error = NSError(domain: "error", code: 0, userInfo: nil)
                result(.failure(error))
                return
            }
            result(.success((response, data)))
        }
    }
}
