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
/// - Note: Used in 2D mode only.
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
    /// No continental name supplied.
    case NoName = "NoName"
    
    /// African cities.
    case Africa = "Africa"
    
    /// Asian cities.
    case Asia = "Asia"
    
    /// European cities.
    case Europe = "Europe"
    
    /// North American cities.
    case NorthAmerica = "North America"
    
    /// South American cities.
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

/// Filter used for World Heritage Site year inclusion.
enum YearFilters: String, CaseIterable
{
    /// All years.
    case All = "All"
    
    /// Only a specific year.
    case Only = "Only"
    
    /// All years up to a given year.
    case UpTo = "Up To"
    
    /// All years after a given year.
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

/// Shapes used to render the North Pole and South Pole.
/// - Note: Used only in 3D mode.
enum PolarShapes: String, CaseIterable
{
    /// Do not show a shape.
    case None = "None"
    
    /// Flag with the appropriate symbol.
    case Flag = "Flag"
    
    /// A literal pole with red stripes and a gold sphere on top.
    case Pole = "Pole"
}

/// Scripts to use for some visual elements. This does not control the user interface
/// language.
enum Scripts: String, CaseIterable
{
    /// Use English (eg, Latin) scripts and Arabic numerals.
    case English = "English"
    
    /// Use Japanese scripts and numerals.
    case Japanese = "日本語"
}

/// Ways to display cities.
/// - Note: Used only in 3D mode.
enum CityDisplayTypes: String, CaseIterable
{
    /// Each city is a uniform size and embedded in the parent surface.
    case UniformEmbedded = "Uniform Flush Spheres"
    
    /// Each city is sized relative to its population and is embedded in the parent surface.
    case RelativeEmbedded = "Relative Flush Spheres"
    
    /// Each city floats above the parent surface and is sized relative to its population.
    case RelativeFloating = "Floating Spheres"
    
    /// Each city is a box with height determined by relative population.
    case RelativeHeight = "Boxes"
    
    /// Each city is a cylinder with the height (and radius, slightly) determined by
    /// relative population.
    case Cylinders = "Cylinders"
}

/// City population types.
/// - Note: Not all cities in the database have both types of populations.
enum PopulationTypes: String, CaseIterable
{
    /// City population only.
    case City = "City"
    
    /// Metropolitan population.
    case Metropolitan = "Metropolitan"
}

/// Shapes for rendering the home location.
/// - Note: Used in 3D mode only.
enum HomeShapes: String, CaseIterable
{
    /// Do not show the home location.
    case Hide = "Hide"
    
    /// 3D arrow pointing down (radially) towards the home location.
    case Arrow = "Arrow"
    
    /// Flag at the home location.
    case Flag = "Flag"
    
    /// Pulsating sphere at the home location.
    case Pulsate = "Pulsate"
}

/// Suns that can be displayed in 2D mode.
enum SunNames: String, CaseIterable
{
    /// No sun.
    case None = "None"
    
    /// Simple sun.
    case Simple = "Simple"
    
    /// Generic sun.
    case Generic = "Generic"
    
    /// Static, shining sun.
    case Shining = "Shining"
    
    /// Naomi's sun picture.
    case NaomisSun = "Naomi's Sun"
    
    /// Durer's sun sketch.
    case Durer = "Durer's Sun"
    
    /// Vintage sun picture 1.
    case Classic1 = "Old Sun 1"
    
    /// Vintage sun picture 2/
    case Classic2 = "Old Sun 2"
    
    /// Placeholder sun.
    case PlaceHolder = "Placeholder Sun"
}

/// Relative levels of darkness (implemented as alpha levels) of the night layer mask
/// in 2D mode. Actual levels determined at run-time.
/// - Note: Used in 2D mode only.
enum NightDarknesses: String, CaseIterable
{
    /// Very light (meaning a low alpha level).
    case VeryLight = "VeryLight"
    
    /// Not as light as `.VeryLight`.
    case Light = "Light"
    
    /// Not as dark as `.VeryDark`.
    case Dark = "Dark"
    
    /// Very dark (meaking a high alpha level).
    case VeryDark = "VeryDark"
}

/// Determines the size of plotted 2D locations.
/// - Note: Used in 2D mode only.
enum LocationShapes2D: String, CaseIterable
{
    /// Location is a square.
    case Square = "Square"
    
    /// Location is a circle.
    case Circle = "Circle"
}

enum GravitationParameters: Double, CaseIterable
{
    case Sun = 1327124001.89
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
