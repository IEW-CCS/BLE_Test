//
//  BLEDataItemTableViewCell.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/9/12.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class BLEDataItemTableViewCell: UITableViewCell {
    @IBOutlet weak var txtDataItem: UILabel!
    @IBOutlet weak var txtDataValue: UILabel!
    @IBOutlet weak var swhEnable: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        swhEnable.isOn = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func enableHistoryChart(_ sender: UISwitch) {
        if sender.isOn {
            print("Turn on data history chart for row: \(self.tag)")
            NotificationCenter.default.post(
                name: NSNotification.Name("TurnOnChartHistory"),
                object: Int(self.tag))
        } else {
            print("Turn off data history chart for row: \(self.tag)")
            NotificationCenter.default.post(
                name: NSNotification.Name("TurnOffChartHistory"),
                object: Int(self.tag))
        }
    }
    
    func setData(item_name: String, item_value: String) {
        txtDataItem.text = item_name
        txtDataValue.text = item_value
    }
    
    func setValue(item_value: String) {
        txtDataValue.text = item_value
    }
    
    func setOnOff(enabled: Bool) {
        swhEnable.isOn = enabled
    }
}
