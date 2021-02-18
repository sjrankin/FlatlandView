//
//  +Database.swift
//  Flatland
//
//  Created by Stuart Rankin on 2/15/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension Settings
{
    // MARK: - City-related table retrieval/editing.
    
    /// Get the set of cities determined by `Key`.
    /// - Note: Cities live in the mappable database, not `UserDefaults`.
    /// - Parameter Key: Determines whether the built-in city list or the user city list is returned.
    /// - Returns: Array of cities from the specified city table. Nil returns if `Key` is not valid.
    public static func GetCities(_ Key: SettingKeys) -> [City2]?
    {
        switch Key
        {
            case .CityList:
                return DBIF.Cities
                
            case .UserCityList:
                return DBIF.AdditionalCities
                
            default:
                return nil
        }
    }
    
    public static func UserCityRowOperation(_ Operation: TableOperations, City: City2)
    {
        switch Operation
        {
            case .Edit:
                break
            case .Add:
                break
            case .Delete:
                break
            case .RemoveAll:
                break
        }
    }
    
    public static func SaveQuakes(_ Quakes: [Earthquake])
    {
        DBIF.InsertQuakes(Quakes) 
    }
}

/// Operations callers can perform on non-built-in tables.
enum TableOperations: String, CaseIterable
{
    /// Edit a row.
    case Edit = "Edit"
    
    /// Add a new row.
    case Add = "Add"
    
    /// Delete an existing row.
    case Delete = "Delete"
    
    /// Remove all data in a table. 
    case RemoveAll = "RemoveAll"
}
