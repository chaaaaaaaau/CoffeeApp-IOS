//
//  CoffeeItemViewController.swift
//  CoffeeAppIOS
//
//  Created by Chau Sam on 7/8/2019.
//  Copyright © 2019 Chau Sam. All rights reserved.
//

import UIKit
import Charts

// showing each detail of selected record view controller

struct cellData {
    var index = Int()
    var opened = Bool()
    var title = String()
  //  var s = String()
    var sectionData = [String]()
}

class CoffeeItemViewController: UITableViewController {
    
    //var coffeeIdPassed:Int64 = 0
    // boolean for selecting corresponding table cell for detail representation
    //var showChart = false
    //var currentIndex = 0;
    
    // TastePassed
    var fragrancePassed: Double = 0
    var flavorPassed: Double = 0
    var aftertastePassed: Double = 0
    var acidityPassed: Double = 0
    var bodyPassed: Double = 0
    var balancePassed: Double = 0
    var sweetnessPassed: Double = 0
    var cleanCupPassed: Double = 0
    var uniformityPassed: Double = 0
    var overallPassed: Double = 0 // can delete
    
    //chart data passed (as String)
    var dataStrTempPassed: String = ""
    var dataStrInVolPassed: String = ""
    var dataStrOutVolPassed: String = ""
    
    var lineChtEntryT = [ChartDataEntry]() // Used to store X, Y coordinates
    var lineChtEntryI = [ChartDataEntry]()
    var lineChtEntryO = [ChartDataEntry]()
    var lineT = LineChartDataSet()  // A Line Contains a set of X Y Coordinates
    var lineI = LineChartDataSet()
    var lineO = LineChartDataSet()
    var data = LineChartData() // Contains a set of Line
    
    var dataStrPouringPassed: String = ""
    
    // ReportPassed
    var totalTimeSpentPassed: String = ""
    var initBloomTempPassed: String = ""
    var initBrewTempPassed: String = ""
    var finalBrewTempPassed: String = ""
    var avgTempPassed: String = ""
    var totalWaterInfusedPassed: String = ""
    var totalCoffeeProducedPassed: String = ""
    var numOfPourPassed: String = ""
    
    var tableViewData = [cellData(index: 0, opened: true, title: "Chart",  sectionData: [""]),
                         cellData(index: 1,opened: false, title: "Report", sectionData: ["Total Time Spent", "Initial Blooming Temp", "Initial Brewing Temp", "Final Brewing Temp", "Average Temp", "Total Water Infused", "Total Coffee Produced", "Number of Pouring"]),
                         cellData(index: 2, opened: false, title: "Pouring Details", sectionData: [""]),
                         cellData(index: 3, opened: false, title: "Rating", sectionData: ["Fragrance", "Flavor", "Aftertaste", "Acidity", "Body", "Balance", "Sweetness", "Clean Cup", "Uniformity", "Comment"])]
    
    var dataArrTempX = Array<Double>()
    var dataArrTempY = Array<Double>()
    var dataArrInVolX = Array<Double>()
    var dataArrInVolY = Array<Double>()
    var dataArrOutVolX = Array<Double>()
    var dataArrOutVolY = Array<Double>()
    
    var dataArrPouringCount = Array<String>()
    var dataArrPouringTimeSpent = Array<String>()
    var dataArrPouringWaterInfused = Array<String>()
    var dataArrPouringSpeed = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableView.estimatedRowHeight = 100
        //self.tableView.rowHeight = UITableView
        // Do any additional setup after loading the view.
        print(fragrancePassed)
        
        let dataArrTemp = dataStrTempPassed.components(separatedBy: ";")
        for i in 0...dataArrTemp.count - 1 {
            let arr = dataArrTemp[i].components(separatedBy: ",")
            dataArrTempX.append(Double(arr[0])!)
            dataArrTempY.append(Double(arr[1])!)
        }
        
