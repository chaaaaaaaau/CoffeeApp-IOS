//
//  recordViewController.swift
//  CoffeeAppIOS
//
//  Created by Chau Sam on 7/7/2019.
//  Copyright © 2019 Chau Sam. All rights reserved.
//

import UIKit
import Cosmos
import SQLite
import SQLite3

//outere database for quick reference and selection

struct coffee {
    var id: Int64
    var name: String
    var type: String
    var rating: Double
}

var arrayCoffee:Array<coffee> = Array()
//var arrayCoffeeTasteFR:Array<coffeeTasteForReference> = Array()

class recordViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        arrayCoffee = [coffee]()
        var newCoffee:coffee = coffee(id: 0,name: "", type: "", rating: 0.0)
    
        if let recordQuery: AnySequence<Row> = RecordEntity.shared.queryAll() {
            for eachRecord in recordQuery {
                newCoffee.id = RecordEntity.shared.getID(record: eachRecord)
                newCoffee.name = RecordEntity.shared.getName(record: eachRecord)
                newCoffee.type = RecordEntity.shared.getType(record: eachRecord)
                newCoffee.rating = RecordEntity.shared.getRating(record: eachRecord)
                arrayCoffee.append(newCoffee)
                
            }
        }

    } // end of viewDidLoad
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayCoffee.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoffeeItem", for: indexPath)
        
        //cell.textLabel?.text = arrayCoffee[indexPath.row].name
        let lblName = cell.viewWithTag(1000) as? UILabel
        let lblType = cell.viewWithTag(1001) as? UILabel
        let rtOverall = cell.viewWithTag(1002) as? CosmosView?
          //  for indexPath.row in 0..arrayCoffee.count {
        lblName!.text = arrayCoffee[indexPath.row].name
        lblType!.text = arrayCoffee[indexPath.row].type
        rtOverall!?.rating = arrayCoffee[indexPath.row].rating
        //}
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let CoffeeItemViewController = segue.destination as? CoffeeItemViewController
            else {
                return
        }
        
        if let indexPath = tableView.indexPathForSelectedRow {
            print(indexPath)
             // CoffeeItemViewController.coffeeIdPassed = arrayCoffee[indexPath.row].id
            
            if let recordQuery: AnySequence<Row> = RecordEntity.shared.queryAll() {
                for eachRecord in recordQuery {
                    
                    if RecordEntity.shared.getID(record: eachRecord) == arrayCoffee[indexPath.row].id { // actually can be done in 1 database. Modify later?
                        CoffeeItemViewController.dataStrTempPassed = RecordEntity.shared.getDataStrTemp(record: eachRecord)
                        CoffeeItemViewController.dataStrInVolPassed = RecordEntity.shared.getDataStrInVol(record: eachRecord)
                        CoffeeItemViewController.dataStrOutVolPassed =
                            RecordEntity.shared.getDataStrOutVol(record: eachRecord)
                        
                        CoffeeItemViewController.dataStrPouringPassed = RecordEntity.shared.getDataStrPouring(record: eachRecord)
                        
                        CoffeeItemViewController.totalTimeSpentPassed =  RecordEntity.shared.getTotalTimeSpent(record: eachRecord)
                        CoffeeItemViewController.initBloomTempPassed =  RecordEntity.shared.getInitBloomTemp(record: eachRecord)
                        CoffeeItemViewController.initBrewTempPassed =  RecordEntity.shared.getInitBrewTemp(record: eachRecord)
                        CoffeeItemViewController.finalBrewTempPassed =  RecordEntity.shared.getFinalBrewTemp(record: eachRecord)
                        CoffeeItemViewController.avgTempPassed =  RecordEntity.shared.getAvgTemp(record: eachRecord)
                        CoffeeItemViewController.totalWaterInfusedPassed =  RecordEntity.shared.getTotalWaterInfused(record: eachRecord)
                        CoffeeItemViewController.totalCoffeeProducedPassed =  RecordEntity.shared.getTotalCoffeeProduced(record: eachRecord)
                        CoffeeItemViewController.numOfPourPassed =  RecordEntity.shared.getNumOfPour(record: eachRecord)
                        
                    } // end of If
                } // end of For loop
            } // end of If let recordQuery
            
          
           if let recordQuery: AnySequence<Row> = RecordTasteEntity.shared.queryAll() {
                for eachRecord in recordQuery {
                    
                    if RecordTasteEntity.shared.getTasteID(record: eachRecord) == arrayCoffee[indexPath.row].id { // actually can be done in 1 database. Modify later?
    
                                CoffeeItemViewController.fragrancePassed =  RecordTasteEntity.shared.getFragranceValue(record: eachRecord)
                                CoffeeItemViewController.flavorPassed = RecordTasteEntity.shared.getFlavorValue(record: eachRecord)
                                CoffeeItemViewController.aftertastePassed = RecordTasteEntity.shared.getAftertasteValue(record: eachRecord)
                                CoffeeItemViewController.acidityPassed = RecordTasteEntity.shared.getAcidityValue(record: eachRecord)
                                CoffeeItemViewController.bodyPassed = RecordTasteEntity.shared.getBodyValue(record: eachRecord)
                                CoffeeItemViewController.balancePassed = RecordTasteEntity.shared.getBalanceValue(record: eachRecord)
                                CoffeeItemViewController.sweetnessPassed = RecordTasteEntity.shared.getSweetnessValue(record: eachRecord)
                                CoffeeItemViewController.cleanCupPassed = RecordTasteEntity.shared.getCleanCupValue(record: eachRecord)
                                CoffeeItemViewController.uniformityPassed = RecordTasteEntity.shared.getUniformityValue(record: eachRecord)
                                CoffeeItemViewController.overallPassed = RecordTasteEntity.shared.getOverallValue(record: eachRecord)
                        
                        } // end of If
                } // end of For loop
            } // end of If let recordQuery
            
        } // end of if let Index path
    }
    
    
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        // do something
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

