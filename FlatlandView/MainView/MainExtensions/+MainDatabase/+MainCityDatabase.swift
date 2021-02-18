//
//  +MainCityDatabase.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SQLite3

extension MainController
{
    // MARK: - City database-related code.
    
    /// Returns the number of items in the passed table.
    /// - Parameter For: The table the number for which the number of items will be returned.
    /// - Returns: Result with the count of the number of items on success, error code on failure. On failure,
    ///            the count is undefined.
    public static func ItemCount(For: MappableTableNames) -> Result<Int, DatabaseErrors>
    {
        var TableName = ""
        switch For
        {
            case .AdditionalCities:
                TableName = For.rawValue
                
            case .Cities:
                TableName = For.rawValue
                
            case .PointsOfInterest:
                TableName = For.rawValue
                
            default:
                return .failure(.InvalidTable)
        }
        let GetCount = "SELECT COUNT(*) FROM \(TableName)"
        var CountQuery: OpaquePointer? = nil
        if sqlite3_prepare(MainController.MappableHandle, GetCount, -1, &CountQuery, nil) == SQLITE_OK
        {
            while sqlite3_step(CountQuery) == SQLITE_ROW
            {
                let Count = sqlite3_column_int(CountQuery, 0)
                return .success(Int(Count))
            }
        }
        return .failure(.QueryPreparationError)
    }
    
    /// Load all cities and return them in an array.
    /// - Returns: Array of all cities in the mappable database.
    public static func GetAllCities() -> [City2]
    {
        var Results = [City2]()
        let GetQuery = "SELECT * FROM \(MappableTableNames.Cities.rawValue)"
        let QueryHandle = SetupQuery(DB: MappableHandle, Query: GetQuery)
        while (sqlite3_step(QueryHandle) == SQLITE_ROW)
        {
            let ID = ReadIntColumn(Handle: QueryHandle, Index: CityColumns.CityPK.rawValue)!
            let Name = ReadStringColumn(Handle: QueryHandle, Index: CityColumns.CityName.rawValue)!
            let Country = ReadStringColumn(Handle: QueryHandle, Index: CityColumns.CityCountry.rawValue)!
            let IsCapital = ReadBoolColumn(Handle: QueryHandle, Index: CityColumns.CityIsCaptial.rawValue)!
            let Population = ReadIntColumn(Handle: QueryHandle, Index: CityColumns.CityPopulation.rawValue)!
            let MetroPopulation = ReadIntColumn(Handle: QueryHandle, Index: CityColumns.CityMetroPopulation.rawValue)!
            let Latitude = ReadDoubleColumn(Handle: QueryHandle, Index: CityColumns.CityLatitude.rawValue)!
            let Longitude = ReadDoubleColumn(Handle: QueryHandle, Index: CityColumns.CityLongitude.rawValue)!
            let Continent = ReadStringColumn(Handle: QueryHandle, Index: CityColumns.CityContinent.rawValue)!
            let CityColor = ReadStringColumn(Handle: QueryHandle, Index: CityColumns.CityColor.rawValue)!
            let IsWorldCity = ReadBoolColumn(Handle: QueryHandle, Index: CityColumns.CityWorldCity.rawValue)!
            let CityID = ReadUUIDColumn(Handle: QueryHandle, Index: CityColumns.CityID.rawValue)!
            let IsCustomCity = ReadBoolColumn(Handle: QueryHandle, Index: CityColumns.CityCustomCity.rawValue)!
            let DBCity = City2(Name, Country, IsCapital, Population, MetroPopulation, Latitude, Longitude,
                               Continent, CityID)
            Results.append(DBCity)
        }
        let PlaceGroup = WordGroup()
        for Place in Results
        {
            PlaceGroup.AddWord(Place.Name)
        }
        GlobalWordLists.AddGlobalWordList(For: .CityNames, WordList: PlaceGroup)
        return Results
    }
    
    #if false
    public static func MoveCities(Cities: [City])
    {
        let ColumnList = MakeColumnList(["Name", "Country", "IsCapital", "Population", "MetropolitanPopulation", "Latitude",
                                         "Longitude", "Continent", "CityColor", "IsWorldCity", "CityID", "IsCustomCity"])
        for SomeCity in Cities
        {
            var InsertCommand = "INSERT INTO \(MappableTableNames.Cities.rawValue) \(ColumnList) VALUES("
            InsertCommand.append("'\(RemoveApostrophes(From: SomeCity.Name))', ")
            InsertCommand.append("'\(SomeCity.Country)', ")
            InsertCommand.append("'\(SomeCity.IsCapital ? 1 : 0)', ")
            InsertCommand.append("'\(SomeCity.Population ?? 0)', ")
            InsertCommand.append("'\(SomeCity.MetropolitanPopulation ?? 0)', ")
            InsertCommand.append("'\(SomeCity.Latitude)', ")
            InsertCommand.append("'\(SomeCity.Longitude)', ")
            InsertCommand.append("'\(SomeCity.Continent)', ")
            InsertCommand.append("'\(SomeCity.CityColor.Hex)', ")
            InsertCommand.append("'\(SomeCity.IsWorldCity ? 1 : 0)', ")
            InsertCommand.append("'\(SomeCity.CityID.uuidString)', ")
            InsertCommand.append("'\(SomeCity.IsCustomCity ? 1 : 0)'")
            InsertCommand.append(")")
            var Insert: OpaquePointer? = nil
            if sqlite3_prepare_v2(MappableHandle, InsertCommand, -1, &Insert, nil) != SQLITE_OK
            {
                let (Message, Code) = ExtendedError(From: Insert)
                fatalError("Error preparing \(InsertCommand): \(Message) [\(Code)]")
            }
            let Result = sqlite3_step(Insert)
            if Result != SQLITE_DONE
            {
                let (Message, Code) = ExtendedError(From: Insert)
                fatalError("Error inserting row for City ID: \(SomeCity.CityID): \(Message) [\(Code)]")
            }
        }
    }
    #endif
    
