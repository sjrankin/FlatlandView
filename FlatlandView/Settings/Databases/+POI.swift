//
//  +POI.swift
//  Flatland
//
//  Created by Stuart Rankin on 2/10/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SQLite3

extension DBIF
{
    // MARK: - Points of interest table handling.
    
    /// Return all user-defined points of interest.
    /// - Returns: Array of user-defined points of interest. May be empty if nothing defined or on error.
    public static func GetAllUserPOIs() -> [POI2]
    {
        var Results = [POI2]()
        if DBIF.MappableHandle == nil
        {
            Debug.Print("Call to \(#function) before database initialized.")
            return Results
        }
        let GetQuery = "SELECT * FROM \(POITableNames.UserPOI.rawValue)"
        let QuerySetupResult = SQL.SetupQuery(For: DBIF.MappableHandle, Query: GetQuery)
        var QueryHandle: OpaquePointer? = nil
        switch QuerySetupResult
        {
            case .success(let Handle):
                QueryHandle = Handle
                
            case .failure(let Why):
                Debug.Print("Failure creating query for user points of interest: \(Why)")
                let (Message, Value) = SQL.ExtendedError(From: DBIF.MappableHandle)
                Debug.Print("  \(Message) [\(Value)]")
                return [POI2]()
        }
        while (sqlite3_step(QueryHandle) == SQLITE_ROW)
        {
            let PKID = SQL.ReadIntColumn(Handle: QueryHandle, Index: POIColumns2.ID.rawValue)!
            let POIID = SQL.ReadUUIDColumn(Handle: QueryHandle, Index: POIColumns2.POIID.rawValue)!
            let Name = SQL.ReadStringColumn(Handle: QueryHandle, Index: POIColumns2.Name.rawValue)!
            let Description = SQL.ReadStringColumn(Handle: QueryHandle, Index: POIColumns2.Description.rawValue, Default: "")
            let Latitude = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: POIColumns2.Latitude.rawValue)!
            let Longitude = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: POIColumns2.Longitude.rawValue)!
            let Color = SQL.ReadColorColumn(Handle: QueryHandle, Index: POIColumns2.Color.rawValue, Default: NSColor.yellow)
            let POIType = SQL.ReadIntColumn(Handle: QueryHandle, Index: POIColumns2.POIType.rawValue)!
            let Numeric = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: POIColumns2.Numeric.rawValue)!
            let Added = SQL.ReadDateColumn(Handle: QueryHandle, Index: POIColumns2.Added.rawValue)
            let Modified = SQL.ReadDateColumn(Handle: QueryHandle, Index: POIColumns2.Added.rawValue)
            let UPOI = POI2(Meta: .User, PKID, POIID, Name, Description, Latitude, Longitude,
                            Color, POIType, Numeric, Added, Modified)
            Results.append(UPOI)
        }
        return Results
    }
    
    /// Returns all built-in points of interest.
    /// - Returns: Array of all points of interest.
    public static func GetAllBuiltInPOIs() -> [POI2]
    {
        var Results = [POI2]()
        if DBIF.MappableHandle == nil
        {
            Debug.Print("Call to \(#function) before database initialized.")
            return Results
        }
        let GetQuery = "SELECT * FROM \(POITableNames.POI.rawValue)"
        let QuerySetupResult = SQL.SetupQuery(For: DBIF.MappableHandle, Query: GetQuery)
        var QueryHandle: OpaquePointer? = nil
        switch QuerySetupResult
        {
            case .success(let Handle):
                QueryHandle = Handle
                
            case .failure(let Why):
                let StackTrace = Debug.StackFrameContents(10)
                Debug.Print("\(Debug.PrettyStackTrace(StackTrace))")
                Debug.Print("Failure creating query for built-in points of interest: \(Why)")
                let (Message, Value) = SQL.ExtendedError(From: DBIF.MappableHandle)
                Debug.Print("  \(Message) [\(Value)]")
                return [POI2]()
        }
        while (sqlite3_step(QueryHandle) == SQLITE_ROW)
        {
            #if true
            let PKID = SQL.ReadIntColumn(Handle: QueryHandle, Index: POIColumns2.ID.rawValue)!
            let POIID = SQL.ReadUUIDColumn(Handle: QueryHandle, Index: POIColumns2.POIID.rawValue)!
            let Name = SQL.ReadStringColumn(Handle: QueryHandle, Index: POIColumns2.Name.rawValue)!
            let Description = SQL.ReadStringColumn(Handle: QueryHandle, Index: POIColumns2.Description.rawValue, Default: "")
            let Latitude = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: POIColumns2.Latitude.rawValue)!
            let Longitude = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: POIColumns2.Longitude.rawValue)!
            let Color = SQL.ReadColorColumn(Handle: QueryHandle, Index: POIColumns2.Color.rawValue, Default: NSColor.yellow)
            let POIType = SQL.ReadIntColumn(Handle: QueryHandle, Index: POIColumns2.POIType.rawValue)!
            let Numeric = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: POIColumns2.Numeric.rawValue)!
            let Added = SQL.ReadDateColumn(Handle: QueryHandle, Index: POIColumns2.Added.rawValue)
            let Modified = SQL.ReadDateColumn(Handle: QueryHandle, Index: POIColumns2.Added.rawValue)
            let UPOI = POI2(Meta: .User, PKID, POIID, Name, Description, Latitude, Longitude,
                            Color, POIType, Numeric, Added, Modified)
            Results.append(UPOI)
            #else
            let PKID = SQL.ReadIntColumn(Handle: QueryHandle, Index: POIColumns2.ID.rawValue)!
            let POIID = SQL.ReadUUIDColumn(Handle: QueryHandle, Index: POIColumns2.POIID.rawValue)!
            let Name = SQL.ReadStringColumn(Handle: QueryHandle, Index: POIColumns2.Name.rawValue)!
            let Description = SQL.ReadStringColumn(Handle: QueryHandle, Index: POIColumns2.Description.rawValue)!
            let Latitude = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: POIColumns2.Latitude.rawValue)!
            let Longitude = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: POIColumns2.Longitude.rawValue)!
            let Color = SQL.ReadColorColumn(Handle: QueryHandle, Index: POIColumns2.Color.rawValue, Default: NSColor.yellow)
            let Shape = SQL.ReadStringColumn(Handle: QueryHandle, Index: POIColumns2.Shape.rawValue)!
            let POIType = SQL.ReadIntColumn(Handle: QueryHandle, Index: POIColumns2.HomeType.rawValue)!
            let Numeric = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: POIColumns2.Numeric.rawValue)!
            let Added = SQL.ReadDateColumn(Handle: QueryHandle, Index: POIColumns2.Added.rawValue)
            let Modified = SQL.ReadDateColumn(Handle: QueryHandle, Index: POIColumns2.Added.rawValue)
            let Category = SQL.ReadStringColumn(Handle: QueryHandle, Index: POIColumns2.Category.rawValue, Default: "")
            let SubCategory = SQL.ReadStringColumn(Handle: QueryHandle, Index: POIColumns2.Category.rawValue, Default: "")
            let ShowPOI = SQL.ReadBoolColumn(Handle: QueryHandle, Index: POIColumns2.Show.rawValue)!
            let UPOI = POI2(Meta: .User, PKID, POIID, Name, Description, Latitude, Longitude,
                            Color, Shape, POIType, Numeric, Category, SubCategory,
                            Added, Modified, ShowPOI)
            Results.append(UPOI)
            #endif
        }
        return Results
    }
    
    public static func SetUserPOIs(_ POIs: [POI2])
    {
        
    }
}