///////// refernece function from online resoureces

/*
 let record1Id = RecordEntity.shared.insert(name: "Financial information department",
 address: "An example address 1",
 city: "New York",
 zipCode: 1111)
 let record2Id = RecordEntity.shared.insert(name: "Sales department",
 address: "An example address 2",
 city: "Hong Kong",
 zipCode: 2222)
 */

/*
 if let recordQuery: AnySequence<Row> = RecordEntity.shared.filter() {
 for eachRecord in recordQuery {
 RecordEntity.shared.toString(record: eachRecord)
 }
 }
 */

//update
//for example, do not update name, -> name: nil
/*
 if RecordEntity.shared.update(id: 1,
 name: "new Department Name",
 address: "new address 123",
 city: "a new city",
 zipCode: 8888){
 print("Update successful")
 } else {
 print("Update unsuccessful")
 }
 */

//delete
/*
 if RecordEntity.shared.delete(id: 1){
 print("Delete successful")
 } else {
 print("Delete unsuccessful")
 }
 */

/*
 struct coffeeTasteForReference {
 var tasteid: Int64
 var fragrance: Double
 var flavor: Double
 var aftertaste: Double
 var acidity: Double
 var body: Double
 var balance: Double
 var sweetness: Double
 var cleanCup: Double
 var uniformity: Double
 var overall: Double
 var coffeeid: Int64
 }
 */

//  arrayCoffeeTasteFR = [coffeeTasteForReference]()
// var newCoffeeTasteFT:coffeeTasteForReference = coffeeTasteForReference(tasteid: 0, fragrance: 0, flavor: 0, aftertaste: 0, acidity: 0, body: 0, balance: 0, sweetness: 0, cleanCup: 0, uniformity: 0, overall: 0, coffeeid: 0)
// Do any additional setup after loading the view.
