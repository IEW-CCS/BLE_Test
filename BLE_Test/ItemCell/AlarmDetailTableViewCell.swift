//
//  AlarmDetailTableViewCell.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/9/4.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class AlarmDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var txtItem: UILabel!
    @IBOutlet weak var txtInformation: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tap = UITapGestureRecognizer(target: self, action:#selector(self.handleTap(_:)))
        tap.delegate = self
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        self.addGestureRecognizer(tap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(item_name: String, information: String) {
        txtItem.text = item_name
        txtInformation.text = information
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        print("Row is tapped")
    }
}
