//
//  DashboardStatusSummaryCell.swift
//  TestCoreData
//
//  Created by Lo Fang Chou on 2019/9/21.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import Charts

class DashboardStatusSummaryCell: UITableViewCell {
    
    @IBOutlet weak var pieChart: PieChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.contentView.layer.cornerRadius = CELL_CORNER_RADIUS
        self.contentView.layer.backgroundColor = UIColor.clear.cgColor

        configPieChart()
        setupChartData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configPieChart() {
        let l = self.pieChart.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.orientation = .vertical
        l.xEntrySpace = 7
        l.yEntrySpace = 0
        l.yOffset = 0
        pieChart.entryLabelColor = .black
        pieChart.entryLabelFont = .systemFont(ofSize: 12, weight: .light)
        pieChart.animate(xAxisDuration: 1.0, easingOption: .easeOutBack)
    }
    
    func setupChartData() {
        var dataEntries: [PieChartDataEntry] = []
        var entry = PieChartDataEntry(value: 85)
        dataEntries.append(entry)
        entry = PieChartDataEntry(value: 5)
        dataEntries.append(entry)
        entry = PieChartDataEntry(value: 10)
        dataEntries.append(entry)
        
        let set = PieChartDataSet(entries: dataEntries, label: "Status Summary")
        set.drawIconsEnabled = false
        set.sliceSpace = 4
        
        set.colors = ChartColorTemplates.vordiplom()
            + ChartColorTemplates.joyful()
            + ChartColorTemplates.colorful()
            + ChartColorTemplates.liberty()
            + ChartColorTemplates.pastel()
            + [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]
        
        let data = PieChartData(dataSet: set)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        data.setValueFont(.systemFont(ofSize: 11, weight: .light))
        data.setValueTextColor(.black)
        
        pieChart.data = data
        pieChart.highlightValues(nil)    }
}
