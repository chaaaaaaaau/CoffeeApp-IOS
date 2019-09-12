//
//  RecordEntity.swift
//  CoffeeAppIOS
//
//  Created by Chau Sam on 8/7/2019.
//  Copyright © 2019 Chau Sam. All rights reserved.
//
/*
 
 // ReportPassed
 var totalTimeSpentPassed: String = ""
 var initBloomTempPassed: String = ""
 var initBrewTempPassed: String = ""
 var finalBrewTempPassed: String = ""
 var avgTempPassed: String = ""
 var totalWaterInfusedPassed: String = ""
 var totalCoffeeProducedPassed: String = ""
 var numOfPourPassed: String = ""
 
 */

import Foundation
import SQLite

// database (table) set up

class RecordEntity {
    static let shared = RecordEntity()
    
    private let tblRecord = Table("tblRecord")
    // ************** attributes in table
    private let coffeeId = Expression<Int64>("coffeeId")
    
    // Display in Record list
    private let coffeeName = Expression<String>("coffeeName")
    private let coffeeType = Expression<String>("coffeeType")
    private let coffeeRating = Expression<Double>("coffeeRating")
    
    // Further Details: Chart
    private let coffeeDataTemp = Expression<String>("coffeeDataTemp")
    private let coffeeDataInVol = Expression<String>("coffeeDataInVol")
    private let coffeeDataOutVol = Expression<String>("coffeeDataOutVol")
    
    // Further Details: Pour
    private let coffeeDataPouring = Expression<String>("coffeeDataPouring")
    
    // Further Details: Report
    private let coffeeTotalTimeSpent = Expression<String>("coffeeTotalTimeSpent")
    private let coffeeInitBloomTemp = Expression<String>("coffeeInitBloomTemp")
    private let coffeeInitBrewTemp = Expression<String>("coffeeInitBrewTemp")
    private let coffeeFinalBrewTemp = Expression<String>("coffeeFinalBrewTemp")
    private let coffeeAvgTemp = Expression<String>("coffeeAvgTemp")
    private let coffeeTotalWaterInfused = Expression<String>("coffeeTotalWaterInfused")
    private let coffeeTotalCoffeeProduced = Expression<String>("coffeeTotalCoffeeProduced")
    private let coffeeNumOfPour = Expression<String>("coffeeNumOfPour")
    
    
  //  private let coffeeArrayTaste = Expression<Array<detailCoffeeTaste>>("coffeeArrayTaste")
    
