//
//  SimpleTableCell.swift
//  UBottomSheet
//
//  Created by ugur on 9.09.2018.
//  Copyright © 2018 otw. All rights reserved.
//

import UIKit

struct SimpleTableCellViewModel {
    let image: UIImage?
    let title: String
    let subtitle: String
}

class SimpleTableCell: UITableViewCell {

    //@IBOutlet weak var _imageView: UIImageView!
    @IBOutlet weak var _titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //_imageView.layer.cornerRadius = _imageView.frame.height/2
        //_imageView.layer.borderWidth = 1
        //_imageView.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    func setData(title: String, sub_title: String){
        _titleLabel.text = title
        subtitleLabel.text = sub_title
        //imageView?.image = model.image
    }


}
