//
//  Cities.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SQLite3

/// Holds and manages the list of cities.
class Cities
{
    /// Default initializer.
    init()
    {
        _AllCities = CitiesData.RawCityList
    }
    
    /// Search for a city with the passed name.
    /// - Parameter Name: The name of the city. Case insensitive.
    /// - Returns: The city's record if found, nil if not.
    public func FindCity(Name: String) -> City?
    {
        return FindCity(In: _AllCities, WithName: Name)
    }
    
    /// Search for a city with the passed name.
    /// - Parameter In: The list of cities to search.
    /// - Parameter WithName: The name of the city. Case insensitive.
    /// - Returns: The city's record if found, nil if not.
    public func FindCity(In SourceList: [City], WithName: String) -> City?
    {
        for SomeCity in SourceList
        {
            if SomeCity.Name.lowercased() == WithName.lowercased()
            {
                return SomeCity
            }
        }
        return nil
    }
    
    /// Returns all capital cities.
    /// - Parameter DoSort: If true, cities are returned in name-sorted order.
    /// - Returns: All cities marked as a capital city.
    public func AllCapitalCities(DoSort: Bool = false) -> [City]
    {
        return AllCapitalCities(In: _AllCities, DoSort: DoSort)
    }
    
    /// Returns all capital cities in the passed city list.
    /// - Parameter In: The list of cities to search for capital cities.
    /// - Parameter DoSort: If true, cities are returned in name-sorted order.
    /// - Returns: All cities marked as a capital city.
    public func AllCapitalCities(In SourceList: [City], DoSort: Bool = false) -> [City]
    {
        var CapitalCities = [City]()
        for SomeCity in SourceList
        {
            if SomeCity.IsCapital
            {
                CapitalCities.append(SomeCity)
            }
        }
        if DoSort
        {
            CapitalCities.sort(by: {$0.Name < $1.Name})
        }
        return CapitalCities
    }
    
    /// Return a list of all cities with a metropolitan population.
    /// - Parameter DoSort: If true, the returned list will be sorted in metropolitan population order.
    /// - Returns: List of all cities with a metropolitan population.
    public func AllMetroAreas(DoSort: Bool = false) -> [City]
    {
        return AllMetroAreas(In: _AllCities, DoSort: DoSort)
    }
    
    /// Return a list of all cities with a metropolitan population.
    /// - Parameter In: The list of cities to search.
    /// - Parameter DoSort: If true, the returned list will be sorted in metropolitan population order.
    /// - Returns: List of all cities with a metropolitan population.
    public func AllMetroAreas(In SourceList: [City], DoSort: Bool = false) -> [City]
    {
        var MetroAreas = [City]()
        for SomeCity in SourceList
        {
            if SomeCity.MetropolitanPopulation != nil
            {
                MetroAreas.append(SomeCity)
            }
        }
        if DoSort
        {
            MetroAreas.sort(by: {$0.MetropolitanPopulation! < $1.MetropolitanPopulation!})
        }
        return MetroAreas
    }
    
    /// Returns a list of all cities in the supplied continent.
    /// - Parameter Continent: The continent whose cities will be returned.
    /// - Parameter DoSort: If true, the returned list will be sorted in city names.
    /// - Returns: List of cities in the specified continent.
    public func CitiesIn(_ Continent: Continents, DoSort: Bool = false) -> [City]
    {
        return CitiesIn(In: _AllCities, Continent: Continent, DoSort: DoSort)
    }
    
    /// Returns a list of all cities in the supplied continent.
    /// - Parameter In: List of cities to search.
    /// - Parameter Continent: The continent whose cities will be returned.
    /// - Parameter DoSort: If true, the returned list will be sorted in city names.
    /// - Returns: List of cities in the specified continent.
    public func CitiesIn(In SourceList: [City], Continent: Continents, DoSort: Bool = false) -> [City]
    {
        var ContinentalCities = [City]()
        for SomeCity in SourceList
        {
            if SomeCity.Continent == Continent
            {
                ContinentalCities.append(SomeCity)
            }
        }
        if DoSort
        {
            ContinentalCities.sort(by: {$0.Name < $1.Name})
        }
        return ContinentalCities
    }
    
    /// Returns a list of all cities in the supplied country.
    /// - Parameter Country: The continent whose cities will be returned. Country names are
    ///                      case insensitive
    /// - Parameter DoSort: If true, the returned list will be sorted in city names.
    /// - Returns: List of cities in the specified country.
    public func CitiesIn(Country: String, DoSort: Bool = false) -> [City]
    {
        return CitiesIn(In: _AllCities, Country: Country, DoSort: DoSort)
    }
    
