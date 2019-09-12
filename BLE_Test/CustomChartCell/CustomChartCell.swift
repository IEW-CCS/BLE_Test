//
//  CustomChartCell.swift
//  Charts-LineChart
//
//  Created by Satnam Sync on 5/24/18.
//  Copyright © 2018 Satnam Sync. All rights reserved.
//

import UIKit
import Charts

class CustomChartCell: UITableViewCell {
    
    @IBOutlet weak var chtChart: LineChartView!
    var yValues  =  [Double]()
    var xValues = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.chtChart.gridBackgroundColor = NSUIColor.white
        self.chtChart.rightAxis.enabled = false
        self.chtChart.rightAxis.drawAxisLineEnabled = true
        
        //   self.chtChart.xAxis.axisMinimum = 0.0
        self.chtChart.xAxis.drawGridLinesEnabled = false
        self.chtChart.xAxis.axisLineColor = UIColor.clear
        self.chtChart.xAxis.labelFont = UIFont(name: "AvenirNext-Regular", size: 12.0)!
        self.chtChart.xAxis.labelTextColor = UIColor(red: 20/255, green: 34/255, blue: 60/255, alpha: 1.0)
        self.chtChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        self.chtChart.xAxis.granularityEnabled = true
        // self.chtChart.xAxis.axisMaximum = 2
        // self.chtChart.xAxis.axisMinimum = 2
        self.chtChart.xAxis.spaceMin = 10
        self.chtChart.xAxis.spaceMax = 2
        
        self.chtChart.leftAxis.enabled = true
        self.chtChart.leftAxis.drawAxisLineEnabled = false
        self.chtChart.leftAxis.labelFont = UIFont(name: "AvenirNext-Medium", size: 14.0)!
        self.chtChart.leftAxis.labelTextColor = UIColor(red: 92/255, green: 92/255, blue: 92/255, alpha: 1.0)
        self.chtChart.leftAxis.gridColor = NSUIColor.black.withAlphaComponent(0.3)
        self.chtChart.leftAxis.labelPosition = YAxis.LabelPosition.insideChart
        self.chtChart.leftAxis.yOffset = -8
        
        
        self.chtChart.setViewPortOffsets(left: 0, top: 20, right: 0, bottom: 20)
        
        
        self.chtChart.backgroundColor = .lightGray
        self.chtChart.translatesAutoresizingMaskIntoConstraints = false
        self.chtChart.legend.enabled = false
        
        self.chtChart.chartDescription?.enabled = false
        self.chtChart.dragEnabled = true
        self.chtChart.setScaleEnabled(true)
        self.chtChart.pinchZoomEnabled = true
        
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        chtChart.noDataText = "You need to provide data for the chart."
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i)+0.5, y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(entries: dataEntries, label: "")
        let chartData = LineChartData(dataSets: [chartDataSet])
        
        
        chartDataSet.colors = [NSUIColor(red: 239/255, green: 75/255, blue: 94/255, alpha: 1.0)] //Sets the colour to blue
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.lineWidth = 2
        chartDataSet.drawValuesEnabled = false
        
        chartDataSet.fillColor = UIColor.red
        chartDataSet.drawFilledEnabled = true
        
        chtChart.data = chartData
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
