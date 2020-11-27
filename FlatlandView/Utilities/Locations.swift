//
//  Locations.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class Locations
{
    public weak var Main: MainProtocol? = nil
    
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
                                                          Name: Settings.GetString(.LocalName, ""),
                                                          Latitude: Settings.GetDoubleNil(.LocalLatitude, 0.0)!,
                                                          Longitude: Settings.GetDoubleNil(.LocalLongitude, 0.0)!,
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
            }
        }
        
        return nil
    }
}

enum LocationTypes: String, CaseIterable
{
    case City = "City"
    case UNESCO = "UNESCO"
    case UserPOI = "UserPOI"
    case Home = "Home"
}

struct MetaLocation
{
    var ID: UUID? = nil
    var Name: String = ""
    var Latitude: Double = 0.0
    var Longitude: Double = 0.0
    var Population: Int = 0
    var LocationType: LocationTypes = .City
}