    /// Returns a list of all cities in the supplied country.
    /// - Parameter In: The list of cities to search.
    /// - Parameter Country: The continent whose cities will be returned. Country names are
    ///                      case insensitive
    /// - Parameter DoSort: If true, the returned list will be sorted in city names.
    /// - Returns: List of cities in the specified country.
    public func CitiesIn(In SourceList: [City], Country: String, DoSort: Bool = false) -> [City]
    {
        var CountryCities = [City]()
        for SomeCity in SourceList
        {
            if SomeCity.Country.lowercased() == Country.lowercased()
            {
                CountryCities.append(SomeCity)
            }
        }
        if DoSort
        {
            CountryCities.sort(by: {$0.Name < $1.Name})
        }
        return CountryCities
    }
    
    /// Return a list of cities whose population is greater than or equal to the passed value.
    /// - Parameter GreaterThan: The minimum value the population of the city must be to be included in the returned list.
    /// - Parameter UseMetroPopulation: If true, the metropolitan population is used. Otherwise, the city population
    ///                                 is used. In either case, if the population value is nil, it will not be
    ///                                 included in the returned list.
    /// - Parameter DoSort: If true, the returned list is sorted in name order.
    /// - Returns: List of cities whose population is greater than or equal to `GreaterThan`.
    public func CitiesByPopulation(GreaterThan: Int, UseMetroPopulation: Bool, DoSort: Bool = false) -> [City]
    {
        return CitiesByPopulation(In: _AllCities, GreaterThan: GreaterThan, UseMetroPopulation: UseMetroPopulation, DoSort: DoSort)
    }
    
    /// Return a list of cities whose population is greater than or equal to the passed value.
    /// - Parameter In: List of cities to search.
    /// - Parameter GreaterThan: The minimum value the population of the city must be to be included in the returned list.
    /// - Parameter UseMetroPopulation: If true, the metropolitan population is used. Otherwise, the city population
    ///                                 is used. In either case, if the population value is nil, it will not be
    ///                                 included in the returned list.
    /// - Parameter DoSort: If true, the returned list is sorted in name order.
    /// - Returns: List of cities whose population is greater than or equal to `GreaterThan`.
    public func CitiesByPopulation(In SourceList: [City], GreaterThan: Int, UseMetroPopulation: Bool, DoSort: Bool = false) -> [City]
    {
        var CityList = [City]()
        for SomeCity in SourceList
        {
            if UseMetroPopulation
            {
                if let Population = SomeCity.MetropolitanPopulation
                {
                    if Population >= GreaterThan
                    {
                        CityList.append(SomeCity)
                    }
                }
            }
            else
            {
                if let Population = SomeCity.Population
                {
                    if Population >= GreaterThan
                    {
                        CityList.append(SomeCity)
                    }
                }
            }
        }
        if DoSort
        {
            CityList.sort(by: {$0.Name < $1.Name})
        }
        return CityList
    }
    
    /// Return a list of cities whose population is less than the passed value.
    /// - Parameter LessThan: The maximum value the population of the city must be to be included in the returned list.
    /// - Parameter UseMetroPopulation: If true, the metropolitan population is used. Otherwise, the city population
    ///                                 is used. In either case, if the population value is nil, it will not be
    ///                                 included in the returned list.
    /// - Parameter DoSort: If true, the returned list is sorted in name order.
    /// - Returns: List of cities whose population is less than `LessThan`.
    public func CitiesByPopulation(LessThan: Int, UseMetroPopulation: Bool, DoSort: Bool = false) -> [City]
    {
        return CitiesByPopulation(In: _AllCities, LessThan: LessThan, UseMetroPopulation: UseMetroPopulation, DoSort: DoSort)
    }
    
