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

    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.title = self.title
        //requestGatewayList()
        //self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        let loadalert = Activityalert(title: "Loading")
        present(loadalert, animated : true, completion : requestGatewayList)
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        print("numberOfSections")
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("numberOfRowsInSection")
        
        if self.gatewayList == nil {
            print("numberOfRowsInSection returns: 0")
            return 0
        }

        //return gatewayArray.count
        print("numberOfRowsInSection returns: \(String(describing: self.gatewayList?.gateway_list.count))")
        return (self.gatewayList?.gateway_list.count)!
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatusTableViewCell", for: indexPath) as! StatusTableViewCell

        if self.gatewayList != nil {
            let image = UIImage(named: (self.gatewayList!.gateway_list[indexPath.row].status) + ".png")
            cell.setData(gateway_id: (self.gatewayList!.gateway_list[indexPath.row].gateway_id), device_id: (self.gatewayList!.gateway_list[indexPath.row].device_id), image: image!)
        }

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailViewController = segue.destination as? StatusDetailTableViewController,
            let index = tableView.indexPathForSelectedRow?.row
            else {
                return
        }
        detailViewController.received_device_id = self.gatewayList!.gateway_list[index].device_id
    }
    
    func requestGatewayList() {
        let sessionHttp = URLSession(configuration: .default)
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