    public static func GetAllAdditionalCities() -> [City2]
    {
        var Results = [City2]()
        #if false
        let GetQuery = "SELECT * FROM \(MappableTableNames.AdditionalCities.rawValue)"
        let QueryHandle = SetupQuery(DB: MappableHandle, Query: GetQuery)
        while (sqlite3_step(QueryHandle) == SQLITE_ROW)
        {
            let PKID = ReadIntColumn(Handle: QueryHandle, Index: AdditionalCityColumns.CityPK.rawValue)!
            let Name = ReadStringColumn(Handle: QueryHandle, Index: AdditionalCityColumns.Name.rawValue)!
            let Country = ReadStringColumn(Handle: QueryHandle, Index: AdditionalCityColumns.Country.rawValue)!
            let SubNational = ReadStringColumn(Handle: QueryHandle, Index: AdditionalCityColumns.SubNational.rawValue)!
            let Population = ReadIntColumn(Handle: QueryHandle, Index: AdditionalCityColumns.Population.rawValue)!
            let MetroPopulation = ReadIntColumn(Handle: QueryHandle, Index: AdditionalCityColumns.MetroPopulation.rawValue)!
            let Latitude = ReadDoubleColumn(Handle: QueryHandle, Index: AdditionalCityColumns.Latitude.rawValue)!
            let Longitude = ReadDoubleColumn(Handle: QueryHandle, Index: AdditionalCityColumns.Longitude.rawValue)!
            let Continent = ReadStringColumn(Handle: QueryHandle, Index: AdditionalCityColumns.Continent.rawValue)!
            let CityID = ReadUUIDColumn(Handle: QueryHandle, Index: AdditionalCityColumns.CityID.rawValue)!
            let Added = ReadDateColumn(Handle: QueryHandle, Index: AdditionalCityColumns.Added.rawValue)
            let Modified = ReadDateColumn(Handle: QueryHandle, Index: AdditionalCityColumns.Modified.rawValue)
            let DBCity = City2(Name, Country, false, Population, MetroPopulation, Latitude, Longitude,
                               Continent, CityID, true, SubNational)
            if Added != nil
            {
                DBCity.Added = Added
            }
            if Modified != nil
            {
                DBCity.Modified = Modified
            }
            Results.append(DBCity)
        }
        let PlaceGroup = WordGroup()
        for Place in Results
        {
            PlaceGroup.AddWord(Place.Name)
        }
        GlobalWordLists.AddGlobalWordList(For: .AdditionalCityNames, WordList: PlaceGroup)
        #endif
        return Results
    }
    
    /// Returns all POIs in the mappable database.
    /// - Returns: All POIs in the mappable database.
    public static func GetAllPOIs() -> [POI]
    {
        var Results = [POI]()
        let GetQuery = "SELECT * FROM \(MappableTableNames.PointsOfInterest.rawValue)"
        let QueryHandle = SetupQuery(DB: MappableHandle, Query: GetQuery)
        while (sqlite3_step(QueryHandle) == SQLITE_ROW)
        {
            let ID = ReadIntColumn(Handle: QueryHandle, Index: POIColumns.POIPK.rawValue)!
            let POIID = ReadUUIDColumn(Handle: QueryHandle, Index: POIColumns.POIID.rawValue)!
            let Name = ReadStringColumn(Handle: QueryHandle, Index: POIColumns.Name.rawValue)!
            let Latitude = ReadDoubleColumn(Handle: QueryHandle, Index: POIColumns.Latitude.rawValue)!
            let Longitude = ReadDoubleColumn(Handle: QueryHandle, Index: POIColumns.Longitude.rawValue)!
            let Description = ReadStringColumn(Handle: QueryHandle, Index: POIColumns.Description.rawValue, Default: "")
            let Numeric = ReadDoubleColumn(Handle: QueryHandle, Index: POIColumns.Numeric.rawValue)!
            let POIType = ReadIntColumn(Handle: QueryHandle, Index: POIColumns.POIType.rawValue)!
            let Added = ReadDateColumn(Handle: QueryHandle, Index: POIColumns.Added.rawValue)
            let Modified = ReadDateColumn(Handle: QueryHandle, Index: POIColumns.Modified.rawValue)
            let Color = ReadColorColumn(Handle: QueryHandle, Index: POIColumns.Color.rawValue)!
            let DBPOI = POI(POIID, Name, Latitude, Longitude, Description, Numeric, POIType, Color)
            if Added != nil
            {
                DBPOI.POIAdded = Added!
            }
            if Modified != nil
            {
                DBPOI.POIModified = Modified!
            }
            Results.append(DBPOI)
        }
        let PlaceGroup = WordGroup()
        for Place in Results
        {
            PlaceGroup.AddWord(Place.Name)
        }
        GlobalWordLists.AddGlobalWordList(For: .POINames, WordList: PlaceGroup)
        return Results
    }
}


