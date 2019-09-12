//
//  LayoutTableViewController.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/8/26.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class LayoutTableViewController: UITableViewController {
    let itemArray = ["GatewayID", "DeviceID", "Type", "Virtual", "PLC IP", "PLC Port", "Status", "IOT Status", "HB Status", "Location", "EDC Time", "HB Time", "Alarm Code", "Alarm App", "Message", "Alarm Time"]
    let infoArray = ["gateway001", "device001", "PLC", "N", "192.168.1.1", "6001", "Run", "Run", "Run", "4F-1", "2019/08/25 10:00:00", "2019/08/25 10:00:02", "0001", "WORKER", "OK", "2019/08/25 10:00:03"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemArray.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            //let cell = tableView.dequeueReusableCell(withIdentifier: "LayoutSVGTableViewCell", for: indexPath) as! LayoutSVGTableViewCell
            //cell.setData(item: self.itemArray[indexPath.row], information: self.infoArray[indexPath.row])
            //let cell = LayoutSVGTableViewCell()
            let bundle = Bundle(for: type(of: self))
            let nib = UINib(nibName: "LayoutSVGTableViewCell", bundle: bundle)
            ///透過nib來取得cell view
            let cell = nib.instantiate(withOwner: self, options: nil)[0] as! UITableViewCell
            //addSubview(xibView)

            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LayoutDetailTableViewCell", for: indexPath) as! LayoutDetailTableViewCell
        
        cell.setData(item: self.itemArray[indexPath.row - 1], information: self.infoArray[indexPath.row - 1])
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 360
        }else{
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
