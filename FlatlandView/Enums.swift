//
//  Enums.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

enum ViewTypes: String, CaseIterable
{
    case FlatMap = "FlatMap"
    case Globe3D = "3DGlobe"
    case CubicWorld = "Cubic"
}

enum HourValueTypes: String, CaseIterable
{
    case None = "NoHours"
    case Solar = "RelativeToSolar"
    case RelativeToNoon = "RelativeToNoon"
    case RelativeToLocation = "RelativeToLocation"
}

/// City color overrides. Used to return non-continental colors from `ColorForCity`.
enum CityColorOverrides: String, CaseIterable
{
    /// No override - use the continental color specified by the city's continent.
    case None = "None"
    
    /// Return the world cities color.
    case WorldCities = "WorldCities"
    
    /// Return the captial cities color.
    case CapitalCities = "CapitalCities"
}

/// Continents for the city database.
enum Continents: String, CaseIterable
{
    case NoName = "NoName"
    case Africa = "Africa"
    case Asia = "Asia"
    case Europe = "Europe"
    case NorthAmerica = "North America"
    case SouthAmerica = "South America"
}