        let dataArrInVol = dataStrInVolPassed.components(separatedBy: ";")
        for i in 0...dataArrInVol.count - 1 {
            let arr = dataArrInVol[i].components(separatedBy: ",")
            dataArrInVolX.append(Double(arr[0])!)
            dataArrInVolY.append(Double(arr[1])!)
        }
        
        let dataArrOutVol = dataStrOutVolPassed.components(separatedBy: ";")
        for i in 0...dataArrOutVol.count - 1 {
            let arr = dataArrOutVol[i].components(separatedBy: ",")
            dataArrOutVolX.append(Double(arr[0])!)
            dataArrOutVolY.append(Double(arr[1])!)
        }
        
        let dataArrPouring = dataStrPouringPassed.components(separatedBy: ";")
        for i in 0...dataArrPouring.count - 1 {
            let arr = dataArrPouring[i].components(separatedBy: ",")
            dataArrPouringCount.append(arr[0])
            dataArrPouringTimeSpent.append(arr[1])
            dataArrPouringWaterInfused.append(arr[2])
            dataArrPouringSpeed.append(arr[3])
            
        }
       
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableViewData[section].opened == true {
            return tableViewData[section].sectionData.count + 1 // +1 for title cell
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView:UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dataIndex = indexPath.row - 1
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TitleItem") else {
                return UITableViewCell()
            }
            
            let cellTitle = cell.viewWithTag(4000) as? UILabel
            cellTitle?.text = tableViewData[indexPath.section].title
           
