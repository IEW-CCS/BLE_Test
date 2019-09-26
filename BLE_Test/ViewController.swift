//
//  ViewController.swift
//  TestCoreData
//
//  Created by Lo Fang Chou on 2019/9/5.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    @IBOutlet weak var onlineStatusButton: UIBarButtonItem!
    private var isOnline: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "DashboardMessageCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "DashboardMessageCell")

        let nib2 = UINib(nibName: "DashboardStatusSummaryCell", bundle: nil)
        self.tableView.register(nib2, forCellReuseIdentifier: "DashboardStatusSummaryCell")

        let nib3 = UINib(nibName: "DashboardDataItemChartCell", bundle: nil)
        self.tableView.register(nib3, forCellReuseIdentifier: "DashboardDataItemChartCell")

        let nib4 = UINib(nibName: "DashboardServerNotAvailableCell", bundle: nil)
        self.tableView.register(nib4, forCellReuseIdentifier: "DashboardServerNotAvailableCell")

        self.tableView.backgroundColor = UIColor.white
        self.tableView.layer.backgroundColor = UIColor.white.cgColor
        self.tableView.separatorStyle = .none
        
        self.onlineStatusButton.tintColor = .red
        onlineRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        onlineRequest()
    }
    
    private func onlineRequest() {
        let sessionHttp = URLSession(configuration: .default)
        let url = getUrlForRequest(uri: "CCS_ARE_YOU_THERE")
        let UrlRequest = URLRequest(url: URL(string: url)!)
        
        let task = sessionHttp.dataTask(with: UrlRequest) {(data, response, error) in
            do {
                if error != nil {
                    //DispatchQueue.main.async { self.presentedViewController?.dismiss(animated: false, completion: nil)}
                    let _httpalert = alert(message: error!.localizedDescription, title: "Http Error")
                    DispatchQueue.main.async {self.present(_httpalert, animated : false, completion : nil)}
                    self.isOnline = false
                    DispatchQueue.main.async {
                        self.onlineStatusButton.tintColor = .red
                        self.tableView.reloadData()}
                } else {
                    guard let httpResponse = response as? HTTPURLResponse,
                        (200...299).contains(httpResponse.statusCode) else {
                            let errorResponse = response as? HTTPURLResponse
                            let message: String = String(errorResponse!.statusCode) + " - " + HTTPURLResponse.localizedString(forStatusCode: errorResponse!.statusCode)
                            //DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                            let _httpalert = alert(message: message, title: "Http Error")
                            DispatchQueue.main.async {self.present(_httpalert, animated : false, completion : nil)}
                            self.isOnline = false
                            DispatchQueue.main.async {self.onlineStatusButton.tintColor = .red
                                self.tableView.reloadData()}
                            return
                    }
                    //DispatchQueue.main.async {self.presentedViewController?.dismiss(animated: false, completion: nil)}
                    let outputStr  = String(data: data!, encoding: String.Encoding.utf8) as String?
                    let jsonData = outputStr!.data(using: String.Encoding.utf8, allowLossyConversion: true)
                    let decoder = JSONDecoder()
                    let onlineStatus:WebResponseOnLineStatus = try decoder.decode(WebResponseOnLineStatus.self, from: jsonData!)
                    print("the online request answer is: \(onlineStatus.status)")
                    if onlineStatus.status == "YES" {
                        self.isOnline = true
                        DispatchQueue.main.async {self.onlineStatusButton.tintColor = SERVER_ON_LINE_STATUS
                            self.tableView.reloadData()}
                    }
                }
            } catch {
                print("Online Request Error!")
                print(error.localizedDescription)
                self.isOnline = false
                DispatchQueue.main.async {self.onlineStatusButton.tintColor = .red
                    self.tableView.reloadData()}
                return
            }
        }
        
        task.resume()
        
        return
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isOnline {
            return 3
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isOnline {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardStatusSummaryCell", for: indexPath) as! DashboardStatusSummaryCell
                
                return cell
            }
            
            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardDataItemChartCell", for: indexPath) as! DashboardDataItemChartCell
                
                return cell
            }
            
            if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardMessageCell", for: indexPath) as! DashboardMessageCell
                
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardServerNotAvailableCell", for: indexPath) as! DashboardServerNotAvailableCell
            
            return cell
        }

        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isOnline {
            if indexPath.row == 2 {
                return CGFloat(DASHBOARD_MESSAGE_CELL_HEIGHT)
            }
            return CGFloat(DASHBOARD_STATUS_SUMMARY_CELL_HEIGHT)
        } else {
            return CGFloat(DASHBOARD_STATUS_SUMMARY_CELL_HEIGHT)
        }
    }
}

