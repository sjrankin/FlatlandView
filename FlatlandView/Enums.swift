//
//  Enums.swift
//  Flatland
//
//  This file contains most of the enums used in Flatland. Given how dependent Flatland
//  is on enums, having them all consolidated in one spot makes maintenance easier.
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
    
    /// 3D cube view. Mostly for silliness.
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
    
    /// Each city is a sphere that floats above the parent surface and is sized relative to its population.
    case RelativeFloatingSpheres = "Floating Spheres"
    
    /// Each city is a box that floats above the parent surface and is sized relative to its population.
    case RelativeFloatingBoxes = "Floating Boxes"
    
    /// Each city is a box with height determined by relative population.
    case RelativeHeight = "Boxes"
    
    /// Each city is a cylinder with the height (and radius, slightly) determined by
    /// relative population.
    case Cylinders = "Cylinders"
    
    /// City names displayed with a variation in the size of the text indicating population.
    case Names = "Names"
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
    
    /// 3D pin-shape.
    case Pin = "Pin"
    
    /// 3D bouncing arrow.
    case BouncingArrow = "Bouncing Arrow"
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
    
    /// Location is an oval.
    case Oval = "Oval"
    
    /// Location is a star.
    case Star = "Star"
}

/// Speeds for the velocity of stars in the star view. Actual value determined at run-time.
enum StarSpeeds: String, CaseIterable
{
    /// Slow speed.
    case Slow = "Slow"
    /// Medium speed.
    case Medium = "Medium"
    /// Fast speed.
    case Fast = "Fast"
}

enum GravitationParameters: Double, CaseIterable
{
    case Sun = 1327124001.89
}

#if DEBUG
/// Options for debugging 3D views.
/// - Note: Values obtains from [SCNDebugOptions](https://docs.microsoft.com/en-us/dotnet/api/scenekit.scndebugoptions?view=xamarin-ios-sdk-12)
/// - Note: Values are bit masks and should not be changed.
enum DebugOptions3D: UInt, CaseIterable
{
    case AllOff = 0
    case WireFrame = 64
    case BoundingBoxes = 2
    case Skeleton = 128
    case LightInfluences = 4
    case LightExtents = 8
    case Constraints = 512
    case Cameras = 1024
}
#endif

/// Defines the types of asynchronous data that may be received.
enum AsynchronousDataTypes: String, CaseIterable
{
    /// USGS earthquakes.
    case Earthquakes = "Earthquakes"
    case Earthquakes2 = "Earthquakes2"
}

/// Methods for determining colors of earthquakes.
enum EarthquakeColorMethods: String, CaseIterable
{
    /// Age of the earthquake.
    case Age = "Age"
    /// Magnitude of the earthquake.
    case Magnitude = "Magnitude"
    /// The range of the magnitude of the earthquake.
    case MagnitudeRange = "Magnitude Range"
    /// Nearest population center.
    case Population = "Population"
    /// How significant an earthquake is.
    case Significance = "Significance"
}

/// Earthquake magnitudes to display.
/// - Note: The values of the magnitudes *must* be in ascending order.
enum EarthquakeMagnitudes: Double, CaseIterable
{
    /// Display M4.0 and higher.
    case Mag4 = 4.0
    /// Display M5.0 or higher.
    case Mag5 = 5.0
    /// Display M6.0 or higher.
    case Mag6 = 6.0
    /// Display M7.0 or higher.
    case Mag7 = 7.0
    /// Display M8.0 or higher.
    case Mag8 = 8.0
    /// Display M9.0 or higher.
    case Mag9 = 9.0
}

/// Relative age for displaying earthquakes.
enum EarthquakeAges: String, CaseIterable
{
    case Age1 = "1 Day"
    case Age2 = "2 Days"
    case Age3 = "3 Days"
    case Age4 = "4 Days"
    case Age5 = "5 Days"
    case Age6 = "6 Days"
    case Age7 = "7 Days"
    case Age8 = "8 Days"
    case Age9 = "9 Days"
    case Age10 = "10 Days"
    case Age11 = "11 Days"
    case Age12 = "12 Days"
    case Age13 = "13 Days"
    case Age14 = "14 Days"
    case Age15 = "15 Days"
    case Age16 = "16 Days"
    case Age17 = "17 Days"
    case Age18 = "18 Days"
    case Age19 = "19 Days"
    case Age20 = "20 Days"
    case Age21 = "21 Days"
    case Age22 = "22 Days"
    case Age23 = "23 Days"
    case Age24 = "24 Days"
    case Age25 = "25 Days"
    case Age26 = "26 Days"
    case Age27 = "27 Days"
    case Age28 = "28 Days"
    case Age29 = "29 Days"
    case Age30 = "30 Days"
}

