//
//  BottomSheetViewController.swift
//  NestedScrollView
//
//  Created by ugur on 12.08.2018.
//  Copyright © 2018 me. All rights reserved.
//

import UIKit

enum SheetLevel{
    case top, bottom, middle
}

protocol BottomSheetDelegate {
    func updateBottomSheet(frame: CGRect)
}

class BottomSheetViewController: UIViewController{

    @IBOutlet var panView: UIView!
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var collectionView: UICollectionView! //header view
    
    var lastY: CGFloat = 0
    var pan: UIPanGestureRecognizer!
    
    var bottomSheetDelegate: BottomSheetDelegate?
    var parentView: UIView!
    
    var initalFrame: CGRect!
    var topY: CGFloat = 80 //change this in viewWillAppear for top position
    var middleY: CGFloat = 400 //change this in viewWillAppear to decide if animate to top or bottom
    var bottomY: CGFloat = 600 //no need to change this
    let bottomOffset: CGFloat = 64 //sheet height on bottom position
    var lastLevel: SheetLevel = .middle //choose inital position of the sheet
    
    var disableTableScroll = false
    
    //hack panOffset To prevent jump when goes from top to down
    var panOffset: CGFloat = 0
    var applyPanOffset = false
    
    //tableview variables
    var listItems: [Any] = []
    var headerItems: [Any] = []
    
    let headerArray = ["GatewayID", "DeviceID", "Type", "Virtual", "PLC IP", "PLC Port", "Status", "IOT Status", "HB Status", "Location", "EDC Time", "HB Time", "Alarm Code", "Alarm App", "Message", "Alarm Time"]
    var infoArray = [String]()
    var received_device_id: String = ""
    var device_detail: WebResponseDeviceDetail?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        self.panView.addGestureRecognizer(pan)

