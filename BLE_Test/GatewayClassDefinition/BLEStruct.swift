//
//  BLEStruct.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/9/13.
//  Copyright © 2019 JStudio. All rights reserved.
//

import Foundation

struct BLEReceivedDataList: Codable {
    let data_value_list: [BLEReceivedDataValue]
}

struct BLEReceivedDataValue: Codable {
    let DataName: String
    let DataValue: String
}
