//
//  BLEProfileTable+CoreDataProperties.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/9/11.
//  Copyright © 2019 JStudio. All rights reserved.
//
//

import Foundation
import CoreData


extension BLEProfileTable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BLEProfileTable> {
        return NSFetchRequest<BLEProfileTable>(entityName: "BLEProfileTable")
    }

    @NSManaged public var profileObject: NSObject?
    @NSManaged public var category: String?
    @NSManaged public var name: String?

}
