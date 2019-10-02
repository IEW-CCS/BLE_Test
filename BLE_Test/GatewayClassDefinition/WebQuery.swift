//
//  WebQuery.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/8/29.
//  Copyright © 2019 JStudio. All rights reserved.
//

import Foundation

struct WebResponseOnLineStatus: Codable {
    let status: String
}

struct WebResponseGatewayList: Codable {
    var gateway_list: [WebResponseGateway]
}

struct WebResponseGateway: Codable {
    let status: String
    let gateway_id: String
    let device_id: String
    //let device_list: [WebResponseDeviceList]
}

struct WebResponseDeviceList: Codable {
    let dvd_list: [WebResponseDeviceDetail]
}

struct WebResponseDeviceDetail: Codable {
    let gateway_id: String
    let device_id: String
    let device_type: String
    let virtual_flag: String
    let plc_ip: String
    let plc_port: String
    let device_status: String
    let iotclient_status: String
    let hb_status: String
    let device_location: String
    let last_edc_time: String
    let hb_report_time: String
    let last_alarm_code: String
    let last_alarm_app: String
    let last_alarm_message: String
    let last_alarm_datetime: String
}

struct ItemDef {
    let title: String
    let subtitle: String
    let `class`: AnyClass
}

struct WebResponseDeviceItemList: Codable {
    let device_item_list: [WebResponseDeviceItem]
}

struct WebResponseDeviceItem: Codable {
    let device_id: String
    let item_list: [WebResponseChartItem]
}

struct WebResponseChartItem: Codable {
    let item_name: String
    let chart_type: String
}

struct WebResponseAlarmList: Codable {
    let alarm_list: [AlarmNotification]
}

struct WebResponseBLEProfileList: Codable {
    let profile_list: [BLEProfile]
}

struct WebResponseChartInfoReply: Codable {
    
    let device_id: String
    let data_list: [WebResponseChartBody]
    
}

struct WebResponseChartBody: Codable {
    let X_asix: String
    let Y_asix: String
}
