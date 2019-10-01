//
//  DashboardDataItemChartCell.swift
//  TestCoreData
//
//  Created by Lo Fang Chou on 2019/9/23.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import Charts

class DashboardDataItemChartCell: UITableViewCell {
    @IBOutlet weak var chartView: CombinedChartView!
    
    @IBOutlet weak var ShadowGradientView: ShadowGradientView!
    
    let lineDataArray = [20, 30, 40, 50, 60, 70, 45, 33, 66, 78, 83, 90, 95, 66, 70, 30, 40, 35, 25,15, 10, 5, 30, 35, 45, 60, 45, 45, 50, 30]
    
    let barDataArray1 = [90, 85, 80, 75, 65, 50, 40, 45, 47, 58, 50, 30, 20, 10, 5, 30, 40, 60, 70,75, 80, 85, 90, 95, 93, 92, 70, 78, 84, 60]

    let barDataArray2 = [85, 80, 75, 70, 60, 45, 35, 40, 40, 50, 45, 25, 15, 5, 5, 25, 35, 55, 65, 70, 72, 78, 82, 80, 81, 76, 60, 70, 75, 55]

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.contentView.layer.cornerRadius = CELL_CORNER_RADIUS
        self.contentView.layer.backgroundColor = UIColor.clear.cgColor

        configCombinedChart()
        setupChartData()
       
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    public func AdjustAutoLayout()
    {
       ShadowGradientView.AdjustAutoLayout()
    }
    
    func configCombinedChart() {
        chartView.chartDescription?.enabled = false
        chartView.drawBarShadowEnabled = false
        chartView.highlightFullBarEnabled = false
        chartView.drawOrder = [DrawOrder.bar.rawValue,
                               DrawOrder.line.rawValue,]
        
        let l = chartView.legend
        l.wordWrapEnabled = true
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false

        let rightAxis = chartView.rightAxis
        rightAxis.axisMinimum = 0
        
        let leftAxis = chartView.leftAxis
        leftAxis.axisMinimum = 0
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bothSided
        xAxis.axisMinimum = 0
        xAxis.granularity = 1
        xAxis.valueFormatter = self as? IAxisValueFormatter
    }
    
    func setupChartData() {
        let data = CombinedChartData()
        data.lineData = generateLineData()
        data.barData = generateBarData()

        chartView.xAxis.axisMaximum = data.xMax + 0.25
        chartView.data = data
    }
    
    func generateLineData() -> LineChartData {
        var entries = [ChartDataEntry]()
        for index in 0...lineDataArray.count - 1 {
            let chartEntry = ChartDataEntry(x: Double(index), y: Double(lineDataArray[index]))
            entries.append(chartEntry)
        }
        
        let set = LineChartDataSet(entries: entries, label: "Line DataSet")
        set.setColor(UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1))
        set.lineWidth = 2.5
        set.setCircleColor(UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1))
        set.circleRadius = 5
        set.circleHoleRadius = 2.5
        set.fillColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
        set.mode = .cubicBezier
        set.drawValuesEnabled = true
        set.valueFont = .systemFont(ofSize: 10)
        set.valueTextColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
        
        set.axisDependency = .left
        
        return LineChartData(dataSet: set)
    }
    
    func generateBarData() -> BarChartData {
        var entries1 = [BarChartDataEntry]()
        var entries2 = [BarChartDataEntry]()
        for index1 in 0...barDataArray1.count - 1 {
            let chartEntry = BarChartDataEntry(x: Double(index1), y: Double(barDataArray1[index1]))
            entries1.append(chartEntry)
        }

        for index2 in 0...barDataArray1.count - 1 {
            let chartEntry = BarChartDataEntry(x: Double(index2), y: Double(barDataArray2[index2]))
            entries2.append(chartEntry)
        }
        
        let set1 = BarChartDataSet(entries: entries1, label: "Bar 1")
        set1.setColor(UIColor(red: 60/255, green: 220/255, blue: 78/255, alpha: 1))
        //set1.valueTextColor = UIColor(red: 60/255, green: 220/255, blue: 78/255, alpha: 1)
        //set1.valueFont = .systemFont(ofSize: 10)
        set1.drawValuesEnabled = false
        set1.axisDependency = .right
        
        let set2 = BarChartDataSet(entries: entries2, label: "")
        set2.stackLabels = ["Stack 1", "Stack 2"]
        set2.colors = [UIColor(red: 61/255, green: 165/255, blue: 255/255, alpha: 1),
                       UIColor(red: 23/255, green: 197/255, blue: 255/255, alpha: 1)
        ]
        //set2.valueTextColor = UIColor(red: 61/255, green: 165/255, blue: 255/255, alpha: 1)
        //set2.valueFont = .systemFont(ofSize: 10)
        set2.drawValuesEnabled = false
        set2.axisDependency = .right
        
        let groupSpace = 0.06
        let barSpace = 0.02 // x2 dataset
        let barWidth = 0.45 // x2 dataset
        // (0.45 + 0.02) * 2 + 0.06 = 1.00 -> interval per "group"
        
        let data = BarChartData(dataSets: [set1, set2])
        data.barWidth = barWidth
        
        // make this BarData object grouped
        data.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
        
        return data
    }
}
