//
//  StatusTableViewCell.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/8/25.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class StatusTableViewCell: UITableViewCell {
    
    @IBOutlet weak var gatewayLabel: UILabel!
    @IBOutlet weak var deviceLabel: UILabel!
    @IBOutlet weak var statusView: ShadowGradientView!
    @IBOutlet weak var backView: ShadowGradientView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.backgroundColor = UIColor.clear
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setData(gateway_id: String, device_id: String, status: String) {
        self.gatewayLabel.text = gateway_id
        self.deviceLabel.text = device_id
        switch status {
        case "Run":
            self.statusView.labelColor = UIColor.darkGray
            self.statusView.gradientColor = GRADIENT_COLOR_GREEN
            self.statusView.labelText = "R"
            break
            
        case "Down":
            self.statusView.labelColor = UIColor.white
            self.statusView.gradientColor = GRADIENT_COLOR_RED
            self.statusView.labelText = "D"
            break
            
        case "Idle":
            self.statusView.labelColor = UIColor.darkGray
            self.statusView.gradientColor = GRADIENT_COLOR_YELLOW
            self.statusView.labelText = "I"
            break
            
        case "Ready":
            self.statusView.labelColor = UIColor.darkGray
            self.statusView.gradientColor = GRADIENT_COLOR_LIGHTBLUE
            self.statusView.labelText = "r"
            break

        default:
            self.statusView.labelColor = UIColor.white
            self.statusView.gradientColor = GRADIENT_COLOR_BLUEGREY
            break
        }
    }

    public func AdjustAutoLayout()
    {
        self.backView.AdjustAutoLayout()
    }
}
