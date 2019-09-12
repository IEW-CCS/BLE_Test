//
//  FunctionCollectionViewController.swift
//  BLE_Test
//
//  Created by Lo Fang Chou on 2019/8/28.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class FunctionCollectionViewController: UICollectionViewController {
    let dataArray = ["Status", "Layout", "Chart", "Alarm", "BLE", "Setup"]
    let imageArray: [UIImage] = [
        UIImage(named: "Status_tmp.png")!,
        UIImage(named: "Layout2.png")!,
        UIImage(named: "Chart2.png")!,
        UIImage(named: "Alarm2.png")!,
        UIImage(named: "CloudBLE2.png")!,
        UIImage(named: "Setup2.png")!
    ]
    
    var cellMarginSize = 5.0
    let alarmIndex = 3
    var isLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
   }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell
        cell.setData(text: self.dataArray[indexPath.row], image: self.imageArray[indexPath.row])
        if indexPath.row == alarmIndex {
            cell.setBadge(badge_number: UIApplication.shared.applicationIconBadgeNumber)
        }
        
        cell.frame.size.width = (CGFloat(UIScreen.main.bounds.size.width) - CGFloat(self.cellMarginSize)*4)/3
        
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }

    /*
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }
    */
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let cell = collectionView.cellForItem(at: indexPath)
        //cell?.layer.borderColor = UIColor.black.cgColor
        //cell?.layer.borderWidth = 1
        
        switch indexPath.row {
        // Display Status View Controller
        case 0:
            let vc = storyboard?.instantiateViewController(withIdentifier: "Status_VC")
            show(vc!, sender: self)
            return
            
        // Display Layout View Controller
        case 1:
            let vc = storyboard?.instantiateViewController(withIdentifier: "Layout_VC")
            show(vc!, sender: self)
            return
            
        // Display Chart View Controller
        case 2:
            let vc = storyboard?.instantiateViewController(withIdentifier: "QueryChart_VC")
            show(vc!, sender: self)
            return
            
        // Display Alarm View Controller
        case 3:
            let vc = storyboard?.instantiateViewController(withIdentifier: "Alarm_VC")
            show(vc!, sender: self)
            return
            
        // Display CloudBLE View Controller
        case 4:
            let vc = storyboard?.instantiateViewController(withIdentifier: "CloudBLE_VC")
            show(vc!, sender: self)
            return
            
        // Display Setup View Controller
        case 5:
            let vc = storyboard?.instantiateViewController(withIdentifier: "Setup_VC")
            show(vc!, sender: self)
            return
            
            
        default:
            return
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.isLoaded == true {
            //print("FunctionList ViewController: viewWillAppear")
            let index = IndexPath(row: alarmIndex, section: 0)
            let cell = self.collectionView.cellForItem(at: index) as! ItemCell
            cell.setBadge(badge_number: UIApplication.shared.applicationIconBadgeNumber)
        } else {
            print("FunctionList ViewController isLoaded is false, set to true")
            self.isLoaded = true
        }
    }
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
