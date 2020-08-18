//
//  +EarthquakeHistory.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/16/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SQLite3

extension MainView
{
    /// Initialize the world heritage site database.
    /// - Warning: A fatal error is generated on error.
    public static func InitializeEarthquakeHistory()
    {
        if HistoricalQuakesInitialized
        {
            return
        }
        HistoricalQuakesInitialized = true
        if let QuakeURL = FileIO.GetEarthquakeHistoryDatabaseURL()
        {
            if sqlite3_open_v2(QuakeURL.path, &MainView.QuakeHandle,
                               SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_CREATE, nil) != SQLITE_OK
            {
                fatalError("Error opening \(QuakeURL.path), \(String(cString: sqlite3_errmsg(MainView.QuakeHandle!)))")
            }
        }
        else
        {
            fatalError("Error getting URL for historical earthquake database.")
        }
    }
    
    /// Return the number of historical earthquakes in the database.
    /// - Returns: Number of historical earthquakes in the database.
    func HistoricalQuakeCount() -> Int
    {
        let GetCount = "SELECT COUNT(*) FROM Historical"
        var CountQuery: OpaquePointer? = nil
        if sqlite3_prepare(MainView.QuakeHandle, GetCount, -1, &CountQuery, nil) == SQLITE_OK
        {
            while sqlite3_step(CountQuery) == SQLITE_ROW
            {
                let Count = sqlite3_column_int(CountQuery, 0)
                return Int(Count)
            }
        }
        print("Error returned when preparing \"\(GetCount)\"")
        return 0
    }
    
    /// Determines if an earthquake is already in the database.
    /// - Parameter ID: The ID of the earthquake to check.
    /// - Returns: True if the earthquake with the passed ID is in the database, false if not.
    func EarthquakeInDatabase(ID: String) -> Bool
    {
        if QuakeIDCache.contains(ID)
        {
            return true
        }
        let QueryString = "SELECT COUNT(*) FROM Historical WHERE ID='\(ID)'"
        var Query: OpaquePointer? = nil
        if sqlite3_prepare(MainView.QuakeHandle, QueryString, -1, &Query, nil) == SQLITE_OK
        {
            while sqlite3_step(Query) == SQLITE_ROW
            {
                let Count = sqlite3_column_int(Query, 0)
                if Count > 0
                {
                    return true
                }
                return false
            }
        }
        return false
    }
    
    func AddQuakeToHistory(_ Quake: Earthquake)
    {
        if EarthquakeInDatabase(ID: Quake.Code)
        {
            return
        }
        QuakeIDCache.append(Quake.Code)
    }
}
