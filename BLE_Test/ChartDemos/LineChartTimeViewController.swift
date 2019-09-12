//
//  LineChartTimeViewController.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import UIKit
import Charts

class LineChartTimeViewController: DemoBaseViewController {
    
    @IBOutlet var chartView: LineChartView!
    @IBOutlet weak var QueryButton: UIButton!
    @IBOutlet weak var DTPickerView: UIDatePicker!
    @IBOutlet var DatetimePickView: UIView!
    
    @IBOutlet weak var Sel_Start_Button: UIButton!
    @IBOutlet weak var Sel_End_Button: UIButton!
    
    private var _Sel_Start_Button: Bool = true
    private var _Select_Start_Time :String!
    private var _Select_End_Time: String!
    private var _Query_DeviceID : String!
    private var _Query_ChartName : String!
    
    //--------- Alert --------
    private  let _myalert = UIAlertController(title: "Loading...",message: "\n\n\n",preferredStyle: .alert)

    private var ChartQuery: WebResponseChartInfoReply?
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        //--- Chris 處理下拉式窗
        QueryButton.layer.cornerRadius = 5
        view.addSubview(DatetimePickView)
    
        // Disable Auto Resizeing
        DatetimePickView.translatesAutoresizingMaskIntoConstraints = false
        DatetimePickView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        DatetimePickView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        DatetimePickView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        let DatetimePCV_Hide = DatetimePickView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 200)
        DatetimePCV_Hide.identifier = "DatetimePickerView"
        DatetimePCV_Hide.isActive = true
        DatetimePickView.layer.cornerRadius = 15
        
        super.viewWillAppear(animated)
        
        
        //------- Initial Date time ----
        
        let Displayformatter = DateFormatter()
        Displayformatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let Jsonformatter = DateFormatter()
        Jsonformatter.dateFormat = "yyyyMMddHHmmss"
        
        
        let currentDateTime = Date()
        _Select_End_Time = Jsonformatter.string(from: currentDateTime)
        Sel_End_Button.setTitle(Displayformatter.string(from: currentDateTime),for: UIControl.State.normal)
        
        let modifiedDate = Calendar.current.date(byAdding: .hour, value: -1, to: currentDateTime)!
        _Select_Start_Time = Jsonformatter.string(from: modifiedDate)
        Sel_Start_Button.setTitle(Displayformatter.string(from: modifiedDate),for: UIControl.State.normal)
        
        //---------Setup Device ID and Item ------
        _Query_DeviceID = AppDelegate.select_DeviceID
        _Query_ChartName = AppDelegate.select_EDCItem
        
        let url = getUrlForRequest(uri: "CCS_Chart/Info")
        let postJSON = ["device_id": _Query_DeviceID,"chart_name":_Query_ChartName, "get_count":"100", "start_time": _Select_Start_Time, "end_time" : _Select_End_Time]
        requestWithJSONBody(urlString: url, parameters: postJSON as [String : Any], completion: { (data) in
            DispatchQueue.main.async {
                self.processData(data: data)
            }
        })
        
        
        let _loadingIndicator =  UIActivityIndicatorView(frame: _myalert.view.bounds)
        _loadingIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _loadingIndicator.color = UIColor.blue
        _loadingIndicator.startAnimating()
        
        _myalert.view.addSubview(_loadingIndicator)
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "Time Line Chart"
       
        chartView.delegate = self
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = false
        chartView.highlightPerDragEnabled = true
        chartView.backgroundColor = .white
        chartView.legend.enabled = false
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .topInside
        xAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
        xAxis.labelTextColor = UIColor(red: 255/255, green: 192/255, blue: 56/255, alpha: 1)
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = true
        xAxis.centerAxisLabelsEnabled = true
        xAxis.granularity = 100   // default 3600
        xAxis.valueFormatter = DateValueFormatter()
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelPosition = .insideChart
        leftAxis.labelFont = .systemFont(ofSize: 12, weight: .light)
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = true
        //leftAxis.axisMinimum = 0
        //leftAxis.axisMaximum = 20000
        leftAxis.yOffset = -9
        leftAxis.labelTextColor = UIColor(red: 255/255, green: 192/255, blue: 56/255, alpha: 1)

        chartView.rightAxis.enabled = false
        chartView.legend.form = .line
        self.updateChartData()
        
        chartView.animate(xAxisDuration: 1)
        
    }
    
    override func updateChartData() {
        if self.shouldHideData {
            chartView.data = nil
            return
        }
        
        let url = getUrlForRequest(uri: "CCS_Chart/Info")
        let postJSON = ["device_id": _Query_DeviceID,"chart_name":_Query_ChartName, "get_count":"100", "start_time": _Select_Start_Time, "end_time" : _Select_End_Time]
        requestWithJSONBody(urlString: url, parameters: postJSON as [String : Any], completion: { (data) in
            DispatchQueue.main.async {
                self.processData(data: data)
            }
        })
       // self.setDataCount(100, range: 30)
    }
    
    func setDataCount(_ count: Int, range: UInt32) {
        let now = Date().timeIntervalSince1970
        let hourSeconds: TimeInterval = 3600
        
        let from = now - (Double(count) / 2) * hourSeconds
        let to = now + (Double(count) / 2) * hourSeconds
        
        let dateFormat:DateFormatter = DateFormatter()
        dateFormat.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        
        
        let values = stride(from: from, to: to, by: hourSeconds).map { (x) -> ChartDataEntry in
            let y = arc4random_uniform(range) + 50
            
            //let date:Date = Date(timeIntervalSince1970: x)
            //print("\(dateFormat.string(from: date))")
            return ChartDataEntry(x: x, y: Double(y))
        }
        
        let set1 = LineChartDataSet(entries: values, label: "DataSet 1")
        set1.axisDependency = .left
        set1.setColor(UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1))
        set1.lineWidth = 1.5
        set1.drawCirclesEnabled = false
        set1.drawValuesEnabled = false
        set1.fillAlpha = 0.26
        set1.fillColor = UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)
        set1.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        set1.drawCircleHoleEnabled = false
        
        let data = LineChartData(dataSet: set1)
        data.setValueTextColor(.white)
        data.setValueFont(.systemFont(ofSize: 9, weight: .light))
        
        chartView.data = data
        
    }
    
    @IBAction func Select_Start_Click(_ sender: Any) {
        
        _Sel_Start_Button = true
        DisplayDatetimePickView(true)
     }
        
    @IBAction func Select_End_Click(_ sender: Any) {
        _Sel_Start_Button = false
        DisplayDatetimePickView(true)
    }
    
    @IBAction func DateTime_PV_Done_Click(_ sender: Any) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        if _Sel_Start_Button == true
        {
           Sel_Start_Button.setTitle(formatter.string(from: DTPickerView.date), for: UIControl.State.normal)
        }
        else
        {
           Sel_End_Button.setTitle(formatter.string(from: DTPickerView.date), for: UIControl.State.normal)
        }
        
        DisplayDatetimePickView(false)
        
    }
    func DisplayDatetimePickView(_ show:Bool){
        
        for c in view.constraints
        {
            
            if c.identifier == "DatetimePickerView"
            {
                c.constant = (show) ? -40 : 200
                break
            }
            
        }
        UIView.animate(withDuration: 0.5)
        {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func Query_Btn_Click(_ sender: Any) {
        
        super.present(_myalert, animated : true, completion :nil )
        _Select_Start_Time = convertDateFormatter(date: String( Sel_Start_Button.currentTitle ?? "0"))
        _Select_End_Time = convertDateFormatter(date: String( Sel_End_Button.currentTitle ?? "0"))
        
        let url = getUrlForRequest(uri: "CCS_Chart/Info")
        let postJSON = ["device_id": _Query_DeviceID,"chart_name":_Query_ChartName, "get_count":"100", "start_time": _Select_Start_Time, "end_time" : _Select_End_Time]
        requestWithJSONBody(urlString: url, parameters: postJSON as [String : Any], completion: { (data) in
            DispatchQueue.main.async {
                self.processData(data: data)
                self.presentedViewController?.dismiss(animated: false, completion: nil)
            }
        })
        
        
        //DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {}
        
        
        /*
        let alertController = UIAlertController(
            title: "提示",
            message: "Query Range Start" + "\(String( Sel_Start_Button.currentTitle ?? "0"))" + "End" + "\(String( Sel_End_Button.currentTitle ?? "0"))",
            preferredStyle: .alert)
        
        // 建立[確認]按鈕
        let okAction = UIAlertAction(
            title: "確認",
            style: .default,
            handler: {
                (action: UIAlertAction!) -> Void in
                print("按下確認後，閉包裡的動作")
        })
        alertController.addAction(okAction)
        
        // 顯示提示框
        self.present(
            alertController,
            animated: true,
            completion: nil)
       */
        
        
    }
    
    
    
    private func requestWithJSONBody(urlString: String, parameters: [String: Any], completion: @escaping (Data) -> Void){
        
        let url = URL(string: urlString)!
        var UrlRequest = URLRequest(url: url)
        
        do{
            UrlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions())
        }catch let error{
            print(error)
        }
        UrlRequest.httpMethod = "POST"
        UrlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        fetchedDataByDataTask(from: UrlRequest, completion: completion)
    }
    
    
    
    private func fetchedDataByDataTask(from request: URLRequest, completion: @escaping (Data) -> Void){
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error != nil{
                print(error as Any)
            }else{
                guard let data = data else{return}
                completion(data)
            }
        }
        task.resume()
    }
    
    private func convertDateFormatter(date: String) -> String
    {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"//this your string date format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let date = dateFormatter.date(from: date)
        
        
        dateFormatter.dateFormat = "yyyyMMddHHmmss"///this is what you want to convert format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let timeStamp = dateFormatter.string(from: date!)
        
        return timeStamp
    }
    
    
    private func processData(data: Data){
        
        let outputStr  = String(data: data, encoding: String.Encoding.utf8) as String?
        let jsonData = outputStr!.data(using: String.Encoding.utf8, allowLossyConversion: true)
        let decoder = JSONDecoder()
        
        
        do {
           
            self.ChartQuery = try decoder.decode(WebResponseChartInfoReply.self, from: jsonData!)
            if self.ChartQuery != nil {
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMddhhmmss"
            
                let values = self.ChartQuery?.data_list.map { (Json) -> ChartDataEntry in
                    let someDate = formatter.date(from: Json.X_asix )
               
                    let x = someDate!.timeIntervalSince1970
                    let y = Double( Json.Y_asix)   // Vaule
                    return ChartDataEntry(x: x, y: y! )
                }
                
                let set1 = LineChartDataSet(entries: values, label: "DataSet 1")
                set1.axisDependency = .left
                set1.setColor(UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1))
                set1.lineWidth = 1.5
                set1.drawCirclesEnabled = false
                set1.drawValuesEnabled = false
                set1.fillAlpha = 0.26
                set1.fillColor = UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)
                set1.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
                set1.drawCircleHoleEnabled = false
                
                let data = LineChartData(dataSet: set1)
                data.setValueTextColor(.white)
                data.setValueFont(.systemFont(ofSize: 9, weight: .light))
                
                chartView.data = data
                

                
                
                
            }
            
        } catch {
            print(error.localizedDescription)
            
            return
        }
        
    }
    
}
