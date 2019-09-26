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
    //Test Data
    let categoryArray = ["1F", "2F", "3F", "4F", "5F", "6F", "7F", "8F", "9F"]
    let pieDataArray = [[23.1, 18.5, 32.9],
                        [124.2, 56.8, 90.9],
                        [78.9, 54.3, 128.0],
                        [32.8, 49.8, 113.2],
                        [120.4, 345.2, 789.1],
                        [233.4, 333.4, 433.4],
                        [50.2, 111.3, 23.5],
                        [18.9, 20.8, 33.3],
                        [3.0, 4.0, 5.0]]
    
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var categoryView: UICollectionView!
    
    private var previousSelectedIndex:Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.contentView.layer.cornerRadius = CELL_CORNER_RADIUS
        self.contentView.layer.backgroundColor = UIColor.clear.cgColor
        categoryView.register(BasicCollectionViewCell.self, forCellWithReuseIdentifier: "CategoryView")
        categoryView.dataSource = self
        categoryView.delegate = self

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

extension DashboardStatusSummaryCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryView", for: indexPath) as! BasicCollectionViewCell
        cell.setText(text: self.categoryArray[indexPath.row])
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categoryArray.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAt indexPath.row = \(indexPath.row)")
        
    }
}
