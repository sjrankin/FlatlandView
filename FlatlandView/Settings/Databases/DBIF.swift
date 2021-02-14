//
//  DBIF.swift
//  Flatland
//
//  Created by Stuart Rankin on 2/9/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SQLite3

/// Database interface class. Not intended to be called by anyone other than the Settings class.
class DBIF
{
    public static func Initialize(LoadToo: Bool = true)
    {
        #if true
        FileIO.InstallDatabases()
        if !MappableInitialized
        {
            _MappableInitialized = true
            if let MappableURL = FileIO.GetMappagleDatabaseSURL()
            {
                print("MappableURL=\(MappableURL.path)")
                if sqlite3_open_v2(MappableURL.path, &MappableHandle,
                                   SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_CREATE, nil) != SQLITE_OK
                {
                    Debug.FatalError("Error opening \(MappableURL.path), \(String(cString: sqlite3_errmsg(MappableHandle!)))")
                }
            }
            else
            {
                Debug.FatalError("Error getting URL for the mappable database.")
            }
        }
        if !QuakesInitialized
        {
            _QuakesInitialized = true
            if let QuakeURL = FileIO.GetEarthquakeHistoryDatabaseSURL()
            {
                if sqlite3_open_v2(QuakeURL.path, &QuakeHandle,
                                   SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_CREATE, nil) != SQLITE_OK
                {
                    Debug.FatalError("Error opening \(QuakeURL.path), \(String(cString: sqlite3_errmsg(QuakeHandle!)))")
                }
            }
            else
            {
                Debug.FatalError("Error getting URL for the historic earthquake database.")
            }
        }
        if LoadToo
        {
            LoadTables()
        }
        #endif
    }
    
    /// Load certain tables into memory-resident arrays.
    /// - Note: Only the most recent earthquakes are loaded, not all of them.
    public static func LoadTables()
    {
        UNESCOSites = LoadWorldHeritageSites()
        UserPOIs = GetAllUserPOIs()
        BuiltInPOIs = GetAllBuiltInPOIs()
        if let Earlier = Calendar.current.date(byAdding: .day, value: -30, to: Date())
        {
            InitialQuakes = GetHistoricQuakes(Start: Earlier, End: Date())
        }
        print("Found \(InitialQuakes.count) latest earthquakes")
        Cities = GetAllCities()
        AdditionalCities = GetAllAdditionalCities()
        print("City.count=\(Cities.count), AdditionalCities.count=\(AdditionalCities.count)")
    }
    
    private static var _QuakesInitialized: Bool = false
    public static var QuakesInitialized: Bool
    {
        get
        {
            return _QuakesInitialized
        }
    }
    
    private static var _MappableInitialized: Bool = false
    public static var MappableInitialized: Bool
    {
        get
        {
            return _MappableInitialized
        }
    }
    
    // MARK: - In-memory tables.
    
    private static var BuiltInPOIs = [POI2]()
    private static var UserPOIs = [POI2]()
    private static var UNESCOSites = [WorldHeritageSite]()
    private static var InitialQuakes = [Earthquake]()
    private static var Cities = [City2]()
    private static var AdditionalCities = [City2]()
    
    // MARK: - Database handles.
    public static var MappableHandle: OpaquePointer? = nil
    public static var QuakeHandle: OpaquePointer? = nil
}


/// Column IDs for the city table in the mappable database.
enum CityColumns: Int32
{
    /// City entry primary key.
    case CityPK = 0
    /// City name.
    case CityName = 1
    /// Country of the city.
    case CityCountry = 2
    /// Capital city flag.
    case CityIsCaptial = 3
    /// City population.
    case CityPopulation = 4
    /// City metro population.
    case CityMetroPopulation = 5
    /// City latitude.
    case CityLatitude = 6
    /// City longitude.
    case CityLongitude = 7
    /// Continent of the city.
    case CityContinent = 8
    /// Color of the city.
    case CityColor = 9
    /// World city flag.
    case CityWorldCity = 10
    /// ID of the city (UUID).
    case CityID = 11
    /// Custom city flag.
    case CityCustomCity = 12
    /// Sub-national location name.
    case SubNational = 13
}

/// Column IDs for POI locations.
enum POIColumns: Int32
{
    /// POI entry primary key.
    case POIPK = 0
    /// POI ID (UUID).
    case POIID = 1
    /// POI name.
    case Name = 2
    /// POI latitude.
    case Latitude = 3
    /// POI longitude.
    case Longitude = 4
    /// POI description.
    case Description = 5
    /// POI numeric value. *Usaged TBD.*
    case Numeric = 6
    /// POI type.
    case POIType = 7
    /// Date POI added.
    case Added = 8
    /// Date POI modified.
    case Modified = 9
    /// POI Color.
    case Color = 10
}

/// Column IDs for home locations.
enum HomeColumns: Int32
{
    /// Home entry primary key.
    case ID = 0
    /// Home ID (UUID).
    case HomeID = 1
    /// Home name.
    case Name = 2
    /// Home description.
    case Description = 3
    /// Home latitude.
    case Latitude = 4
    /// Home longitude.
    case Longitude = 5
    /// Home shape color.
    case Color = 6
    /// Home shape.
    case Shape = 7
    /// Home type.
    case HomeType = 8
    /// Associated home numeric value.
    case Numeric = 9
    /// Date home added.
    case Added = 10
    /// Date home modified.
    case Modified = 11
    /// Show home flag.
    case Show = 13
}

enum QuakeColumns: Int32
{
    /// Quake entry primary key.
    case ID = 0
    case Latitude = 1
    case Longitude = 2
    case Place = 3
    case Magnitude = 4
    case Depth = 5
    case Time = 6
    case Updated = 7
    case Code = 8
    case Tsunami = 9
    case Status = 10
    case MMI = 11
    case Felt = 12
    case Significance = 13
    case Sequence = 14
    case Notified = 15
    case FlatlandRegion = 16
    case Marked = 17
    case MagType = 18
    case MagError = 19
    case MagNS = 20
    case DMin = 21
    case Alert = 22
    case Title = 23
    case Types = 24
    case EventType = 25
    case Detail = 26
    case TZ = 27
    case EventPageURL = 28
    case Sources = 29
    case Net = 30
    case NST = 31
    case Gap = 32
    case IDs = 33
    case HorizontalError = 34
    case CDI = 35
    case RMS = 36
    case NPH = 37
    case LocationSource = 38
    case MagSource = 39
    case ContextDistance = 40
    case DebugQuake = 41
    case QuakeDate = 42
    case QuakeID = 43
    case EventID = 44
}
