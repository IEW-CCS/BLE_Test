//
//  DashboardBasicTableViewCell.swift
//  TestCoreData
//
//  Created by Lo Fang Chou on 2019/9/17.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class DashboardBasicTableViewCell: UITableViewCell {
    //@IBOutlet weak var txtLevel: UILabel!
    @IBOutlet weak var txtMessage: UILabel!
    @IBOutlet weak var levelView: ShadowGradientView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.contentView.layer.cornerRadius = CGFloat(CELL_CORNER_RADIUS)
        self.contentView.layer.backgroundColor = UIColor.white.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(level: String, message: String) {
        //txtLevel.text = level
        levelView.labelText = level
        txtMessage.text = message
        
        switch level {
        case "e":
            levelView.labelColor = UIColor.white
            self.levelView.gradientColor = GRADIENT_COLOR_RED
            break
            
        case "w":
            levelView.labelColor = UIColor.brown
            self.levelView.gradientColor = GRADIENT_COLOR_ORANGE
            break
            
        case "i":
            levelView.labelColor = UIColor.black
            self.levelView.gradientColor = GRADIENT_COLOR_CYAN
            break
            
        default:
            break
        }
    }
}
