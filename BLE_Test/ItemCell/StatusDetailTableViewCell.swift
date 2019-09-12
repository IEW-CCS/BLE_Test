//
//  StatusDetailTableViewCell.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/8/25.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class StatusDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(item: String, information: String) {
        self.itemLabel.text = item
        self.infoLabel.text = information
    }

}
