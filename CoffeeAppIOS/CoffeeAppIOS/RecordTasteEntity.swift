//
//  RecordTasteEntity.swift
//  CoffeeAppIOS
//
//  Created by Chau Sam on 15/8/2019.
//  Copyright © 2019 Chau Sam. All rights reserved.
//

import Foundation
import SQLite

// database (table) set up

class RecordTasteEntity {
    static let shared = RecordTasteEntity()
    
    private let tblRecordTaste = Table("tblRecordTaste")
    // attributes in table
    private let coffeeTasteId = Expression<Int64>("coffeeTasteId")
    // 9 tastes
    private let TasteFragranceValue = Expression<Double>("TasteFragranceValue")
    private let TasteFlavorValue = Expression<Double>("TasteFlavorValue")
    private let TasteAftertasteValue = Expression<Double>("TasteAftertasteValue")
    private let TasteAcidityValue = Expression<Double>("TasteAcidityValue")
    private let TasteBodyValue = Expression<Double>("TasteBodyValue")
    private let TasteBalanceValue = Expression<Double>("TasteBalanceValue")
    private let TasteSweetnessValue = Expression<Double>("TasteSweetnessValue")
    private let TasteCleanCupValue = Expression<Double>("TasteCleanCupValue")
    private let TasteUniformityValue = Expression<Double>("TasteUniformityValue")
    // overall, from RecordEntity
    private let TasteOverallValue = Expression<Double>("TasteOverallValue")
    // foreign key
    private let coffeeId = Expression<Int64>("coffeeId")
    
