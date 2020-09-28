//
//  NodeTables.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/28/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

/// This class maintains a dictionary of dictionaries of `SCNNode` IDs and related data for use when the
/// user wants more information about a given visual node.
class NodeTables
{
    /// Initialize the node tables.
    /// - Warning: If city data and World Heritage Sites have not yet been loaded, item data for both class
    ///            types will be missing.
    /// - Note: City data is loaded here.
    /// - Parameter Unesco: Array of World Heritage Sites.
    public static func Initialize(Unesco: [WorldHeritageSite])
    {
        for SomeCity in CitiesData.RawCityList
        {
            CityTable[SomeCity.CityID] = DisplayItem(ID: SomeCity.CityID, ItemType: .City, Name: SomeCity.Name,
                                                     Numeric: Double(SomeCity.GetPopulation()),
                                                     Location: GeoPoint(SomeCity.Latitude, SomeCity.Longitude),
                                                     Description: "")
        }
        
        for Site in Unesco
        {
            UNESCOTable[Site.InternalID] = DisplayItem(ID: Site.InternalID, ItemType: .WorldHeritageSite,
                                                       Name: Site.Name, Numeric: Double(Site.DateInscribed),
                                                       Location: GeoPoint(Site.Latitude, Site.Longitude),
                                                       Description: Site.Category)
        }
    }
    
    /// Add an earthquake to the earthquake item table.
    /// - Parameter Quake: The earthquake to add to the table. Duplicate earthquakes overwrite previous
    ///                    earthquakes.
    public static func AddEarthquake(_ Quake: Earthquake)
    {
        let QItem = DisplayItem(ID: Quake.ID, ItemType: .Earthquake, Name: "\(Quake.Time)",
                                Numeric: Quake.Magnitude, Location: Quake.LocationAsGeoPoint(),
                                Description: Quake.Place)
        QuakeTable[QItem.ID] = QItem
    }
    
    /// Deletes all earthquakes.
    public static func RemoveEarthquakes()
    {
        QuakeTable.removeAll()
    }
    
    /// Add user points of interesting.
    /// - Parameter ID: The ID of the user POI.
    /// - Parameter Name: The name of the user POI.
    /// - Parameter Location: The location of the user POI.
    public static func AddUserPOI(ID: UUID, Name: String, Location: GeoPoint)
    {
        let UserPOI = DisplayItem(ID: ID, ItemType: .UserPOI, Name: Name,
                                  Numeric: 0.0, Location: Location)
        POITable[UserPOI.ID] = UserPOI
    }
    
    /// Deletes all user POIs.
    public static func RemoveUserPOI()
    {
        POITable.removeAll()
    }
    
    /// Add the user's home location.
    /// - Parameter ID: ID of the home location.
    /// - Parameter Name: Name of the home location.
    /// - Parameter Location" Location of the home location.
    public static func AddHome(ID: UUID, Name: String, Location: GeoPoint)
    {
        let UserHome = DisplayItem(ID: ID, ItemType: .Home, Name: Name,
                                  Numeric: 0.0, Location: Location)
        HomeTable[UserHome.ID] = UserHome
    }
    
    /// Deletes all home data.
    public static func RemoveUserHome()
    {
        HomeTable.removeAll()
    }
    
    /// Determines the class type of the pass item ID.
    /// - Parameter Item: The item ID whose class type is returned.
    /// - Returns: The item type of the passed ID.
    public static func LocationClass(Item ID: UUID) -> ItemTypes
    {
        if QuakeTable[ID] != nil
        {
            return .Earthquake
        }
        if CityTable[ID] != nil
        {
            return .City
        }
        if HomeTable[ID] != nil
        {
            return .Home
        }
        if POITable[ID] != nil
        {
            return .UserPOI
        }
        if UNESCOTable[ID] != nil
        {
            return .WorldHeritageSite
        }
        return .Unknown
    }
    
