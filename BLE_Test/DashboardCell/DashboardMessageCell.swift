//
//  DashboardMessageCell.swift
//  TestCoreData
//
//  Created by Lo Fang Chou on 2019/9/23.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class DashboardMessageCell: UITableViewCell {
    let levelArray = ["e", "w", "i", "w", "w", "i", "e", "e"]
    let messageArray = ["Error condition 1",
                        "Warning: check something1 please",
                        "Information for 1st condition",
                        "Warning: check something2 more information",
                        "Warning: check something3 please",
                        "Information for 2nd condition",
                        "Error condition 2",
                        "Error condition 3"]
    
    @IBOutlet weak var messageTableView: UITableView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.contentView.layer.cornerRadius = CELL_CORNER_RADIUS
        self.contentView.layer.backgroundColor = UIColor.clear.cgColor

        let nib = UINib(nibName: "DashboardBasicTableViewCell", bundle: nil)
        self.messageTableView.register(nib, forCellReuseIdentifier: "DashboardBasicTableViewCell")
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.layer.cornerRadius = CELL_CORNER_RADIUS
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension DashboardMessageCell: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberofSections section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return levelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardBasicTableViewCell", for: indexPath) as! DashboardBasicTableViewCell
        
        cell.setData(level: levelArray[indexPath.row], message: messageArray[indexPath.row])
        
        return cell
    }
}

