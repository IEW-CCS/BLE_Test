import Foundation

func getUrlForRequest(uri: String) -> String {
    let path = NSHomeDirectory() + "/Documents/Setup.plist"
    let plist = NSMutableDictionary(contentsOfFile: path)
    let httpServer = plist!["HttpServer"] as! String
    let httpPort = plist!["HttpPort"] as! String
    let url = "http://\(httpServer):\(httpPort)/RestfulService/\(uri)"
    
    return url
}
