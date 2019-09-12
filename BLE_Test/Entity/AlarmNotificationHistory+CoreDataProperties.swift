//
//  AlarmNotificationHistory+CoreDataProperties.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/9/5.
//  Copyright © 2019 JStudio. All rights reserved.
//
//

import Foundation
import CoreData


extension AlarmNotificationHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AlarmNotificationHistory> {
        return NSFetchRequest<AlarmNotificationHistory>(entityName: "AlarmNotificationHistory")
    }

    @NSManaged public var alarm_app: String?
    @NSManaged public var alarm_code: String?
    @NSManaged public var alarm_datetime: NSDate?
    @NSManaged public var alarm_level: String?
    @NSManaged public var alarm_message: String?
    @NSManaged public var badge_number: Int16
    @NSManaged public var device_id: String?
    @NSManaged public var gateway_id: String?
    @NSManaged public var is_archived: Bool
    @NSManaged public var id: String?

}
