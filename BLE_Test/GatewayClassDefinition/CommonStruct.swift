//
//  CommonStruct.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/9/4.
//  Copyright © 2019 JStudio. All rights reserved.
//

import Foundation

struct AlarmNotification: Codable {
    let GatewayID: String
    let DeviceID: String
    let AlarmCode: String
    let AlarmLevel: String
    let AlarmApp: String
    let DateTime: String
    let AlarmDesc: String
}

struct BLEDataItem: Codable {
    let DataName: String
    let DataType: String
}

struct BLECharacteristicData: Codable {
    let UUID: String
    let ItemList: [BLEDataItem]
}

struct BLEProfile: Codable {
    let BLECategory: String
    let BLEName: String
    let BLEDescription: String
    let ServiceUUID: String
    let CharacteristicUUID: [BLECharacteristicData]
    let ConfigParameterList: [BLECharacteristicData]
    let ProfileCreateTime: String
}
