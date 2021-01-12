//
//  Locations.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Location helper functions.
class Locations
{
    public weak var Main: MainProtocol? = nil
    
    /// Search for a location with the passed name.
    /// - Parameter FindMe: The name of the location to find.
    /// - Parameter Compressed: If true, all spaces in `FindMe` have been removed.
    /// - Parameter CaseSensitive: Determines case sensitivity of comparison.
    /// - Parameter ForAnyIn: Determines where to look for the location. If `.Earthquake` is specified in the
    ///                       array, it is ignored.
    /// - Returns: Meta location data if found, nil if not found.
    func SearchFor(_ FindMe: String, Compressed: Bool = false, CaseSensitive: Bool = false,
                   ForAnyIn: [LocationTypes] = []) -> MetaLocation?
    {
        var LookIn = ForAnyIn
        if LookIn.isEmpty
        {
            for SomeType in LocationTypes.allCases
            {
                LookIn.append(SomeType)
            }
        }
        
        var SearchName = FindMe
        if !CaseSensitive
        {
            SearchName = SearchName.lowercased()
        }
        if Compressed
        {
            SearchName = SearchName.replacingOccurrences(of: " ", with: "")
        }
        
        for SearchType in LookIn
        {
            switch SearchType
            {
                case .City:
                    for City in CityManager.AllCities!
                    {
                        var CityNameTest = City.Name
                        if !CaseSensitive
                        {
                            CityNameTest = CityNameTest.lowercased()
                        }
                        if Compressed
                        {
                            CityNameTest = CityNameTest.replacingOccurrences(of: " ", with: "")
                        }
                        if SearchName == CityNameTest
                        {
                            let CityRecord = MetaLocation(ID: City.CityID,
                                                          Name: City.Name,
                                                          Latitude: City.Latitude,
                                                          Longitude: City.Longitude,
                                                          Population: City.GetPopulation(),
                                                          LocationType: .City)
                            return CityRecord
                        }
                    }
                    
                case .Home:
                    if SearchName.lowercased() == "home"
                    {
                        if Settings.HaveLocalLocation()
                        {
                            let HomeRecord = MetaLocation(ID: nil,
                                                          Name: Settings.GetString(.UserHomeName, ""),
                                                          Latitude: Settings.GetDoubleNil(.UserHomeLatitude, 0.0)!,
                                                          Longitude: Settings.GetDoubleNil(.UserHomeLongitude, 0.0)!,
                                                          Population: 0,
                                                          LocationType: .Home)
                            return HomeRecord
                        }
                    }
                    
                case .UNESCO:
                    if let WHS = Main?.GetWorldHeritageSites()
                    {
                        for Site in WHS
                        {
                            var SiteName = Site.Name
                            if !CaseSensitive
                            {
                                SiteName = SiteName.lowercased()
                            }
                            if Compressed
                            {
                                SiteName = SiteName.replacingOccurrences(of: " ", with: "")
                            }
                            if SiteName == SearchName
                            {
                                let WHSRecord = MetaLocation(ID: Site.RuntimeID ?? UUID.Empty,
                                                             Name: Site.Name,
                                                             Latitude: Site.Latitude,
                                                             Longitude: Site.Longitude,
                                                             Population: 0,
                                                             LocationType: .UNESCO)
                                return WHSRecord
                            }
                        }
                    }
                    
                case .UserPOI:
                    let UserPOIs = Settings.GetLocations()
                    for Location in UserPOIs
                    {
                        var NameTest = Location.Name
                        if !CaseSensitive
                        {
                            NameTest = NameTest.lowercased()
                        }
                        if Compressed
                        {
                            NameTest = NameTest.replacingOccurrences(of: " ", with: "")
                        }
                        if NameTest == SearchName
                        {
                            let POIRecord = MetaLocation(ID: Location.ID,
                                                         Name: Location.Name,
                                                         Latitude: Location.Coordinates.Latitude,
                                                         Longitude: Location.Coordinates.Longitude,
                                                         Population: 0,
                                                         LocationType: .UserPOI)
                            return POIRecord
                        }
                    }
                    
                default:
                    continue
            }
        }
        
        return nil
    }
    
