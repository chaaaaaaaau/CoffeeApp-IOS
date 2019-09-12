//
//  Database.swift
//  CoffeeAppIOS
//
//  Created by Chau Sam on 8/7/2019.
//  Copyright © 2019 Chau Sam. All rights reserved.
//
// ref https://www.youtube.com/watch?v=lYjZu0sXMwM

import Foundation
import SQLite

// database setup

class Database {

    static let shared: Database = Database()
    public let connection: Connection?
    public let databaseFileName = "CoffeeAppIOS.sqlite3"
    private init() {
        let dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first as String? // String! in original code
        do {
            connection = try Connection("\(dbPath!)/(databaseFileName)")
        } catch  {
            connection = nil
            let nserror = error as NSError
            print("Cannot connect to Database. Error is: \(nserror), \(nserror.userInfo)")
            
        }
    }




}
