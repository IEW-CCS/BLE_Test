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
    //var dataSets: [LineChartDataSet] = []
    
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
        self.chtChart.xAxis.spaceMin = 5
        self.chtChart.xAxis.spaceMax = 2
        
        self.chtChart.leftAxis.enabled = true
        self.chtChart.leftAxis.drawAxisLineEnabled = false
        self.chtChart.leftAxis.labelFont = UIFont(name: "AvenirNext-Medium", size: 14.0)!
        self.chtChart.leftAxis.labelTextColor = UIColor(red: 92/255, green: 92/255, blue: 92/255, alpha: 1.0)
        self.chtChart.leftAxis.gridColor = NSUIColor.black.withAlphaComponent(0.3)
        self.chtChart.leftAxis.labelPosition = YAxis.LabelPosition.insideChart
        self.chtChart.leftAxis.yOffset = -8
        
        self.chtChart.setViewPortOffsets(left: 0, top: 20, right: 0, bottom: 20)
        
        //self.chtChart.backgroundColor = .lightGray
        self.chtChart.backgroundColor = UIColor(red: 34/255, green: 234/255, blue: 157/255, alpha: 0.2)
        self.chtChart.translatesAutoresizingMaskIntoConstraints = false
        //self.chtChart.legend.enabled = false
        let l = self.chtChart.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.orientation = .vertical
        l.drawInside = false
        
        self.chtChart.chartDescription?.enabled = false
        self.chtChart.dragEnabled = true
        self.chtChart.setScaleEnabled(true)
        self.chtChart.pinchZoomEnabled = true
        
        self.chtChart.animate(xAxisDuration: 0.2)
    }
    
    func setChartData(value: [[String]], data_label: [String]) {
        var dataEntries: [ChartDataEntry] = []
        var dataSets: [LineChartDataSet] = []
        let colors = ChartColorTemplates.colorful()[0...(value.count - 1)]

        for i in 0...(value.count - 1 ){
            dataEntries.removeAll()
            for j in 0...(value[i].count - 1) {
                let dataEntry = ChartDataEntry(x: Double(j), y: Double(value[i][j])!)
                dataEntries.append(dataEntry)
            }
            let chartDataSet = LineChartDataSet(entries: dataEntries, label: data_label[i])
            chartDataSet.lineWidth = 2.5
            chartDataSet.circleRadius = 4
            chartDataSet.circleHoleRadius = 2
            let color = colors[i % colors.count]
            chartDataSet.setColor(color)
            chartDataSet.setCircleColor(color)

            dataSets.append(chartDataSet)
        }
        
        let data = LineChartData(dataSets: dataSets)
        
        data.setValueFont(.systemFont(ofSize: 7, weight: .light))
        chtChart.data = data
    }

    func setChartDataNil() {
        chtChart.data = nil
    }
    
    func setDataSetDisplay(index: Int, display_flag: Bool) {
        //self.dataSets[index].drawValuesEnabled = display_flag
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
