//
//  BasicCollectionViewCell.swift
//  TestCoreData
//
//  Created by Lo Fang Chou on 2019/9/26.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class BasicCollectionViewCell: UICollectionViewCell {
    var shadowView: ShadowGradientView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        self.shadowView = ShadowGradientView(frame: CGRect(x: 0, y:0, width: CGFloat(DASHBOARD_CATEGORY_CELL_WIDTH), height: CGFloat(DASHBOARD_CATEGORY_CELL_WIDTH)))
        self.shadowView.gradientColor = GRADIENT_COLOR_ORANGE
        self.shadowView.shadowColor = UIColor.clear
        self.shadowView.layer.zPosition = 1
        self.addSubview(self.shadowView)
        self.shadowView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.shadowView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    func setText(text: String) {
        self.shadowView.labelText = text
    }
    
    func selected() {
        self.shadowView.gradientColor = GRADIENT_COLOR_RED
    }
    
    func unselected() {
        self.shadowView.gradientColor = GRADIENT_COLOR_ORANGE
    }
}