    /// Return a list of cities whose population is less than the passed value.
    /// - Parameter In: The list of cities to search.
    /// - Parameter LessThan: The maximum value the population of the city must be to be included in the returned list.
    /// - Parameter UseMetroPopulation: If true, the metropolitan population is used. Otherwise, the city population
    ///                                 is used. In either case, if the population value is nil, it will not be
    ///                                 included in the returned list.
    /// - Parameter DoSort: If true, the returned list is sorted in name order.
    /// - Returns: List of cities whose population is less than `LessThan`.
    public func CitiesByPopulation(In SourceList: [City], LessThan: Int, UseMetroPopulation: Bool, DoSort: Bool = false) -> [City]
    {
        var CityList = [City]()
        for SomeCity in SourceList
        {
            if UseMetroPopulation
            {
                if let Population = SomeCity.MetropolitanPopulation
                {
                    if Population < LessThan
                    {
                        CityList.append(SomeCity)
                    }
                }
            }
            else
            {
                if let Population = SomeCity.Population
                {
                    if Population < LessThan
                    {
                        CityList.append(SomeCity)
                    }
                }
            }
        }
        if DoSort
        {
            CityList.sort(by: {$0.Name < $1.Name})
        }
        return CityList
    }
    
    /// Returns the most populated city in the passed list of cities.
    /// - Parameter In: The list of cities to test.
    /// - Parameter UseMetroPopulation: If true, metropolitan populations are used. If a city does
    ///                                 not have a metropolitcan population, the normal city population
    ///                                 is used instead. Defaults to `true`.
    /// - Returns: The city with the greatest population in the passed list. Nil if none found.
    public static func MostPopulatedCity(In List: [City], UseMetroPopulation: Bool = true) -> City?
    {
        var Population = 0
        var TheCity: City? = nil
        for SomeCity in List
        {
            if UseMetroPopulation
            {
                if let Metro = SomeCity.MetropolitanPopulation
                {
                    if Metro > Population
                    {
                        Population = Metro
                        TheCity = SomeCity
                    }
                }
                else
                {
                    if let CityPop = SomeCity.Population
                    {
                        if CityPop > Population
                        {
                            Population = CityPop
                            TheCity = SomeCity
                        }
                    }
                }
            }
            else
            {
                if let CityPop = SomeCity.Population
                {
                    if CityPop > Population
                    {
                        Population = CityPop
                        TheCity = SomeCity
                    }
                }
            }
        }
        return TheCity
    }
    
    /// Returns the population of the most populated city in the passed list.
    /// - Parameter In: The list of cities to test.
    /// - Parameter UseMetroPopulation: If true, metropolitan populations are used. If a city does
    ///                                 not have a metropolitcan population, the normal city population
    ///                                 is used instead. Defaults to `true`.
    /// - Returns: The population of the most populated city in the list. If `UseMetroPopulation` is
    ///            true but the city does not have a metropolitan population, the city population is
    ///            returned. If the city does not have a city population, 0 is returned.
    public static func MostPopulatedCityPopulation(In List: [City], UseMetroPopulation: Bool = true) -> Int
    {
        if let PopulatedCity = MostPopulatedCity(In: List, UseMetroPopulation: UseMetroPopulation)
        {
            if UseMetroPopulation
            {
                if let Metro = PopulatedCity.MetropolitanPopulation
                {
                    return Metro
                }
                else
                {
                    if let CityPop = PopulatedCity.Population
                    {
                        return CityPop
                    }
                }
            }
            else
            {
                if let CityPop = PopulatedCity.Population
                {
                    return CityPop
                }
            }
        }
        return 0
    }
    
    /// Returns a list of cities that have a metropolitan population associated with it. All known
    /// cities are searched.
    /// - Returns: List of cities with a valid metropolitan population.
    public func CitiesWithMetroPopulation() -> [City]
    {
        return CitiesWithMetroPopulation(In: _AllCities)
    }
    
    /// Returns a list of cities from `In` that have a metropolitan population associated.
    /// - Returns: List of cities in `In` that have a valid metropolitan population.
    public func CitiesWithMetroPopulation(In SourceList: [City]) -> [City]
    {
        var Final = [City]()
        for SomeCity in SourceList
        {
            if SomeCity.MetropolitanPopulation != nil
            {
                Final.append(SomeCity)
            }
        }
        return Final
    }
    
    /// Returns a list of cities that have a valid population. All known cities are searched.
    /// - Returns: List of cities that have a valid population.
    public func CitiesWithPopulation() -> [City]
    {
        return CitiesWithPopulation(In: _AllCities)
    }
    
    /// Returns a list of cities from `In` that have a population associated.
    /// - Returns: List of cities in `In` that have a valid population.
    public func CitiesWithPopulation(In SourceList: [City]) -> [City]
    {
        var Final = [City]()
        for SomeCity in SourceList
        {
            if SomeCity.Population != nil
            {
                Final.append(SomeCity)
            }
        }
        return Final
    }
    
