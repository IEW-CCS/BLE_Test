//
//  ProfileObject.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/9/10.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class ProfileObject: NSObject, NSCoding {
    var BLECategory: String
    var BLEName: String
    var BLEDescription: String
    var ServiceUUID: String
    var CharacteristicUUID: [CharacteristicDataObject]?
    var ConfigParameterList: [CharacteristicDataObject]?
    var ProfileCreateTime: String
    
    override init() {
        self.BLECategory = ""
        self.BLEName = ""
        self.BLEDescription = ""
        self.ServiceUUID = ""
        self.CharacteristicUUID = []
        self.ConfigParameterList = []
        self.ProfileCreateTime = ""
        super.init()
    }
    
    init(data: BLEProfile) {
        self.BLECategory = data.BLECategory
        self.BLEName = data.BLEName
        self.BLEDescription = data.BLEDescription
        self.ServiceUUID = data.ServiceUUID
        self.CharacteristicUUID = []
        for tmpUUID in data.CharacteristicUUID {
            let tmpData = CharacteristicDataObject(data: tmpUUID)
            self.CharacteristicUUID?.append(tmpData)
        }
        self.ConfigParameterList = []
        for tmpParameter in data.ConfigParameterList {
            let tmpParam = CharacteristicDataObject(data: tmpParameter)
            self.ConfigParameterList?.append(tmpParam)
        }

        self.ProfileCreateTime = data.ProfileCreateTime
    }
    
    //encoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(BLECategory, forKey: "BLECategory")
        aCoder.encode(BLEName, forKey: "BLEName")
        aCoder.encode(BLEDescription, forKey: "BLEDescription")
        aCoder.encode(ServiceUUID, forKey: "ServiceUUID")
        aCoder.encode(CharacteristicUUID, forKey: "CharacteristicUUID")
        aCoder.encode(ConfigParameterList, forKey: "ConfigParameterList")
        aCoder.encode(ProfileCreateTime, forKey: "ProfileCreateTime")
    }
    
    //decoding
    required init?(coder aDecoder: NSCoder) {
        BLECategory = aDecoder.decodeObject(forKey: "BLECategory") as! String
        BLEName = aDecoder.decodeObject(forKey: "BLEName") as! String
        BLEDescription = aDecoder.decodeObject(forKey: "BLEDescription") as! String
        ServiceUUID = aDecoder.decodeObject(forKey: "ServiceUUID") as! String
        CharacteristicUUID = aDecoder.decodeObject(forKey: "CharacteristicUUID") as? [CharacteristicDataObject]
        ConfigParameterList = aDecoder.decodeObject(forKey: "ConfigParameterList") as? [CharacteristicDataObject]
        ProfileCreateTime = aDecoder.decodeObject(forKey: "ProfileCreateTime") as! String
    }
}

class CharacteristicDataObject: NSObject, NSCoding {
    var UUID: String
    var ItemList: [DataItemObject]?
    
    override init() {
        self.UUID = ""
        self.ItemList = []
        super.init()
    }
    
    init(data_uuid: String, data_itemlist: [DataItemObject]) {
        self.UUID = data_uuid
        self.ItemList = data_itemlist
    }
    
    init(data: BLECharacteristicData) {
        //super.init()
        self.UUID = data.UUID
        self.ItemList = []
        for tmp in data.ItemList {
            self.ItemList?.append(DataItemObject(data_name: tmp.DataName, data_type: tmp.DataType))
        }
    }

    //encoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(UUID, forKey: "UUID")
        aCoder.encode(ItemList, forKey: "ItemList")
    }
    
    //decoding
    required init?(coder aDecoder: NSCoder) {
        UUID = aDecoder.decodeObject(forKey: "UUID") as! String
        ItemList = aDecoder.decodeObject(forKey: "ItemList") as? [DataItemObject]
    }
}

class DataItemObject: NSObject, NSCoding {
    var DataName: String
    var DataType: String
    
    override init() {
        self.DataName = ""
        self.DataType = ""
        super.init()
    }
    
    init(data_name: String, data_type: String) {
        self.DataName = data_name
        self.DataType = data_type
    }
    
    func setData(data_name: String, data_type: String) {
        self.DataName = data_name
        self.DataType = data_type
    }

    //encoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(DataName, forKey: "DataName")
        aCoder.encode(DataType, forKey: "DataType")
    }
    
    //decoding
    required init?(coder aDecoder: NSCoder) {
        DataName = aDecoder.decodeObject(forKey: "DataName") as! String
        DataType = aDecoder.decodeObject(forKey: "DataType") as! String
    }

}
