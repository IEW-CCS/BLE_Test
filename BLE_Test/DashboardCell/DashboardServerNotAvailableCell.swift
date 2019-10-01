//
//  DashboardServerNotAvailableCell.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/9/26.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class DashboardServerNotAvailableCell: UITableViewCell {

    @IBOutlet weak var ShadowGradientView: ShadowGradientView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func AdjustAutoLayout()
    {
        ShadowGradientView.AdjustAutoLayout()
    }
    
}
