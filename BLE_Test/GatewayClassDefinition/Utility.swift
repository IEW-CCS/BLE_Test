import Foundation

func getUrlForRequest(uri: String) -> String {
    let path = NSHomeDirectory() + "/Documents/Setup.plist"
    let plist = NSMutableDictionary(contentsOfFile: path)
    let httpServer = plist!["HttpServer"] as! String
    let httpPort = plist!["HttpPort"] as! String
    let url = "http://\(httpServer):\(httpPort)/\(uri)"
    
    return url
}

func getMQTT_IP() -> String {
    let path = NSHomeDirectory() + "/Documents/Setup.plist"
    let plist = NSMutableDictionary(contentsOfFile: path)
    let mqttIP = plist!["MQTTBrokerIP"] as! String
    
    return mqttIP
}

func getMQTT_Port() -> UInt32 {
    let path = NSHomeDirectory() + "/Documents/Setup.plist"
    let plist = NSMutableDictionary(contentsOfFile: path)
    let mqttPort = plist!["MQTTBrokerPort"] as! String
    
    return UInt32(mqttPort)!
}

func getMQTTPublishTopic(device_id: String) -> String {
    let topic:String = "/IEW/BLEGateway/\(device_id)/ReplyData"
    
    return topic
}
