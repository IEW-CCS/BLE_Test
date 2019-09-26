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
    let pieDataArray = [[28, 12, 3],
                        [124, 56, 90],
                        [78, 54, 128],
                        [32, 49, 113],
                        [120, 345, 789],
                        [233, 333, 433],
                        [50, 111, 23],
                        [18, 20, 33],
                        [3, 4, 5]]
    var normalizeArray = [[Double]]()
    
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var categoryView: UICollectionView!
    
    @IBOutlet weak var txtRun: UILabel!
    @IBOutlet weak var txtDown: UILabel!
    @IBOutlet weak var txtIdle: UILabel!
    
    private var previousSelectedIndex:Int = 0
    private var currentSelectedIndex: Int = 0
    private var selectedSliceIndex: Int = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.contentView.layer.cornerRadius = CELL_CORNER_RADIUS
        self.contentView.layer.backgroundColor = UIColor.clear.cgColor
        categoryView.register(BasicCollectionViewCell.self, forCellWithReuseIdentifier: "CategoryView")
        categoryView.dataSource = self
        categoryView.delegate = self

        pieChart.delegate = self
        
        configPieChart()
        
        if !categoryArray.isEmpty {
            normalizeData()
            setupChartData(cate_index: self.previousSelectedIndex)
        }
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
    
    func setupChartData(cate_index: Int) {
        var dataEntries: [PieChartDataEntry] = []
        
        for index in 0...pieDataArray[cate_index].count - 1 {
            let entry = PieChartDataEntry(value: Double(pieDataArray[cate_index][index]))
            entry.data = Int()
            entry.data = index
            dataEntries.append(entry)
        }
        
        let set = PieChartDataSet(entries: dataEntries, label: "Status Summary")
        set.drawIconsEnabled = false
        set.sliceSpace = 4

        set.colors = [STATUS_RUN_COLOR, STATUS_DOWN_COLOR, STATUS_IDLE_COLOR]
        let data = PieChartData(dataSet: set)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .decimal
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        //pFormatter.percentSymbol = " %"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        data.setValueFont(.systemFont(ofSize: 16, weight: .light))
        data.setValueTextColor(.black)
        
        pieChart.data = data
        pieChart.highlightValues(nil)
        pieChart.animate(xAxisDuration: 1.0, easingOption: .easeOutBack)
        setStatusText()
    }
    
    private func setStatusText() {
        txtRun.text = "RUN:     " + String(format: "%.1f", arguments: [(self.normalizeArray[self.currentSelectedIndex][0])*100]) + "%"
        txtDown.text = "DOWN: " + String(format: "%.1f", arguments: [(self.normalizeArray[self.currentSelectedIndex][1])*100]) + "%"
        txtIdle.text = "IDLE:     " + String(format: "%.1f", arguments: [(self.normalizeArray[self.currentSelectedIndex][2])*100]) + "%"
    }
    
    private func normalizeData() {
        var tmp = [Double]()
        var sum:Int = 0
        
        if !self.pieDataArray.isEmpty {
            for index in 0...self.pieDataArray.count - 1 {
                tmp.removeAll()
                sum = 0
                for i in 0...self.pieDataArray[index].count - 1 {
                    sum += self.pieDataArray[index][i]
                }
                print("pieDataArray[\(index)] sum = \(sum)")
                
                for j in 0...self.pieDataArray[index].count - 1 {
                    tmp.append(Double(self.pieDataArray[index][j])/Double(sum))
                }
                self.normalizeArray.append(tmp)
            }
        }
    }
    
    private func animateStatusText(index: Int) {
        
    }
}

extension DashboardStatusSummaryCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryView", for: indexPath) as! BasicCollectionViewCell
        cell.setText(text: self.categoryArray[indexPath.row])
        if indexPath.row == self.previousSelectedIndex {
            cell.selected()
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categoryArray.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAt indexPath.row = \(indexPath.row)")
        let cellSelected = collectionView.cellForItem(at: indexPath) as! BasicCollectionViewCell
        cellSelected.selected()
        self.currentSelectedIndex = indexPath.row
        setupChartData(cate_index: indexPath.row)
        
        if indexPath.row != self.previousSelectedIndex {
            let prevIndexPath = IndexPath(row: self.previousSelectedIndex, section: indexPath.section)
            let cellUnSelected = collectionView.cellForItem(at: prevIndexPath) as! BasicCollectionViewCell
            cellUnSelected.unselected()
            
            self.previousSelectedIndex = indexPath.row
        }
    }
}

extension DashboardStatusSummaryCell: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        self.selectedSliceIndex = entry.data as! Int
        print("self.selectedSliceIndex = \(self.selectedSliceIndex )")

        animateStatusText(index: self.selectedSliceIndex)
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        print("None of the slice selected")
        self.selectedSliceIndex = -1
        
        animateStatusText(index: self.selectedSliceIndex)
    }
}