            return cell
        } else { // use different cell identifier if needed
            if tableViewData[indexPath.section].index == 0 && indexPath.row == 1{
            //if showChart == true {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChartItem") else {
                    return UITableViewCell()
                }

                let chart = cell.viewWithTag(5001) as? LineChartView
                chart?.clear()
                for i in 0...dataArrTempX.count - 1 {
                    lineChtEntryT.append(ChartDataEntry(x:dataArrTempX[i], y:dataArrTempY[i]))
                }
                
                for i in 0...dataArrInVolX.count - 1 {
                    lineChtEntryI.append(ChartDataEntry(x:dataArrInVolX[i], y:dataArrInVolY[i]))
                }
                
                for i in 0...dataArrOutVolX.count - 1 {
                    lineChtEntryO.append(ChartDataEntry(x:dataArrOutVolX[i], y:dataArrOutVolY[i]))
                }
                
                lineT = LineChartDataSet(entries: lineChtEntryT, label: "refTemp")
                lineI = LineChartDataSet(entries: lineChtEntryI, label: "refInVol")
                lineO = LineChartDataSet(entries: lineChtEntryO, label: "refOutVol")
                
                lineT.colors = [NSUIColor.init(red: 255/255.0, green: 111/255.0, blue: 155/255.0, alpha: 1.0)]
                lineT.circleRadius = 2
                lineT.circleColors = [NSUIColor.init(red: 255/255.0, green: 111/255.0, blue: 155/255.0, alpha: 1.0)]
                lineI.colors = [NSUIColor.init(red: 159/255.0, green: 111/255.0, blue: 255/255.0, alpha: 1.0)]
                lineI.circleRadius = 2
                lineI.circleColors = [NSUIColor.init(red: 159/255.0, green: 111/255.0, blue: 255/255.0, alpha: 1.0)]
                lineO.colors = [NSUIColor.init(red: 112/255.0, green: 194/255.0, blue: 255/255.0, alpha: 1.0)]
                lineO.circleRadius = 2
                lineO.circleColors = [NSUIColor.init(red: 112/255.0, green: 194/255.0, blue: 255/255.0, alpha: 1.0)]
                
                data = LineChartData()
                data.addDataSet(lineT)
                data.addDataSet(lineI)
                data.addDataSet(lineO)
                chart?.gridBackgroundColor = NSUIColor.lightGray
                chart?.data = data
                //chart?.setVisibleXRangeMinimum(15)
                
               // let ref = cell.viewWithTag(5002) as? UIButton
                
                print("chart created")
                return cell
            }
            else if tableViewData[indexPath.section].index == 2 && indexPath.row >= 1{
                    //if showChart == true {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "PourItem2") else {
                        return UITableViewCell()
                    }
                    
                    let lblPCount = cell.viewWithTag(6000) as? UILabel
                    let lblPTime = cell.viewWithTag(6001) as? UILabel
                    let lblPWater = cell.viewWithTag(6002) as? UILabel
                    let lblPSpeed = cell.viewWithTag(6003) as? UILabel
                
                    lblPCount?.text = dataArrPouringCount[indexPath.row - 1]
                    lblPTime?.text = dataArrPouringTimeSpent[indexPath.row - 1]
                    lblPWater?.text = dataArrPouringWaterInfused[indexPath.row - 1]
                    lblPSpeed?.text = dataArrPouringSpeed[indexPath.row - 1]
                
                    return cell
                }
            else {
    
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecordItem") else {
                return UITableViewCell()
            }
            //cell.textLabel?.text = tableViewData[indexPath.section].sectionData[dataIndex]
            let cellTitle = cell.viewWithTag(4001) as? UILabel
            cellTitle?.text = tableViewData[indexPath.section].sectionData[dataIndex]
            let cellValue = cell.viewWithTag(4002) as? UILabel
            
            switch(cellTitle?.text) {
            
                case "Total Time Spent": cellValue?.text = String(totalTimeSpentPassed)
                case "Initial Blooming Temp": cellValue?.text = String(initBloomTempPassed)
                case "Initial Brewing Temp": cellValue?.text = String(initBrewTempPassed)
                case "Final Brewing Temp": cellValue?.text = String(finalBrewTempPassed)
                case "Average Temp": cellValue?.text = String(avgTempPassed)
                case "Total Water Infused": cellValue?.text = String(totalWaterInfusedPassed)
                case "Total Coffee Produced": cellValue?.text = String(totalCoffeeProducedPassed)
                case "Number of Pouring": cellValue?.text = String(numOfPourPassed)
                
                case "Fragrance": cellValue?.text = String(fragrancePassed)
                case "Flavor": cellValue?.text = String(flavorPassed)
                case "Aftertaste": cellValue?.text = String(aftertastePassed)
                case "Acidity": cellValue?.text = String(acidityPassed)
                case "Body": cellValue?.text = String(bodyPassed)
                case "Balance": cellValue?.text = String(balancePassed)
                case "Sweetness": cellValue?.text = String(sweetnessPassed)
                case "Clean Cup": cellValue?.text = String(cleanCupPassed)
                case "Uniformity": cellValue?.text = String(uniformityPassed)
                case "": print()
                
            
                default: cellValue?.text = "?"
            }
        
            return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableViewData[indexPath.section].opened == true {
            tableViewData[indexPath.section].opened = false
           
            let sections = IndexSet.init(integer: indexPath.section)
            tableView.reloadSections(sections, with: .none) // with -> animation
            
            
        } else {
            tableViewData[indexPath.section].opened = true
            let sections = IndexSet.init(integer: indexPath.section)
            tableView.reloadSections(sections, with: .none)
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableViewData[indexPath.section].opened && tableViewData[indexPath.section].index == 0 { // this cond for tableViewData attribute. To make the below indexPath.row unique (Just need 1 300 height)
            if indexPath.row == 1  {
                return 300 // hardcode. How abt other screen
            }
        }
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { // Is this func useful? (estimated)
        if tableViewData[0].opened && tableViewData[0].index == 0 { // this cond for tableViewData attribute. To make the below indexPath.row unique (Just need 1 300 height)
            if indexPath.row == 1  {
                return 300 // hardcode. How abt other screen
            }
        }
        return UITableView.automaticDimension
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let PourOverViewController = segue.destination as? PourOverViewController
            else {
                return
        }
        // chart details, pass to next scene
        //rateViewController.dataStrTempPassed = dataStrTemp
        PourOverViewController.useRef = true
        PourOverViewController.reflineT = lineT
        PourOverViewController.reflineI = lineI
        PourOverViewController.reflineO = lineO
       
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