    /// Returns a list of places that are close to the passed latitude and longitude. Places are defined in:
    /// cities, user points of interest, user home locations, UNESCO World Heritage Sites, earthquakes.
    /// - Parameter Latitude: The latitude of the location.
    /// - Parameter Longitude: The longitude of the location.
    /// - Parameter CloseIs: Determines the radial value to determine closeness, in kilometers.
    /// - Parameter ForLocations: Array of types of locations to search. If an empty array is passed, all
    ///                           location types are searched.
    /// - Returns: Array of locations that fall within `CloseIs` kilometers of the passed location. If empty
    ///            no known locations were found close to the passed coordinate.
    func WhatIsCloseTo(Latitude: Double, Longitude: Double, CloseIs: Double = 50.0,
                       ForLocations: [LocationTypes]) -> [MetaLocation]
    {
        var Results = [MetaLocation]()
        var SearchInTypes = ForLocations
        if SearchInTypes.count < 1
        {
            for LType in LocationTypes.allCases
            {
                SearchInTypes.append(LType)
            }
        }
        
        var QuakeList = [Earthquake]()
        if SearchInTypes.contains(.Earthquake)
        {
            if Main == nil
            {
                print("No main delegate")
            }
            else
            {
                QuakeList = Main!.GetCurrentEarthquakes()
                QuakeList = QuakeList.filter({$0.Magnitude >= 5.0})
            }
        }
        
        for SearchType in SearchInTypes
        {
            switch SearchType
            {
                case .City:
                    for City in CityManager.AllCities!
                    {
                        let Distance = Geometry.HaversineDistance(Latitude1: Latitude, Longitude1: Longitude,
                                                                  Latitude2: City.Latitude, Longitude2: City.Longitude) / 1000.0
                        if Distance <= CloseIs
                        {
                            let CityRecord = MetaLocation(ID: City.CityID,
                                                          Name: City.Name,
                                                          Latitude: City.Latitude,
                                                          Longitude: City.Longitude,
                                                          Population: City.GetPopulation(),
                                                          LocationType: .City,
                                                          Distance: Distance)
                            Results.append(CityRecord)
                        }
                    }
                    
                case .Earthquake:
                    for Quake in QuakeList
                    {
                        if Quake.Magnitude >= 5.0
                        {
                            let Distance = Geometry.HaversineDistance(Latitude1: Latitude, Longitude1: Longitude,
                                                                      Latitude2: Quake.Latitude, Longitude2: Quake.Longitude) / 1000.0
                            if Distance <= CloseIs
                            {
                                let QuakeRecord = MetaLocation(ID: Quake.ID,
                                                               Name: Quake.Title,
                                                               Latitude: Quake.Latitude,
                                                               Longitude: Quake.Longitude,
                                                               Population: 0,
                                                               LocationType: .Earthquake,
                                                               Distance: Distance)
                                Results.append(QuakeRecord)
                            }
                        }
                    }
                    
                case .Home:
                    if Settings.HaveLocalLocation()
                    {
                        let Distance = Geometry.HaversineDistance(Latitude1: Latitude, Longitude1: Longitude,
                                                                  Latitude2: Settings.GetDoubleNil(.UserHomeLatitude, 0.0)!,
                                                                  Longitude2: Settings.GetDoubleNil(.UserHomeLongitude, 0.0)!) / 1000.0
                        if Distance <= CloseIs
                        {
                            //Use a fake ID because home locations don't have IDs.
                            if Settings.GetBool(.ShowHomeLocation)
                            {
                                if Settings.HomeLocationSet()
                                {
                                    if let HomeName = Settings.GetSecureString(.UserHomeName)
                                    {
                                        let HomeLatitudeS = Settings.GetSecureString(.UserHomeLatitude)
                                        let HomeLongitudeS = Settings.GetSecureString(.UserHomeLongitude)
                                        let HomeLatitude = Double(HomeLatitudeS!)
                                        let HomeLongitude = Double(HomeLongitudeS!)
                                        let HomeRecord = MetaLocation(ID: UUID(),
                                                                      Name: HomeName,
                                                                      Latitude: HomeLatitude!,
                                                                      Longitude: HomeLongitude!,
                                                                      Population: 0,
                                                                      LocationType: .Home,
                                                                      Distance: Distance)
                                        Results.append(HomeRecord)
                                    }
                                }
                            }
                        }
                    }
                    
                case .Region:
                    //Regions are returned only if the mouse is actually in the region.
                    let Regions = Settings.GetEarthquakeRegions()
                    for SomeRegion in Regions
                    {
                        if SomeRegion.InRegion(Latitude: Latitude, Longitude: Longitude)
                        {
                            let RgnRecord = MetaLocation(ID: SomeRegion.ID,
                                                         Name: SomeRegion.RegionName,
                                                         Latitude: SomeRegion.Center.Latitude,
                                                         Longitude: SomeRegion.Center.Longitude,
                                                         Population: 0,
                                                         LocationType: .Region,
                                                         Distance: 0)
                            Results.append(RgnRecord)
                        }
                    }
                    
                case .UNESCO:
                    if let WHS = Main?.GetWorldHeritageSites()
                    {
                        for Site in WHS
                        {
                            let Distance = Geometry.HaversineDistance(Latitude1: Latitude, Longitude1: Longitude,
                                                                      Latitude2: Site.Latitude, Longitude2: Site.Longitude) / 1000.0
                            if Distance <= CloseIs
                            {
                                let WHSRecord = MetaLocation(ID: Site.RuntimeID ?? UUID.Empty,
                                                             Name: Site.Name,
                                                             Latitude: Site.Latitude,
                                                             Longitude: Site.Longitude,
                                                             Population: 0,
                                                             LocationType: .UNESCO,
                                                             Distance: Distance)
                                Results.append(WHSRecord)
                            }
                        }
                    }
                    
                case .UserPOI:
                    let UserPOIs = Settings.GetLocations()
                    for Location in UserPOIs
                    {
                        let Distance = Geometry.HaversineDistance(Latitude1: Latitude, Longitude1: Longitude,
                                                                  Latitude2: Location.Coordinates.Latitude,
                                                                  Longitude2: Location.Coordinates.Longitude) / 1000.0
                        if Distance <= CloseIs
                        {
                            let POIRecord = MetaLocation(ID: Location.ID,
                                                         Name: Location.Name,
                                                         Latitude: Location.Coordinates.Latitude,
                                                         Longitude: Location.Coordinates.Longitude,
                                                         Population: 0,
                                                         LocationType: .UserPOI,
                                                         Distance: Distance)
                            Results.append(POIRecord)
                        }
                    }
                    
                case .UserPoint:
                    break
            }
        }
        Results = RemoveDuplicates(From: Results)
        return Results
    }
    
