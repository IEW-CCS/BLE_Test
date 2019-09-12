//
//  ProfileTransformer.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/9/10.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class ProfileTransformer: ValueTransformer {
    override func transformedValue(_ value: Any?) -> Any? {
        if let value = value {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false)
                return data
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
        
        return nil
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        if let value = value {
            do {
                let data = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(value as! Data) as! [ProfileObject]
                return data
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
        
        return  nil
    }
}