    private init() {
        //Create table if not exists
        do {
            if let connection = Database.shared.connection {
                try connection.run(tblRecord.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (table) in
                    table.column(self.coffeeId, primaryKey: true)
                    table.column(self.coffeeName)
                    table.column(self.coffeeType)
                    
                    table.column(self.coffeeDataTemp)
                    table.column(self.coffeeDataInVol)
                    table.column(self.coffeeDataOutVol)
                    
                    table.column(self.coffeeDataPouring)
                    //table.column(self.coffeeTemp)
                    //table.column(self.coffeeInVol)
                    //table.column(self.coffeeOutVol)
                    table.column(self.coffeeRating)
                    table.column(self.coffeeTotalTimeSpent)
                    table.column(self.coffeeInitBloomTemp)
                    table.column(self.coffeeInitBrewTemp)
                    table.column(self.coffeeFinalBrewTemp)
                    table.column(self.coffeeAvgTemp)
                    table.column(self.coffeeTotalWaterInfused)
                    table.column(self.coffeeTotalCoffeeProduced)
                    table.column(self.coffeeNumOfPour)
                   // table.column(self.coffeeArrayTaste)
                }))
                print("Create table tblRecord successfully")
            } else {
                print("Create table tblRecord failed")
            }
        } catch {
            let nserror = error as NSError
            print("Create table tblRecord failed. Error is: \(nserror), \(nserror.userInfo)")
        }
    }
    //Insert a record to tblRecord
    func insert(coffeeName: String, coffeeType: String, coffeeRating: Double, coffeeDataTemp: String, coffeeDataInVol: String, coffeeDataOutVol: String, coffeeDataPouring: String, coffeeTotalTimeSpent: String, coffeeInitBloomTemp: String, coffeeInitBrewTemp: String, coffeeFinalBrewTemp: String, coffeeAvgTemp: String, coffeeTotalWaterInfused: String, coffeeTotalCoffeeProduced: String, coffeeNumOfPour: String) -> Int64? {
        do {
            let insert = tblRecord.insert(self.coffeeName <- coffeeName,
                                          self.coffeeType <- coffeeType,
                                          self.coffeeRating <- coffeeRating,
                                          self.coffeeDataTemp <- coffeeDataTemp,
                                          self.coffeeDataInVol <- coffeeDataInVol,
                                          self.coffeeDataOutVol <- coffeeDataOutVol,
                                          self.coffeeDataPouring <- coffeeDataPouring,
                                          self.coffeeTotalTimeSpent <- coffeeTotalTimeSpent,
                                          self.coffeeInitBloomTemp <- coffeeInitBloomTemp,
                                          self.coffeeInitBrewTemp <- coffeeInitBrewTemp,
                                          self.coffeeFinalBrewTemp <- coffeeFinalBrewTemp,
                                          self.coffeeAvgTemp <- coffeeAvgTemp,
                                          self.coffeeTotalWaterInfused <- coffeeTotalWaterInfused,
                                          self.coffeeTotalCoffeeProduced <- coffeeTotalCoffeeProduced,
                                          self.coffeeNumOfPour <- coffeeNumOfPour) // int64 -> ?? 0
            let insertedId = try Database.shared.connection!.run(insert)
            return insertedId
        } catch {
            let nserror = error as NSError
            print("Cannot insert new Record. Error is: \(nserror), \(nserror.userInfo)")
            return nil
        }
    }
    
    func filter() -> AnySequence<Row>? {
        do {
            //SELECT * FROM "tblRecord" WHERE ("id" = 1)
            //let filterCondition = (id == 1)
            
            //SELECT * FROM "tblRecord" WHERE ("id" IN (1, 2, 3, 4))
            //let filterCondition = [1, 2, 3 ,4].contains(id)
            
            //SELECT * FROM "tblRecord" WHERE ("name" LIKE '%Record%')
            //let filterCondition = self.name.like("%Department%")
            
            //SELECT * FROM "tblRecord" WHERE name.lowercaseString == "sales department" AND id >= 3
            //let filterCondition = (id >= 3) && (name.lowercaseString == "sales department")
            
            //SELECT * FROM "tblRecord" WHERE ("id" == 3) OR ("id" == 4)
            //let filterCondition = (id == 3) || (id == 4)
            let filterCondition = (coffeeId == 1)
            
            return try Database.shared.connection?.prepare(self.tblRecord.filter(filterCondition))
        } catch {
            let nserror = error as NSError
            print("Cannot query(list) all tblRecord. Error is: \(nserror), \(nserror.userInfo)")
            return nil
        }
    }
    
    //UPDATE tblRecord SET(name= ... and address = ... and city = ... and zipCode = ...) where id == ??
    func update(coffeeName: String, coffeeType: String, coffeeRating: Double, coffeeDataTemp: String, coffeeDataInVol: String, coffeeDataOutVol: String, coffeeDataPouring: String, coffeeTotalTimeSpent: String, coffeeInitBloomTemp: String, coffeeInitBrewTemp: String, coffeeFinalBrewTemp: String, coffeeAvgTemp: String, coffeeTotalWaterInfused: String, coffeeTotalCoffeeProduced: String, coffeeNumOfPour: String) -> Bool {
        if Database.shared.connection == nil {
            return false
        }
        do {
            let tblFilterRecord = self.tblRecord.filter(self.coffeeId == coffeeId)
            var setters:[SQLite.Setter] = [SQLite.Setter]()
            if coffeeName != nil {
                setters.append(self.coffeeName <- coffeeName) // name!
            }
            if coffeeType != nil {
                setters.append(self.coffeeType <- coffeeType)
            }
            if coffeeRating != nil {
                setters.append(self.coffeeRating <- coffeeRating)
            }
            
            if coffeeDataTemp != nil {
                setters.append(self.coffeeDataTemp <- coffeeDataTemp)
            }
            if coffeeDataInVol != nil {
                setters.append(self.coffeeDataInVol <- coffeeDataInVol)
            }
            if coffeeDataOutVol != nil {
                setters.append(self.coffeeDataOutVol <- coffeeDataOutVol)
            }
            if coffeeDataPouring != nil {
                setters.append(self.coffeeDataPouring <- coffeeDataPouring)
            }
            if coffeeTotalTimeSpent != nil {
                setters.append(self.coffeeName <- coffeeTotalTimeSpent) // name!
            }
            if coffeeInitBloomTemp != nil {
                setters.append(self.coffeeInitBloomTemp <- coffeeInitBloomTemp)
            }
            
            if coffeeInitBrewTemp != nil {
                setters.append(self.coffeeName <- coffeeInitBrewTemp) // name!
            }
            if coffeeFinalBrewTemp != nil {
                setters.append(self.coffeeFinalBrewTemp <- coffeeFinalBrewTemp)
            }
            
            if coffeeAvgTemp != nil {
                setters.append(self.coffeeName <- coffeeAvgTemp) // name!
            }
            if coffeeTotalWaterInfused != nil {
                setters.append(self.coffeeTotalWaterInfused <- coffeeTotalWaterInfused)
            }
            if coffeeTotalCoffeeProduced != nil {
                setters.append(self.coffeeTotalCoffeeProduced <- coffeeTotalCoffeeProduced)
            }
            if coffeeNumOfPour != nil {
                setters.append(self.coffeeNumOfPour <- coffeeNumOfPour)
            }
            
            if setters.count == 0 {
                print("Nothing to update")
                return false
            }
            let update = tblFilterRecord.update(setters)
            if try Database.shared.connection!.run(update) <= 0 {
                //Update unsuccessful
                return false
            }
            return true
        } catch {
            let nserror = error as NSError
            print("Cannot list / query objects in tblRecord. Error is: \(nserror), \(nserror.userInfo)")
            return false
        }
    }
    
    func delete(id: Int64) -> Bool {
        if Database.shared.connection == nil {
            return false
        }
        do {
            let tblFilterRecord = self.tblRecord.filter(self.coffeeId == coffeeId)
            if try Database.shared.connection!.run(tblFilterRecord.delete()) <= 0 {
                //Delete unsuccessful
                return false
            }
            return true
        } catch {
            let nserror = error as NSError
            print("Cannot delete objects in tblRecord. Error is: \(nserror), \(nserror.userInfo)")
            return false
        }
    }
    
    // How to query(find) all records in tblRecord ?
    func queryAll() -> AnySequence<Row>? {
        do {
            return try Database.shared.connection?.prepare(self.tblRecord)
        } catch {
            let nserror = error as NSError
            print("Cannot query(list) all tblRecord. Error is: \(nserror), \(nserror.userInfo)")
            return nil
        }
    }
    
    func getID(record: Row)->Int64{
        return record[self.coffeeId]
    }
    func getName(record: Row)->String{
        return record[self.coffeeName]
    }
    func getType(record: Row)->String{
        return record[self.coffeeType]
    }
    func getRating(record: Row)->Double{
        return record[self.coffeeRating]
    }
    
    func getDataStrTemp(record: Row)->String{
        return record[self.coffeeDataTemp]
    }
    func getDataStrInVol(record: Row)->String{
        return record[self.coffeeDataInVol]
    }
    func getDataStrOutVol(record: Row)->String{
        return record[self.coffeeDataOutVol]
    }
    
    func getDataStrPouring(record: Row)->String{
        return record[self.coffeeDataPouring]
    }
    func getTotalTimeSpent(record: Row)->String{
        return record[self.coffeeTotalTimeSpent]
    }
    func getInitBloomTemp(record: Row)->String{
        return record[self.coffeeInitBloomTemp]
    }
    func getInitBrewTemp(record: Row)->String{
        return record[self.coffeeInitBrewTemp]
    }
    func getFinalBrewTemp(record: Row)->String{
        return record[self.coffeeFinalBrewTemp]
    }
    func getAvgTemp(record: Row)->String{
        return record[self.coffeeAvgTemp]
    }
    func getTotalWaterInfused(record: Row)->String{
        return record[self.coffeeTotalWaterInfused]
    }
    func getTotalCoffeeProduced(record: Row)->String{
        return record[self.coffeeTotalCoffeeProduced]
    }
    func getNumOfPour(record: Row)->String{
        return record[self.coffeeNumOfPour]
    }
    
    func toString(record: Row){
        print("""
            #\(record[self.coffeeId]),
            @\(record[self.coffeeName]),
            @\(record[self.coffeeRating]),
            @\(record[self.coffeeDataTemp]),
            @\(record[self.coffeeDataInVol]),
            @\(record[self.coffeeDataOutVol]),
            @\(record[self.coffeeDataPouring]),
            @\(record[self.coffeeTotalTimeSpent]),
            @\(record[self.coffeeInitBloomTemp]),
            @\(record[self.coffeeInitBrewTemp]),
            @\(record[self.coffeeFinalBrewTemp]),
            @\(record[self.coffeeAvgTemp]),
            @\(record[self.coffeeTotalWaterInfused]),
            @\(record[self.coffeeTotalCoffeeProduced]),
            $\(record[self.coffeeNumOfPour]))
        """)
    }
    
    
}