        self.tableView.panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(handleTap(_:)))
        tap.delegate = self
        tableView.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.receiveQueryNotify(_:)),
            name: NSNotification.Name(rawValue: "BottomSheetQueryDetail"),
            object: nil
        )


    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initalFrame = UIScreen.main.bounds
        self.topY = round(initalFrame.height * 0.05)
        self.middleY = initalFrame.height * 0.6
        self.bottomY = initalFrame.height - bottomOffset
        self.lastY = self.middleY
        
        bottomSheetDelegate?.updateBottomSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: self.middleY))
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == tableView else {return}

        if (self.parentView.frame.minY > topY){
            self.tableView.contentOffset.y = 0
        }
    }


    //this stops unintended tableview scrolling while animating to top
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard scrollView == tableView else {return}

        if disableTableScroll{
            targetContentOffset.pointee = scrollView.contentOffset
            disableTableScroll = false
        }
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer){
        let p = recognizer.location(in: self.tableView)
        let index = tableView.indexPathForRow(at: p)
        //WARNING: calling selectRow doesn't trigger tableView didselect delegate. So handle selected row here.
        //You can remove this line if you dont want to force select the cell
        tableView.selectRow(at: index, animated: false, scrollPosition: .none)
    }//Bug fix #5 end
    
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer){

        let dy = recognizer.translation(in: self.parentView).y
        switch recognizer.state {
        case .began:
            applyPanOffset = (self.tableView.contentOffset.y > 0)
        case .changed:
            if self.tableView.contentOffset.y > 0{
                panOffset = dy
                return
            }
            
            if self.tableView.contentOffset.y <= 0{
                if !applyPanOffset{panOffset = 0}
                let maxY = max(topY, lastY + dy - panOffset)
                let y = min(bottomY, maxY)
                //                self.panView.frame = self.initalFrame.offsetBy(dx: 0, dy: y)
                bottomSheetDelegate?.updateBottomSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: y))
            }
            
            if self.parentView.frame.minY > topY{
                self.tableView.contentOffset.y = 0
            }
        case .failed, .ended, .cancelled:
            panOffset = 0
            

            if (self.tableView.contentOffset.y > 0){
                return
            }
            
            self.panView.isUserInteractionEnabled = false
            
            self.disableTableScroll = self.lastLevel != .top
            
            self.lastY = self.parentView.frame.minY
            self.lastLevel = self.nextLevel(recognizer: recognizer)
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.9, options: .curveEaseOut, animations: {
                
                switch self.lastLevel{
                case .top:
                    //                    self.panView.frame = self.initalFrame.offsetBy(dx: 0, dy: self.topY)
                    self.bottomSheetDelegate?.updateBottomSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: self.topY))
                    self.tableView.contentInset.bottom = 50
                case .middle:
                    //                    self.panView.frame = self.initalFrame.offsetBy(dx: 0, dy: self.middleY)
                    self.bottomSheetDelegate?.updateBottomSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: self.middleY))
                case .bottom:
                    //                    self.panView.frame = self.initalFrame.offsetBy(dx: 0, dy: self.bottomY)
                    self.bottomSheetDelegate?.updateBottomSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: self.bottomY))
                }
                
            }) { (_) in
                self.panView.isUserInteractionEnabled = true
                self.lastY = self.parentView.frame.minY
            }
        default:
            break
        }
    }
    
    func nextLevel(recognizer: UIPanGestureRecognizer) -> SheetLevel{
      let y = self.lastY
        let velY = recognizer.velocity(in: self.view).y
        if velY < -200{
            return y > middleY ? .middle : .top
        }else if velY > 200{
            return y < (middleY + 1) ? .middle : .bottom
        }else{
            if y > middleY {
                return (y - middleY) < (bottomY - y) ? .middle : .bottom
            }else{
                return (y - topY) < (middleY - y) ? .top : .middle
            }
        }
    }
    
    @objc func receiveQueryNotify(_ notification: Notification) {
        if let device_id = notification.object as? String {
            print("BottomSheetViewController Receive device query notification, device is \(device_id)")
            self.received_device_id = device_id
            requestDeviceDetail(device_id: device_id)
       }
    }

    func requestDeviceDetail(device_id: String) {
        let sessionConf = URLSessionConfiguration.default
        sessionConf.timeoutIntervalForRequest = HTTP_REQUEST_TIMEOUT
        sessionConf.timeoutIntervalForResource = HTTP_REQUEST_TIMEOUT
        let sessionHttp = URLSession(configuration: sessionConf)
        //let sessionHttp = URLSession(configuration: .default)
        let url = getUrlForRequest(uri: "CCS_Device_Detail" + "/\(device_id)")
        
        let UrlRequest = URLRequest(url: URL(string: url)!)
        
        print("requestDeviceDetail")
        let task = sessionHttp.dataTask(with: UrlRequest) {(data, response, error) in
            do {
                let outputStr  = String(data: data!, encoding: String.Encoding.utf8) as String?
                //print("Received device detail data: \(String(describing: outputStr))")
                let jsonData = outputStr!.data(using: String.Encoding.utf8, allowLossyConversion: true)
                let decoder = JSONDecoder()
                self.device_detail = try decoder.decode(WebResponseDeviceDetail.self, from: jsonData!)
                //print("json decoding seems OK!!")
                if self.device_detail != nil {
                    self.prepareDetailData(detail_data: self.device_detail!)
                }
                DispatchQueue.main.async {self.tableView.reloadData()}
            } catch {
                print(error.localizedDescription)
                
                return
            }
        }
        task.resume()
        
        return
    }
    
    func prepareDetailData(detail_data: WebResponseDeviceDetail) {
        self.infoArray = [detail_data.gateway_id, detail_data.device_id, detail_data.device_type, detail_data.virtual_flag, detail_data.plc_ip, detail_data.plc_port, detail_data.device_status, detail_data.iotclient_status, detail_data.hb_status, detail_data.device_location, detail_data.last_edc_time, detail_data.hb_report_time, detail_data.last_alarm_code, detail_data.last_alarm_app, detail_data.last_alarm_message, detail_data.last_alarm_datetime]
    }
}

extension BottomSheetViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberofSections section: Int) -> Int {
        if self.infoArray.isEmpty {
            return 0
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       if self.infoArray.isEmpty {
            print("numberOfRowsInSection returns: 0")
            return 0
        }
        
        return headerArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleTableCell", for: indexPath) as! SimpleTableCell
        
        if !self.infoArray.isEmpty {
            cell.setData(title: self.infoArray[indexPath.row], sub_title: self.headerArray[indexPath.row])
        }
        
        return cell
    }
}

extension BottomSheetViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
