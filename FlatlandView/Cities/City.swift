//
//  City.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SQLite3

/// Encapsulates one city.
class City
{
    /// Initializer.
    /// - Parameters:
    ///   - Continent: Name of the continent of the city.
    ///   - Country: The country where the city is.
    ///   - Name: The name of the city.
    ///   - Population: The population of the city or nil if not known.
    ///   - MetroPopulation: The population of the metropolitan area or nil if not known.
    ///   - Latitude: The latitude of the city.
    ///   - Longitude: The longitude of the city.
    ///   - IsCapital: Capital city flag.
    init(Continent: String, Country: String, Name: String, Population: Int?, MetroPopulation: Int?,
         Latitude: Double, Longitude: Double, IsCapital: Bool = false)
    {
        self.Continent = Continents(rawValue: Continent)!
        self.Country = Country
        self.Name = Name
        self.IsCapital = IsCapital
        self.Population = Population
        self.MetropolitanPopulation = MetroPopulation
        self.Latitude = Latitude
        self.Longitude = Longitude
    }
    
    /// Initializer.
    /// - Parameters:
    ///   - Name: The name of the city.
    ///   - Country: The country where the city is.
    ///   - IsCapital: Capital city flag.
    ///   - Population: The population of the city or nil if not known.
    ///   - MetroPopulation: The population of the metropolitan area or nil if not known.
    ///   - Latitude: The latitude of the city.
    ///   - Longitude: The longitude of the city.
    ///   - Continent: Name of the continent of the city.
    init(_ Name: String, _ Country: String, _ IsCapital: Bool, _ Population: Int?, _ MetroPopulation: Int?,
         _ Latitude: Double, _ Longitude: Double, _ Continent: String)
    {
        self.Continent = Continents(rawValue: Continent)!
        self.Country = Country
        self.Name = Name
        self.IsCapital = IsCapital
        self.Population = Population
        self.MetropolitanPopulation = MetroPopulation
        self.Latitude = Latitude
        self.Longitude = Longitude
    }
    
    /// Initializer.
    /// - Parameters:
    ///   - Name: The name of the city.
    ///   - Country: The country where the city is.
    ///   - IsCapital: Capital city flag.
    ///   - Population: The population of the city or nil if not known.
    ///   - MetroPopulation: The population of the metropolitan area or nil if not known.
    ///   - Latitude: The latitude of the city.
    ///   - Longitude: The longitude of the city.
    ///   - Continent: Name of the continent of the city.
    ///   - ID: ID of the city.
    init(_ Name: String, _ Country: String, _ IsCapital: Bool, _ Population: Int?, _ MetroPopulation: Int?,
         _ Latitude: Double, _ Longitude: Double, _ Continent: String, ID: UUID)
    {
        self.Continent = Continents(rawValue: Continent)!
        self.Country = Country
        self.Name = Name
        self.IsCapital = IsCapital
        self.Population = Population
        self.MetropolitanPopulation = MetroPopulation
        self.Latitude = Latitude
        self.Longitude = Longitude
        self.CityID = ID
    }
    
    /// Convenience property that holds a base-line location of the city after it was initially plotted.
    public var PlottedPoint: CGPoint? = nil
    
    /// City name.
    public var Name: String = ""
    
    /// Country name.
    public var Country: String = ""
    
    /// Capital city flag.
    public var IsCapital: Bool = false
    
    /// Population of the city. Nil if not known.
    public var Population: Int? = nil
    
    /// Population of the metropolitan area, or nil if not known.
    public var MetropolitanPopulation: Int? = nil
    
    /// Latitude of the city.
    public var Latitude: Double = 0.0
    
    /// Longitude of the city.
    public var Longitude: Double = 0.0
    
    /// Continent of the city.
    public var Continent: Continents = .Asia
    
    /// Color to use to render the city.
    public var CityColor: NSColor = NSColor.yellow 
    
    /// User city flag.
    public var IsUserCity: Bool = false
    
    /// City ID.
    public var CityID: UUID = UUID()
    
    /// Used by the UI when creating custom city lists.
    public var IsCustomCity: Bool = false
    
    /// Return a population for the city. Always returns a value.
    /// - Parameter MetroPopulation: If true, the metropolitan population is returned.
    /// - Returns: Population of the city. If `MetroPopulation` is true and there is no metropolitan
    ///            population available, the city population is returned. If no city population is
    ///            available, `0` is returned.
    public func GetPopulation(_ MetroPopulation: Bool = true) -> Int
    {
        if MetroPopulation
        {
            if let Metro = MetropolitanPopulation
            {
                return Metro
            }
            else
            {
                if let CityPop = Population
                {
                    return CityPop
                }
            }
        }
        else
        {
            if let CityPop = Population
            {
                return CityPop
            }
        }
        return 0
    }
}

