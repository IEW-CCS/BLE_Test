//
//  ChartItemTableViewCell.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/9/2.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class ChartItemTableViewCell: UITableViewCell {
    @IBOutlet weak var txtLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(item_name: String) {
        self.txtLabel.text = item_name
    }

}
