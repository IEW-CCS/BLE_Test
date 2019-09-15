//
//  MQTTStruct.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/9/15.
//  Copyright © 2019 JStudio. All rights reserved.
//

import Foundation

struct EDC_Item: Codable {
    var DATA_NAME: String?
    var DATA_VALUE: String?
    
    init() {
        self.DATA_NAME = ""
        self.DATA_VALUE = ""
    }
}

struct ReplyBLEData: Codable {
    var Device_ID: String?
    var IP_Address: String?
    var Time_Stamp: String?
    var EDC_Data: [EDC_Item]?
    
    init() {
        self.Device_ID = ""
        self.IP_Address = ""
        self.Time_Stamp = ""
        self.EDC_Data = [EDC_Item]()
    }
}