    /// Return the associated data for the passed ID.
    /// - Parameter For: The ID of the item whose data will be returned.
    /// - Returns: The associated data on success, nil if not found.
    public static func GetItemData(For ID: UUID) -> DisplayItem?
    {
        let TableType = LocationClass(Item: ID)
        switch TableType
        {
            case .City:
                return CityTable[ID]
                
            case .Earthquake:
                return QuakeTable[ID]
                
            case .Home:
                return HomeTable[ID]
                
            case .UserPOI:
                return POITable[ID]
                
            case .WorldHeritageSite:
                return UNESCOTable[ID]
                
            default:
                return nil
        }
        return nil
    }
    
    /// Get the number of entries in a class table.
    /// - Parameter For: Identifies the class whose entry count is returned.
    /// - Returns: Number of entries for the specified class. Nil if the class is not defined.
    public static func TableCount(For: NodeClasses) -> Int?
    {
        switch For
        {
            case .City:
                return CityTable.count
                
            case .Earthquake:
                return QuakeTable.count
                
            case .HomeLocation:
                return HomeTable.count
                
            case .UserPOI:
                return POITable.count
                
            case .WorldHeritageSite:
                return UNESCOTable.count
                
            default:
                return nil
        }
    }
    
    private static var QuakeTable = [UUID: DisplayItem]()
    private static var CityTable = [UUID: DisplayItem]()
    private static var POITable = [UUID: DisplayItem]()
    private static var HomeTable = [UUID: DisplayItem]()
    private static var UNESCOTable = [UUID: DisplayItem]()
    
    /// Mapping from class ID to ItemType.
    private static let ClassToItemType =
    [
        UUID(uuidString: NodeClasses.Unknown.rawValue)!: ItemTypes.Unknown,
        UUID(uuidString: NodeClasses.City.rawValue)!: ItemTypes.City,
        UUID(uuidString: NodeClasses.Earthquake.rawValue)!: ItemTypes.Earthquake,
        UUID(uuidString: NodeClasses.HomeLocation.rawValue)!: ItemTypes.Home,
        UUID(uuidString: NodeClasses.UserPOI.rawValue)!: ItemTypes.UserPOI,
        UUID(uuidString: NodeClasses.WorldHeritageSite.rawValue)!: ItemTypes.WorldHeritageSite
    ]
    
    /// The home ID.
    public static let HomeID = UUID()
}

/// Information to display to the user.
class DisplayItem
{
    /// Initializer.
    /// - Parameter ID: The ID of the owning item.
    /// - Parameter ItemType: The item type of the owning item.
    /// - Parameter Name: The name of the item.
    /// - Parameter Numeric: The numeric value (when appropriate) of the item.
    /// - Parameter Location: The geographic location of the item.
    /// - Parameter Description: The description of the item.
    init(ID: UUID, ItemType: ItemTypes, Name: String, Numeric: Double, Location: GeoPoint?,
         Description: String = "")
    {
        self.ID = ID
        self.ItemType = ItemType
        self.Name = Name
        self.Numeric = Numeric
        self.Location = Location
        self.Description = Description
    }
    
    var ID: UUID = UUID()
    var ItemType: ItemTypes = .Unknown
    var Name: String = ""
    var Numeric: Double = 0.0
    var Location: GeoPoint? = nil
    var Description: String = ""
}

enum ItemTypes: String, CaseIterable
{
    case Unknown = "Unknown"
    case City = "City"
    case Home = "Home"
    case UserPOI = "User POI"
    case Earthquake = "Earthquake"
    case WorldHeritageSite = "World Heritage Site"
}

enum NodeClasses: String, CaseIterable
{
    case Unknown = "5f893956-1f90-468a-8475-f066824af425"
    case City = "8d4e5448-943e-4feb-a2e0-e83ab8bcd0b4"
    case UserPOI = "8b0437b8-24fd-4813-b8c6-af78c9dfd1a4"
    case HomeLocation = "21599d45-7ace-47f1-ad40-f302b019dc2c"
    case Earthquake = "fff542af-daf9-4629-8325-a26d8e54b427"
    case WorldHeritageSite = "f0b85fc5-c761-4b74-91fc-5b79b3d7d606"
}