    /// Remove duplicats from the passed list of meta locations.
    /// - Note: Duplicates are defined as locations with the same ID.
    /// - Parameter From: The list of meta locations.
    /// - Returns: Array of meta locations with duplicates removed.
    func RemoveDuplicates(From: [MetaLocation]) -> [MetaLocation]
    {
        var LocationMap = [UUID: MetaLocation]()
        for Location in From
        {
            if let ID = Location.ID
            {
                LocationMap[ID] = Location
            }
            else
            {
                print("Location \(Location.Name) has no ID")
            }
        }
        var Final = [MetaLocation]()
        for (_, Where) in LocationMap
        {
            Final.append(Where)
        }
        return Final
    }
}

/// Types of locations.
enum LocationTypes: String, CaseIterable
{
    /// City location.
    case City = "City"
    /// UNESCO World Heritage Site (all types).
    case UNESCO = "UNESCO"
    /// User point of interest.
    case UserPOI = "UserPOI"
    /// User home location.
    case Home = "Home"
    /// Earthquake.
    case Earthquake = "Earthquake"
    /// User-defined region.
    case Region = "Region"
    /// User-defined point used for transient purposes.
    case UserPoint = "UserPoint"
}

/// Meta location structure.
struct MetaLocation
{
    /// ID of the location.
    var ID: UUID? = nil
    /// Name of the location.
    var Name: String = ""
    /// Latitude of the location.
    var Latitude: Double = 0.0
    /// Longitude of the location.
    var Longitude: Double = 0.0
    /// Population of the location.
    var Population: Int = 0
    /// Location type of the location.
    var LocationType: LocationTypes = .City
    /// Distances from the search location in kilometers.
    var Distance: Double = 0.0
}
