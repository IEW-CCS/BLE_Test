//
//  LayoutSVGTableViewCell.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/8/26.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class LayoutSVGTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //let bundle = Bundle(for: type(of: self))
        //let nib = UINib(nibName: "LayoutSVGTableViewCell", bundle: bundle)
        ///透過nib來取得xibView
        //let xibView = nib.instantiate(withOwner: self, options: nil)[0] as! UITableViewCell
        //addSubview(xibView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
