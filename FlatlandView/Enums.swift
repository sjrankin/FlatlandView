//
//  Enums.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

/// Types of views.
enum ViewTypes: String, CaseIterable
{
    /// Flat view with the north at the center.
    case FlatNorthCenter = "FlatNorthCenter"
    /// Flat view with the south at the center.
    case FlatSouthCenter = "FlatSouthCenter"
    /// 3D globe view.
    case Globe3D = "3DGlobe"
    /// 3D cube view.
    case CubicWorld = "Cubic"
}

/// Types of hour labels.
enum HourValueTypes: String, CaseIterable
{
    /// No hour labels.
    case None = "NoHours"
    /// Noon always at solar noon.
    case Solar = "RelativeToSolar"
    /// Hours relative to noon (eg, + or - hours away from solar noon).
    case RelativeToNoon = "RelativeToNoon"
    /// Hours relative to set location. Not used if the user does not set a
    /// location.
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

/// City groups.
enum CityGroups: String, CaseIterable
{
    /// World cities.
    case WorldCities = "World Cities"
    /// National capital cities.
    case CapitalCities = "Capital Cities"
    /// African cities.
    case AfricanCities = "African Cities"
    /// Asian cities.
    case AsianCities = "Asian Cities"
    /// European cities.
    case EuropeanCities = "European Cities"
    /// North American cities.
    case NorthAmericanCities = "North American Cities"
    /// South American cities.
    case SouthAmericanCities = "South American Cities"
}

enum YearFilters: String, CaseIterable
{
    case All = "All"
    case Only = "Only"
    case UpTo = "Up To"
    case After = "After"
}

/// World heritage site types.
enum SiteTypeFilters: String, CaseIterable
{
    /// Natural site.
    case Natural = "Natural"
    /// Cultural site.
    case Cultural = "Cultural"
    /// Mixed natural/cultural site.
    case Both = "Both"
    /// Any type of site.
    case Either = "Either"
}

enum PolarShapes: String, CaseIterable
{
    case None = "None"
    case Flag = "Flag"
    case Pole = "Pole"
}

enum Scripts: String, CaseIterable
{
    case English = "English"
    case Japanese = "日本語"
}

/// Ways to display cities.
enum CityDisplayTypes: String, CaseIterable
{
    /// Each city is a uniform size and embedded in the parent surface.
    case UniformEmbedded = "Unifor Flush Spheres"
    /// Each city is sized relative to its population and is embedded in the parent surface.
    case RelativeEmbedded = "Relative Flush Spheres"
    /// Each city floats above the parent surface and is sized relative to its population.
    case RelativeFloating = "Floating Spheres"
    /// Each city is a box with height determined by relative population.
    case RelativeHeight = "Boxes"
}

enum PopulationTypes: String, CaseIterable
{
    case City = "City"
    case Metropolitan = "Metropolitan"
}

enum HomeShapes: String, CaseIterable
{
    case Hide = "Hide"
    case Arrow = "Arrow"
    case Flag = "Flag"
    case Pulsate = "Pulsate"
}

/// Z position enum and layer values. Defines which layers are on top of other layers.
/// Higher values mean closer to the user which means more likely to be visible.
enum LayerZLevels: Int
{
    /// Time lables.
    case TimeLabels = 100000
    /// City layer.
    case CityLayer = 8000
    /// Current layer (eg, depending on user settings, this is either the 2D or
    /// 3D view).
    case CurrentLayer = 5000
    /// Inactive layer. The view that is not active.
    case InactiveLayer = 0
    /// Hour label layer.
    case HourLayer = 60000
    /// Hour text.
    case HourTextLayer = 60050
    /// The grid layer.
    case GridLayer = 10000
    /// Night mask layer.
    case NightMaskLayer = 20000
}
