//
//  ViewController.swift
//  TestCoreData
//
//  Created by Lo Fang Chou on 2019/9/5.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    //@IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "DashboardMessageCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "DashboardMessageCell")

        let nib2 = UINib(nibName: "DashboardStatusSummaryCell", bundle: nil)
        self.tableView.register(nib2, forCellReuseIdentifier: "DashboardStatusSummaryCell")

        let nib3 = UINib(nibName: "DashboardDataItemChartCell", bundle: nil)
        self.tableView.register(nib3, forCellReuseIdentifier: "DashboardDataItemChartCell")

        self.tableView.backgroundColor = UIColor.white
        self.tableView.layer.backgroundColor = UIColor.white.cgColor
        self.tableView.separatorStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
        //return self.infoArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 {
            return CGFloat(DASHBOARD_MESSAGE_CELL_HEIGHT)
        }
        
        return CGFloat(DASHBOARD_STATUS_SUMMARY_CELL_HEIGHT)
    }
    
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! DashboardBasicTableViewCell
        cell.selectedBackgroundView = cell.setSelectedView()
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! DashboardBasicTableViewCell
        cell.selectedBackgroundView = nil
    }*/
}

