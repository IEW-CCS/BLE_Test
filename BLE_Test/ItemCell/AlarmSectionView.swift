//
//  AlarmSectionView.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/9/4.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

protocol SectionViewDelegate: class {
    func sectionView(_ sectionView: AlarmSectionView, _ didPressTag: Int, _ isExpand: Bool)
}

class AlarmSectionView: UITableViewHeaderFooterView {
    @IBOutlet weak var txtAlarmDateTime: UILabel!
    @IBOutlet weak var txtGatewayID: UILabel!
    @IBOutlet weak var txtDeviceID: UILabel!
    @IBOutlet weak var txtBadge: BadgeSwift!
    @IBOutlet weak var btnRemove: BadgeSwift!
    @IBOutlet weak var backView: ShadowGradientView!
    
    weak var delegate: SectionViewDelegate?
    var buttonTag: Int = 0
    var isExpand: Bool = false
    var isDisplayRemoveButton = false
    var isLongPressed = false
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let gesTap = UITapGestureRecognizer(target: self, action:#selector(self.handleTap(_:)))
        gesTap.delegate = self
        self.addGestureRecognizer(gesTap)
        
        let gesLongPress = UILongPressGestureRecognizer(target: self, action:#selector(self.handleLongPress(_:)))
        gesLongPress.delegate = self
        self.addGestureRecognizer(gesLongPress)

        btnRemove.isUserInteractionEnabled = true
        let gesRemove = UITapGestureRecognizer(target: self, action:#selector(self.handleRemoveTap(_:)))
        gesRemove.delegate = self
        btnRemove.addGestureRecognizer(gesRemove)
        
        btnRemove.isEnabled = false
        btnRemove.isHidden = true
        AdjustAutoLayout()
    }

    func setData(date_time: String, gateway_id: String, device_id: String, alarm_level: String, badge_number: String) {
        txtAlarmDateTime.text = date_time
        txtGatewayID.text = gateway_id
        txtDeviceID.text = device_id
        let number: Int = Int(badge_number)!
        if number > 0 {
            txtBadge.text = "un-read"
            txtBadge.badgeColor = UIColor.red
        } else {
            txtBadge.text = "read"
            txtBadge.badgeColor = UIColor(red: 43/255, green: 124/255, blue: 212/255, alpha: 1.0)
        }

        switch alarm_level {
        case "E":
            txtAlarmDateTime.textColor = UIColor(red: 0.888, green: 0.004, blue: 0.002, alpha: 1.0)

        case "W":
            txtAlarmDateTime.textColor = UIColor(red: 237/255, green: 130/255, blue: 13/255, alpha: 1.0)
            
        default:
            return
        }
    }
    
    public func AdjustAutoLayout()
    {
        self.backView.AdjustAutoLayout()
    }
    
    @objc func handleRemoveTap(_ sender: UITapGestureRecognizer) {
        AdjustAutoLayout()
        print("Remove button is tapped")
        NotificationCenter.default.post(
            name: NSNotification.Name("RemoveSection"),
            object: Int(self.tag))
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        //AdjustAutoLayout()
        print("Section \(self.tag) is tapped")
        if self.isLongPressed == true {
            self.isLongPressed = false
        } else {
            btnRemove.isEnabled = false
            btnRemove.isHidden = true

            self.isLongPressed = false
            if !self.isDisplayRemoveButton {
                self.delegate?.sectionView(self, self.buttonTag, self.isExpand)
            }
            self.isDisplayRemoveButton = false
        }
    }
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        AdjustAutoLayout()
        if sender.state == .began {
            print("Section \(self.tag) is long pressed")
            self.isDisplayRemoveButton = true
            btnRemove.isEnabled = true
            btnRemove.isHidden = false

            self.isLongPressed = true
            
            self.shake()
            
            return
        }
    }
}

extension AlarmSectionView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //AdjustAutoLayout()
        return true
    }
}

public extension UIView {
    func shake(count : Float = 5, for duration : TimeInterval = 1, withTranslation translation : Float = 5) {
       
        let shake = CABasicAnimation(keyPath: "transform.rotation.z")
        shake.fromValue = -0.03
        shake.toValue = 0.03
        shake.duration = 0.1
        shake.autoreverses = true
        shake.repeatCount = 4
        
        layer.add(shake, forKey: "shakeAnimation")
    }
}
