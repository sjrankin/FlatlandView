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
        var CityTable = [UUID: DisplayItem]()
        for SomeCity in CitiesData.RawCityList
        {
            CityTable[SomeCity.CityID] = DisplayItem(ID: SomeCity.CityID, ItemType: .City, Name: SomeCity.Name,
                                                     Numeric: Double(SomeCity.GetPopulation()),
                                                     Location: GeoPoint(SomeCity.Latitude, SomeCity.Longitude),
                                                     Description: "")
        }
        Tables[UUID(uuidString: NodeClasses.City.rawValue)!] = CityTable
        
        var UnescoTable = [UUID: DisplayItem]()
        for Site in Unesco
        {
            UnescoTable[Site.InternalID] = DisplayItem(ID: Site.InternalID, ItemType: .WorldHeritageSite,
                                                       Name: Site.Name, Numeric: Double(Site.DateInscribed),
                                                       Location: GeoPoint(Site.Latitude, Site.Longitude),
                                                       Description: Site.Category)
        }
        Tables[UUID(uuidString: NodeClasses.WorldHeritageSite.rawValue)!] = UnescoTable
    }
    
    /// Add an earthquake to the earthquake item table.
    /// - Parameter Quake: The earthquake to add to the table. Duplicate earthquakes overwrite previous
    ///                    earthquakes.
    public static func AddEarthquake(_ Quake: Earthquake)
    {
        let QItem = DisplayItem(ID: Quake.ID, ItemType: .Earthquake, Name: "",
                                Numeric: Quake.Magnitude, Location: Quake.LocationAsGeoPoint(),
                                Description: Quake.Place)
        if var QuakeTable = Tables[UUID(uuidString: NodeClasses.Earthquake.rawValue)!]
        {
            QuakeTable[QItem.ID] = QItem
        }
        else
        {
            var QTable = [UUID: DisplayItem]()
            QTable[QItem.ID] = QItem
            Tables[UUID(uuidString: NodeClasses.Earthquake.rawValue)!] = QTable
        }
    }
    
    /// Deletes all earthquakes.
    public static func ClearEarthquakes()
    {
        Tables.removeValue(forKey: UUID(uuidString: NodeClasses.Earthquake.rawValue)!)
    }
    
    /// Add user points of interesting.
    /// - Parameter ID: The ID of the user POI.
    /// - Parameter Name: The name of the user POI.
    /// - Parameter Location: The location of the user POI.
    public static func AddUserPOI(ID: UUID, Name: String, Location: GeoPoint)
    {
        let UserPOI = DisplayItem(ID: ID, ItemType: .UserPOI, Name: Name,
                                  Numeric: 0.0, Location: Location)
        if var POITable = Tables[UUID(uuidString: NodeClasses.UserPOI.rawValue)!]
        {
            POITable[UserPOI.ID] = UserPOI
        }
        else
        {
            var PTable = [UUID: DisplayItem]()
            PTable[UserPOI.ID] = UserPOI
            Tables[UUID(uuidString: NodeClasses.UserPOI.rawValue)!] = PTable
        }
    }
    
    /// Deletes all user POIs.
    public static func RemoveUserPOI()
    {
        Tables.removeValue(forKey: UUID(uuidString: NodeClasses.UserPOI.rawValue)!)
    }
    
    public static func AddHome(ID: UUID, Name: String, Location: GeoPoint)
    {
        let UserHome = DisplayItem(ID: ID, ItemType: .Home, Name: Name,
                                  Numeric: 0.0, Location: Location)
        if var HomeTable = Tables[UUID(uuidString: NodeClasses.HomeLocation.rawValue)!]
        {
            HomeTable[UserHome.ID] = UserHome
        }
        else
        {
            var HTable = [UUID: DisplayItem]()
            HTable[UserHome.ID] = UserHome
            Tables[UUID(uuidString: NodeClasses.HomeLocation.rawValue)!] = HTable
        }
    }
    
    /// Deletes all home data.
    public static func RemoveUserHome()
    {
        Tables.removeValue(forKey: UUID(uuidString: NodeClasses.HomeLocation.rawValue)!)
    }
    
    
    /// Determines the class type of the pass item ID.
    /// - Parameter Item: The item ID whose class type is returned.
    /// - Returns: The item type of the passed ID.
    public static func LocationClass(Item ID: UUID) -> ItemTypes
    {
        for (TypeClass, ItemsInClass) in Tables
        {
            if ItemsInClass.keys.contains(ID)
            {
                if let ItemIsOfType = ClassToItemType[TypeClass]
                {
                    return ItemIsOfType
                }
                else
                {
                    return .Unknown
                }
            }
        }
        return .Unknown
    }
    
    /// Return the associated data for the passed ID.
    /// - Parameter For: The ID of the item whose data will be returned.
    /// - Returns: The associated data on success, nil if not found.
    public static func GetItemData(For ID: UUID) -> DisplayItem?
    {
        for (_, ItemsInClass) in Tables
        {
            if ItemsInClass.keys.contains(ID)
            {
                return ItemsInClass[ID]
            }
        }
        return nil
    }
    
    /// Holds IDs and associated data in a dictionary of class IDs.
    private static var Tables = [UUID: [UUID: DisplayItem]]()
    
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