    private init() {
        //Create table if not exists
        do {
            if let connection = Database.shared.connection {
                try connection.run(tblRecordTaste.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (table) in
                    table.column(self.coffeeTasteId, primaryKey: true)
                    table.column(self.TasteFragranceValue)
                    table.column(self.TasteFlavorValue)
                    table.column(self.TasteAftertasteValue)
                    table.column(self.TasteAcidityValue)
                    table.column(self.TasteBodyValue)
                    table.column(self.TasteBalanceValue)
                    table.column(self.TasteSweetnessValue)
                    table.column(self.TasteCleanCupValue)
                    table.column(self.TasteUniformityValue)
                    table.column(self.TasteOverallValue)
                    table.column(self.coffeeId)
                }))
                print("Create table tblRecordTaste successfully")
            } else {
                print("Create table tblRecordTaste failed")
            }
        } catch {
            let nserror = error as NSError
            print("Create table tblRecordTaste failed. Error is: \(nserror), \(nserror.userInfo)")
        }
    }
    //Insert a record to tblRecordTaste
    func insert(TasteFragranceValue: Double, TasteFlavorValue: Double, TasteAftertasteValue: Double, TasteAcidityValue: Double, TasteBodyValue: Double, TasteBalanceValue: Double, TasteSweetnessValue: Double, TasteCleanCupValue: Double, TasteUniformityValue: Double, TasteOverallValue: Double, coffeeID: Int64) -> Int64? {
        do {
            let insert = tblRecordTaste.insert(self.TasteFragranceValue <- TasteFragranceValue,
                                               self.TasteFlavorValue <- TasteFlavorValue,
                                               self.TasteAftertasteValue <- TasteAftertasteValue,
                                               self.TasteAcidityValue <- TasteAcidityValue,
                                               self.TasteBodyValue <- TasteBodyValue,
                                               self.TasteBalanceValue <- TasteBalanceValue,
                                               self.TasteSweetnessValue <- TasteSweetnessValue,
                                               self.TasteCleanCupValue <- TasteCleanCupValue,
                                               self.TasteUniformityValue <- TasteUniformityValue,
                                               self.TasteOverallValue <- TasteOverallValue,
                                               self.coffeeId <- coffeeId)
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
            let filterCondition = (coffeeTasteId == 1)
            
            return try Database.shared.connection?.prepare(self.tblRecordTaste.filter(filterCondition))
        } catch {
            let nserror = error as NSError
            print("Cannot query(list) all tblRecord. Error is: \(nserror), \(nserror.userInfo)")
            return nil
        }
    }
    
    //UPDATE tblRecord SET(name= ... and address = ... and city = ... and zipCode = ...) where id == ??
    func update(TasteFragranceValue: Double, TasteFlavorValue: Double, TasteAftertasteValue: Double, TasteAcidityValue: Double, TasteBodyValue: Double, TasteBalanceValue: Double, TasteSweetnessValue: Double, TasteCleanCupValue: Double, TasteUniformityValue: Double, TasteOverallValue: Double, coffeeId: Int64) -> Bool {
        if Database.shared.connection == nil {
            return false
        }
        do {
            let tblFilterRecord = self.tblRecordTaste.filter(self.coffeeTasteId == coffeeTasteId)
            var setters:[SQLite.Setter] = [SQLite.Setter]()
            if TasteFragranceValue != nil {
                setters.append(self.TasteFragranceValue <- TasteFragranceValue)
            }
            if TasteFlavorValue != nil {
                setters.append(self.TasteFlavorValue <- TasteFlavorValue)
            }
            if TasteAftertasteValue != nil {
                setters.append(self.TasteAftertasteValue <- TasteAftertasteValue)
            }
            if TasteAcidityValue != nil {
                setters.append(self.TasteAcidityValue <- TasteAcidityValue)
            }
            if TasteBodyValue != nil {
                setters.append(self.TasteBodyValue <- TasteBodyValue)
            }
            if TasteBalanceValue != nil {
                setters.append(self.TasteBalanceValue <- TasteBalanceValue)
            }
            if TasteSweetnessValue != nil {
                setters.append(self.TasteSweetnessValue <- TasteSweetnessValue)
            }
            if TasteCleanCupValue != nil {
                setters.append(self.TasteCleanCupValue <- TasteCleanCupValue)
            }
            if TasteUniformityValue != nil {
                setters.append(self.TasteUniformityValue <- TasteUniformityValue)
            }
            if TasteOverallValue != nil {
                setters.append(self.TasteOverallValue <- TasteOverallValue)
            }
            if coffeeId != nil {
                setters.append(self.coffeeId <- coffeeId)
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
            let tblFilterRecord = self.tblRecordTaste.filter(self.coffeeTasteId == coffeeTasteId)
            if try Database.shared.connection!.run(tblFilterRecord.delete()) <= 0 {
                //Delete unsuccessful
                return false
            }
            return true
        } catch {
            let nserror = error as NSError
            print("Cannot delete objects in tblRecordTaste. Error is: \(nserror), \(nserror.userInfo)")
            return false
        }
    }
    
    // How to query(find) all records in tblRecord ?
    func queryAll() -> AnySequence<Row>? {
        do {
            return try Database.shared.connection?.prepare(self.tblRecordTaste)
        } catch {
            let nserror = error as NSError
            print("Cannot query(list) all tblRecordTaste. Error is: \(nserror), \(nserror.userInfo)")
            return nil
        }
    }
    
    func getTasteID(record: Row)->Int64{
        return record[self.coffeeTasteId]
    }
    
    func getFragranceValue(record: Row)->Double{
        return record[self.TasteFragranceValue]
    }
    
    func getFlavorValue(record: Row)->Double{
        return record[self.TasteFlavorValue]
    }
    func getAftertasteValue(record: Row)->Double{
        return record[self.TasteAftertasteValue]
    }
    func getAcidityValue(record: Row)->Double{
        return record[self.TasteAcidityValue]
    }
    func getBodyValue(record: Row)->Double{
        return record[self.TasteBodyValue]
    }
    func getBalanceValue(record: Row)->Double{
        return record[self.TasteBalanceValue]
    }
    func getSweetnessValue(record: Row)->Double{
        return record[self.TasteSweetnessValue]
    }
    func getCleanCupValue(record: Row)->Double{
        return record[self.TasteCleanCupValue]
    }
    func getUniformityValue(record: Row)->Double{
        return record[self.TasteUniformityValue]
    }
    func getOverallValue(record: Row)->Double{
        return record[self.TasteOverallValue]
    }
    func getCoffeeId(record: Row)->Int64{
        return record[self.coffeeId]
    }
    
    
    func toString(record: Row){
        print("""
            #\(record[self.coffeeTasteId]),
            @\(record[self.TasteFragranceValue]),
            @\(record[self.TasteFlavorValue]),
            @\(record[self.TasteAftertasteValue]),
            @\(record[self.TasteAcidityValue]),
            @\(record[self.TasteBodyValue]),
            @\(record[self.TasteBalanceValue]),
            @\(record[self.TasteSweetnessValue]),
            @\(record[self.TasteCleanCupValue]),
            @\(record[self.TasteUniformityValue]),
            @\(record[self.TasteOverallValue]),
            $\(record[self.coffeeId]))
            """)
    }
    
    
}
