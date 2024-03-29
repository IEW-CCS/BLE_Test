import Foundation
import UIKit

let HTTP_REQUEST_TIMEOUT = 3.0


func getHttpSimulationEnv() -> Bool {
    let path = NSHomeDirectory() + "/Documents/Setup.plist"
    let plist = NSMutableDictionary(contentsOfFile: path)
   
    if(plist!["HttpSimulation"] as! Bool == true)
    {
       return true
    }
    else
    {
       return false
    }
}

func getUrlForRequest(uri: String) -> String {
    let path = NSHomeDirectory() + "/Documents/Setup.plist"
    let plist = NSMutableDictionary(contentsOfFile: path)
    let httpServer = plist!["HttpServer"] as! String
    let httpPort = plist!["HttpPort"] as! String
    var url : String
    if(plist!["HttpSimulation"] as! Bool == true)
    {
          // url = "http://\(httpServer):\(httpPort)/RestfulService/simulation/\(uri)
         // let _firebasepath =  "ROOT/GoogleService-Info.plist"
        
        //let _firebasepath = Bundle.main.path(forResource: "GoogleService-Info" , ofType: "plist")!
        //let _firebaseplist = NSMutableDictionary(contentsOfFile: _firebasepath)
        //let _DATABASE_URL2 = _firebaseplist!["DATABASE_URL"] as! String
        
        let _DATABASE_URL = "https://fun2order-11a03.firebaseio.com"
        url = _DATABASE_URL + "/BLE_SIMU/\(uri).json"
    }
    else
    {
           url = "http://\(httpServer):\(httpPort)/RestfulService/\(uri)"
    }
    
    
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

func alert(message: String, title: String )-> UIAlertController {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(OKAction)
    //self.present(alertController, animated: true, completion: nil)
    return alertController
}

func Activityalert( title: String )-> UIAlertController {
    
    let _Activityalert = UIAlertController(title: title, message: "\n\n\n",preferredStyle: .alert)
    let _loadingIndicator =  UIActivityIndicatorView(frame: _Activityalert.view.bounds)
    _loadingIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    _loadingIndicator.color = UIColor.blue
    _loadingIndicator.startAnimating()
    _Activityalert.view.addSubview(_loadingIndicator)
    
    return _Activityalert
}






