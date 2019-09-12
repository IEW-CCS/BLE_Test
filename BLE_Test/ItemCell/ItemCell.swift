//
//  ItemCell.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/8/22.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class ItemCell: UICollectionViewCell {
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var txtBadge: BadgeSwift!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        txtBadge.isHidden = true
        
    }

    func setData(text: String, image: UIImage) {
        self.textLabel.text = text
        self.imageIcon.image = image
    }
    
    
    func setBadge(badge_number: Int) {
        if badge_number == 0 {
            txtBadge.isHidden = true
        } else {
            txtBadge.isHidden = false
            txtBadge.text = String(badge_number)
        }
    }
}
