//
//  ResultViewController.swift
//  CoffeeAppIOS
//
//  Created by Chau Sam on 29/6/2019.
//  Copyright © 2019 Chau Sam. All rights reserved.
//

import UIKit

// display calculation view controller (detail analysis)

class ResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayPourPassed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PourItem", for: indexPath)
        
        //cell.textLabel?.text = arrayCoffee[indexPath.row].name
        let pourID = cell.viewWithTag(1000) as? UILabel
        let pourTime = cell.viewWithTag(1001) as? UILabel
        let pourWater = cell.viewWithTag(1002) as? UILabel
        let pourSpeed = cell.viewWithTag(1003) as? UILabel
        //  for indexPath.row in 0..arrayCoffee.count {
        pourID?.text = String(indexPath.row + 1)
        pourTime?.text = arrayPourPassed[indexPath.row].pourTimeStr
        pourWater?.text = arrayPourPassed[indexPath.row].pourInfusedWaterStr
        pourSpeed?.text = arrayPourPassed[indexPath.row].pourSpeedStr
        
        //}
        return cell
    }
    
    
    
    @IBOutlet weak var tblDetailPour: UITableView!
    
    var totalTimePassed: String = ""
    var arrayPourPassed: Array<detailPour> = [detailPour]()
    var initBloomTempPassed: String = ""
    var initBrewTempPassed: String = ""
    var finalBrewTempPassed: String = ""
    var avgTempPassed: String = ""
    var totalWaterInfusedPassed: String = ""
    var coffeeProducedPassed: String = ""
    var numOfPourPassed: String = ""
    
    //chart data passed (as String)
    var dataStrTempPassed: String = ""
    var dataStrInVolPassed: String = ""
    var dataStrOutVolPassed: String = ""
    
    //pouring data to pass (as String)
    var dataStrPouring: String = ""
    
    @IBOutlet weak var lblTotalSpentTime: UILabel!
    @IBOutlet weak var lblInitBloomTemp: UILabel!
    @IBOutlet weak var lblInitBrewTemp: UILabel!
    @IBOutlet weak var lblFinalBrewTemp: UILabel!
    @IBOutlet weak var lblAvgTemp: UILabel!
    @IBOutlet weak var lblTotalWaterInfused: UILabel!
    
    @IBOutlet weak var lblTotalCoffeeProduced: UILabel!
    
    @IBOutlet weak var lblNumOfPour: UILabel!
    
    @IBAction func rateBtn(_ sender: Any) {
    }
    
    @IBAction func rateShareBtn(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTotalSpentTime.text = totalTimePassed
        lblInitBloomTemp.text = initBloomTempPassed
        lblInitBrewTemp.text = initBrewTempPassed
        lblFinalBrewTemp.text = finalBrewTempPassed
        lblAvgTemp.text = avgTempPassed
        lblTotalWaterInfused.text = totalWaterInfusedPassed
        lblTotalCoffeeProduced.text = coffeeProducedPassed
        lblNumOfPour.text = numOfPourPassed
        
        for eachPour in arrayPour {
            
            if dataStrPouring == "" {
                dataStrPouring.append(String(eachPour.pourCount + 1) + "," + eachPour.pourTimeStr + "," + eachPour.pourInfusedWaterStr + "," + eachPour.pourSpeedStr)
            }
            else {
                dataStrPouring.append(";" + String(eachPour.pourCount + 1) + "," + eachPour.pourTimeStr + "," + eachPour.pourInfusedWaterStr + "," + eachPour.pourSpeedStr)
            }
            //print(eachPour.pourCount)
            //print(eachPour.pourTimeStr)
            //print(eachPour.pourInfusedWaterStr)
            //print(eachPour.pourSpeedStr)
        }
        
        
      //  tblDetailPour.delegate = self as! UITableViewDelegate
      //  tblDetailPour.dataSource = self as! UITableViewDataSource
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let rateViewController = segue.destination as? rateViewController
            else {
                return
        }
        // chart details, pass to next scene
        rateViewController.dataStrTempPassed = dataStrTemp
        rateViewController.dataStrInVolPassed = dataStrInVol
        rateViewController.dataStrOutVolPassed = dataStrOutVol
        
        // pour details, pass to next scene
        rateViewController.dataStrPouringPassed = dataStrPouring
        
        // report details, pass to next scene
        rateViewController.totalTimePassed = totalTimePassed
        rateViewController.initBloomTempPassed = initBloomTempPassed
        rateViewController.initBrewTempPassed = initBrewTempPassed
        rateViewController.finalBrewTempPassed = finalBrewTempPassed
        rateViewController.avgTempPassed = avgTempPassed
        rateViewController.totalWaterInfusedPassed = totalWaterInfusedPassed
        rateViewController.coffeeProducedPassed = coffeeProducedPassed
        rateViewController.numOfPourPassed = numOfPourPassed
        
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