    /// Returns a list of cities by population. The top `N` cities are returned. All known cities
    /// are searched.
    /// - Parameter N: The top-most n city value. For example, if `N` is 50, the top 50 cities by
    ///                population are returned.
    /// - Parameter UseMetroPopulation: If true, the metropolitan population is used to determine
    ///             which cities to return.
    /// - Returns: List of cities that meet the passed criteria.
    public func TopNCities(N: Int, UseMetroPopulation: Bool = true) -> [City]
    {
        return TopNCities(In: _AllCities, N: N, UseMetroPopulation: UseMetroPopulation)
    }
    
    /// Returns a list of cities by population. The top `N` cities are returned.
    /// - Parameter In: The source list of cities to search.
    /// - Parameter N: The top-most n city value. For example, if `N` is 50, the top 50 cities by
    ///                population are returned.
    /// - Parameter UseMetroPopulation: If true, the metropolitan population is used to determine
    ///             which cities to return.
    /// - Returns: List of cities that meet the passed criteria.
    public func TopNCities(In SourceList: [City], N: Int, UseMetroPopulation: Bool = true) -> [City]
    {
        var Sorted = [City]()
        if UseMetroPopulation
        {
            Sorted = CitiesWithMetroPopulation(In: SourceList).sorted(by: {$0.MetropolitanPopulation! > $1.MetropolitanPopulation!})
        }
        else
        {
            Sorted = CitiesWithPopulation(In: SourceList).sorted(by: {$0.Population! > $1.Population!})
        }
        let FinalCount = Sorted.count - N
        return Sorted.dropLast(FinalCount)
    }
    
    /// Returns a list of all cities read from the database.
    /// - Returns: List of all cities.
    public func GetAllCities() -> [City]
    {
        return _AllCities
    }
    
    /// Holds all of the cities.
    private var _AllCities = [City]()
    
    /// Return the maximum and minimum population in the set a set of cities.
    /// - Parameter CityList: The list of cities whose maximum and minimum populations will be returned.
    /// - Parameter UseMetroPopulation: If true, the metropolitan population is used. If false, the city
    ///                                 population is used. If no population is available, the city is
    ///                                 ignored for the purposes of this function.
    /// - Returns: Tuple with the maximum population and the minimum population values.
    public static func GetPopulationsIn(CityList: [City], UseMetroPopulation: Bool = false) -> (Max: Int, Min: Int)
    {
        var MaxValue: Int = Int.min
        var MinValue: Int = Int.max
        for SomeCity in CityList
        {
            if UseMetroPopulation
            {
                if let Population = SomeCity.MetropolitanPopulation
                {
                    if MaxValue < Population
                    {
                        MaxValue = Population
                    }
                    if MinValue > Population
                    {
                        MinValue = Population
                    }
                }
            }
            else
            {
                if let Population = SomeCity.Population
                {
                    if MaxValue < Population
                    {
                        MaxValue = Population
                    }
                    if MinValue > Population
                    {
                        MinValue = Population
                    }
                }
            }
        }
        return (MaxValue, MinValue)
    }
    
    /// Returns a color for the passed city based on the continent of the city.
    /// - Parameter SomeCity: The city whose continent-based color is returned.
    /// - Parameter OverrideType: If this value is not `.None`, continental colors are returned. Otherwise,
    ///                           the type of color specified by this parameter is returned.
    public static func ColorForCity(_ SomeCity: City, OverrideType: CityColorOverrides = .None) -> NSColor
    {
        switch OverrideType
        {
            case .None:
                switch SomeCity.Continent
                {
                    case .Africa:
                        return Settings.GetColor(.AfricanCityColor, NSColor.blue)
                    
                    case .Asia:
                        return Settings.GetColor(.AsianCityColor, NSColor.brown)
                    
                    case .Europe:
                        return Settings.GetColor(.EuropeanCityColor, NSColor.magenta)
                    
                    case .NorthAmerica:
                        return Settings.GetColor(.NorthAmericanCityColor, NSColor.green)
                    
                    case .SouthAmerica:
                        return Settings.GetColor(.SouthAmericanCityColor, NSColor.orange)
                    
                    case .NoName:
                        return NSColor.white
            }
            
            case .CapitalCities:
                return Settings.GetColor(.CapitalCityColor, NSColor.cyan)
            
            case .WorldCities:
                return Settings.GetColor(.WorldCityColor, NSColor.yellow)
        }
    }
}