/// Shapes for earthquake locations.
enum EarthquakeShapes: String, CaseIterable
{
    /// Earthquake is a sphere.
    case Sphere = "Sphere"
    /// Earthquake is a floating arrow.
    case Arrow = "Bouncing Arrow"
    /// Earthquake is a pyramid.
    case Pyramid = "Pyramid"
    /// Earthquake is a box.
    case Box = "Box"
    /// Earthquake is a cylinder.
    case Cylinder = "Cylinder"
    /// Earthquake is a capsule.
    case Capsule = "Capsule"
    /// Earthquake is a magnitude value.
    case Magnitude = "Magnitude"
}

/// Radius values.
enum GlobeRadius: CGFloat, CaseIterable
{
    /// Primary sphere radius.
    case Primary = 10.01
    /// Sea sphere radius.
    case SeaSphere = 10.0
    /// Sphere with grid lines.
    case LineSphere = 10.2
    /// Sphere that holds the hour text.
    case HourSphere = 11.5
    /// Location of city names (if used).
    case CityNames = 10.5
}

/// Styles of listing earthquakes.
enum EarthquakeListStyles: String, CaseIterable
{
    /// All earthquakes are listed individually.
    case Individual = "Individual"
    /// Earthquakes are clustered together.
    case Clustered = "Clustered"
}

/// Setting groups for the main settings.
/// - Note: The order in which the cases are defined will apply to the list of setting
///         options in the settings window. In other words, the order here defines what
///         the user will see.
enum SettingGroups: String, CaseIterable
{
    /// Map selection window.
    case Maps = "Select Map"
    /// 2D map view settings.
    case Map2D = "2D Map Settings"
    /// 3D map view settings.
    case Map3D = "3D Map Settings"
    /// User location settings.
    case UserLocation = "User Location"
    /// City settings.
    case Cities = "City Locations"
    /// Other location settings.
    case OtherLocations = "Other Locations"
    /// General miscellaneous settings.
    case Other = "Other Settings"
    /// Earthquake live view settings.
    case Earthquakes = "Earthquake Settings"
}

/// Layer names for 2D mode.
enum LayerNames: String
{
    /// Earthquake display layer.
    case Earthquakes = "Earthquake Layer"
    
    /// Single, plotted earthquake.
    case Earthquake = "Plotted Earthquake"
    
    /// Grid layer.
    case Grid = "View Grid"
    
    /// Prime meridian layer.
    case PrimeMeridian = "Prime Meridian"
    
    /// User-defined locations.
    case UserLocation = "User Location"
    
    /// Plotted city layer.
    case PlottedCity = "Plotted City"
    
    /// Layer that holds plotted cities.
    case CityLayer = "City Layer"
}

/// Z position enum and layer values. Defines which layers are on top of other layers.
/// Higher values mean closer to the user which means more likely to be visible.
enum LayerZLevels: Int
{
    /// Time lables.
    case TimeLabels = 100000
    
    /// 2D city layer.
    case CityLayer = 8000
    
    /// 2D earthquake layer.
    case EarthquakeLayer = 8079
    
    /// Current layer (eg, depending on user settings, this is either the 2D or
    /// 3D view).
    case CurrentLayer = 5000
    
    /// Inactive layer. The view that is not active.
    case InactiveLayer = 0
    
    /// 2D hour label layer.
    case HourLayer = 60000
    
    /// 2D hour text.
    case HourTextLayer = 60050
    
    /// 2D grid layer.
    case GridLayer = 10000
    
    /// 2D night mask layer.
    case NightMaskLayer = 20000
    
    /// Info grid layer.
    case LocalInfoGridLayer = 19001
    
    /// Star view layer.
    case StarLayer = 4000
    
    #if DEBUG
    /// Debug layer.
    case DebugLayer = 19000
    #endif
}
