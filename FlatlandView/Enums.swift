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
    case FlatNorthCenter = "FlatNorthCenter"
    case FlatSouthCenter = "FlatSouthCenter"
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

/// The available time label types.
enum TimeLabels: String, CaseIterable
{
    /// Do not display the time.
    case None = "None"
    /// Time is in UTC.
    case UTC = "UTC"
    /// Time is in current local timezone.
    case Local = "Local"
}

/// Determines the location of the sun graphic (and by implication, the time label as well).
enum SunLocations: String, CaseIterable
{
    /// Do not display the sun.
    case Hidden = "NoSun"
    /// Sun is at the top.
    case Top = "Top"
    /// Sun is at the bottom.
    case Bottom = "Bottom"
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

enum YearFilters: String, CaseIterable
{
    case All = "All"
    case Only = "Only"
    case UpTo = "Up To"
    case After = "After"
}

enum SiteTypeFilters: String, CaseIterable
{
    case Natural = "Natural"
    case Cultural = "Cultural"
    case Both = "Both"
    case Either = "Either"
}
