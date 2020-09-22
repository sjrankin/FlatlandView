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

/// Types of earthquake notifications.
enum EarthquakeNotifications: String, CaseIterable
{
    /// No asynchronous notification.
    case None = "None"
    /// Play a sound.
    case Sound = "Sound"
    /// Display a pop-up.
    case Popup = "Popup"
    /// Play a sound and display a pop-up.
    case Both = "Both"
}

/// Notification sounds.
enum NotificationSounds: String, CaseIterable
{
    /// No sound.
    case None = "None"
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
    
    /// Each city is a pyramid with the height (and base) determined by the relative population.
    case Pyramids = "Pyramids"
    
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

/// How to filter cities by populations.
enum PopulationFilterTypes: String, CaseIterable
{
    /// By rank of city population.
    case ByRank = "ByRank"
    /// By comparison of population to user-defined constant.
    case ByPopulation = "ByPopulation"
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
    /// Do not show moving stars.
    case Off = "Off"
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
/// Options for debugging 3D views. Also used for 2D views rendered in a 3D scene.
/// - Note: Values obtains from [SCNDebugOptions](https://docs.microsoft.com/en-us/dotnet/api/scenekit.scndebugoptions?view=xamarin-ios-sdk-12)
/// - Note: Values are bit masks and should not be changed.
enum DebugOptions3D: UInt, CaseIterable
{
    /// All debug options are disabled.
    case AllOff = 0
    /// Show the wire frame.
    case WireFrame = 64
    /// Show bounding boxes.
    case BoundingBoxes = 2
    /// Show the skeleton.
    case Skeleton = 128
    /// Show light influences.
    case LightInfluences = 4
    /// Show light extents.
    case LightExtents = 8
    /// Show constraints.
    case Constraints = 512
    /// Show cameras.
    case Cameras = 1024
}
#endif

/// Time units.
public enum TimeUnits
{
    /// Represents a calendar year.
    case Year
    /// Represents a calendar day.
    case Day
    /// Represents an hour.
    case Hour
    /// Represents a minute.
    case Minute
}

/// Defines the types of asynchronous data that may be received.
enum AsynchronousDataCategories: String, CaseIterable
{
    /// USGS earthquakes.
    case Earthquakes = "Earthquakes"
    /// NASA Earth data.
    case EarthImageTile = "EarthImageTile"
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
    /// Earthquake is a pulsating sphere.
    case PulsatingSphere = "Pulsating Sphere"
    /// Earthquake is an animated arrow.
    case Arrow = "Animated Arrow"
    /// Earthquake is a static arrow.
    case StaticArrow = "Static Arrow"
    /// Earthquake is a pyramid.
    case Pyramid = "Pyramid"
    /// Earthquake is a cone.
    case Cone = "Cone"
    /// Earthquake is a box.
    case Box = "Box"
    /// Earthquake is a cylinder.
    case Cylinder = "Cylinder"
    /// Earthquake is a capsule.
    case Capsule = "Capsule"
}

/// Types of earthquake indicators.
enum EarthquakeIndicators: String, CaseIterable
{
    /// No indicator.
    case None = "None"
    /// Static ring of a solid color.
    case StaticRing = "Static Ring"
    /// Animated ring with a texture.
    case AnimatedRing = "Animated Ring"
    /// Rings that radiate outward from the earthquake.
    case RadiatingRings = "Radiating Rings"
    /// Glowing sphere with a solid color.
    case GlowingSphere = "Glowing Sphere"
    /// Ring of triangles. Triangles point outwards.
    case TriangleRingOut = "Triangle Ring Outward"
    /// Ring of triangles. Triangles point inwards.
    case TriangleRingIn = "Triangle Ring Inward"
}

/// Ways to view earthquake magnitudes.
enum EarthquakeMagnitudeViews: String, CaseIterable
{
    /// Do not show magnitudes.
    case No = "Not Shown"
    /// Magnitudes are roughly parallel with the surface of the Earth.
    case Horizontal = "HorizontalMagnitude"
    /// Magnitudes are perpendicular to the surface of the Earth.
    case Vertical = "VerticalMagnitude"
    /// Magnitudes are stenciled onto the surface of the map.
    case Stenciled = "Stenciled"
}

///Types of earthquake indicators for 2D mode.
enum EarthquakeIndicators2D: String, CaseIterable
{
    /// No indicator.
    case None = "None"
    /// Static ring of a solid color.
    case Ring = "Ring"
}

/// Determines how earthquakes with related earthquakes are sorted. This affects only the earthquake
/// and its related quakes, not full lists of earthquakes.
enum MultipleQuakeOrders
{
    /// Earthquakes are not ordered.
    case Unordered
    /// The parent earthquake is the earliest earthquake.
    case ByEarliestDate
    /// The parent earthquake has the greatest magnitude.
    case ByGreatestMagnitude
}

/// Definitions of "recent" earthquakes.
enum EarthquakeRecents: String, CaseIterable
{
    /// Twelve hours old.
    case Day05 = "Last 12 Hours"
    /// One day old.
    case Day1 = "Last 24 Hours"
    /// Two days old.
    case Day2 = "Last 48 Hours"
    /// Three days old.
    case Day3 = "Last 72 Hours"
    /// Seven days old.
    case Day7 = "Last Week"
    /// Ten days old.
    case Day10 = "Last 10 Days"
}

/// Textures to use for earthquake indicators that use textures.
enum EarthquakeTextures: String, CaseIterable
{
    case Gradient1 = "Simple Gradient"
    case Gradient2 = "Three-color Gradient"
    case DiagonalLines = "Diagonal Lines"
    case TransparentDiagonalLines = "Transparent Diagonals"
    case Checkerboard = "Black/White Checkerboard"
    case CheckerBoardTransparent = "Black/Transparent Checkerboard"
    case RedCheckerboard = "Red/Transparent Checkerboard"
    case SolidColor = "Solid Color"
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
    /// Grid line layer.
    case GridLayer = 10.0105
    /// City name layer.
    case CityNameLayer = 10.012
    /// Earthquake magnitude layer.
    case MagnitudeLayer = 10.013
    /// World Heritage Site layer.
    case UnescoLayer = 10.011
    /// Rectangular region layer.
    case RegionLayer = 10.014
    /// General purpose line layer.
    case LineLayer = 10.015
    #if true
    /// Test layer.
    case TestLayer = 10.01999
    #endif
}

/// Styles of listing earthquakes.
enum EarthquakeListStyles: String, CaseIterable
{
    /// All earthquakes are listed individually.
    case Individual = "Individual"
    /// Earthquakes are clustered together.
    case Clustered = "Clustered"
}

/// Stencil type classes for the stencil layer in 3D mode.
enum StencilTypes: String, CaseIterable
{
    /// Earthquake magnitude values.
    case EarthquakeMagnitudes = "EarthquakeMagnitudes"
    /// City names.
    case CityNames = "CityNames"
    /// Earth grid lines.
    case GridLines = "GridLines"
    /// User-defined regions.
    case UserRegions = "UserRegions"
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
    case Cities = "City Settings"
    /// Other location settings.
    case OtherLocations = "Other Locations"
    /// General miscellaneous settings.
    case Other = "Other Settings"
    /// Earthquake live view settings.
    case Earthquakes = "Earthquake Settings"
    /// Settings for controlling performance.
    case PerformanceSettings = "Performance Settings"
    #if DEBUG
    /// Settings for controlling debugging.
    case DebugSettings = "Debug Settings"
    #endif
}

/// Determines how roughly text is drawn. Smoother text looks nicer but takes more time.
enum TextSmoothnesses: CGFloat, CaseIterable
{
    /// Smoothest possible.
    case Smoothest = 0.0
    /// Smooth.
    case Smooth = 0.1
    /// Medium.
    case Medium = 0.2
    /// Rough.
    case Rough = 0.3
    /// Roughest (we allow).
    case Roughest = 0.5
}

/// Time states for debugging
enum TimeControls: String, CaseIterable
{
    case Run = "Run"
    case Pause = "Pause"
}

/// Scales for 3D nodes.
enum NodeScales: CGFloat
{
    /// Earthquake text.
    case EarthquakeText = 0.03
    
    /// Animated ring base scale.
    case AnimatedRingBase = 1.2
    
    /// Radiating rings.
    case RadiatingRings = 0.1
    
    /// Radiating ring expansion base.
    case RadiatingRingBase = 1.0
    
    /// Earthquake arrow.
    case ArrowScale = 0.75
    
    /// Static earthquake arrow.
    case StaticArrow = 0.74
    
    /// Scale of the home pin.
    case PinScale = 0.25
    
    /// Scale of city names.
    case CityNameScale = 0.02
    
    /// Scale of Unesco sites.
    case UnescoScale = 0.55
    
    /// Minimum pulsating indicator scale.
    case PulsatingHomeMinScale = 0.4
    
    /// Maximum pulsating indicator scale.
    case PulsatingHomeMaxScale = 0.76
    
    /// Bouncing arrow scale.
    case BouncingArrowScale = 0.751
    
    /// Pulsing earthquake sphere.
    case PulsingEarthquakeSphere = 0.749
    
    /// Hour text scale.
    case HourText = 0.07
    
    /// Scale of the static (in relation to motion) home arrow.
    case HomeArrowScale = 2.02
    
    /// Scale of triangle rings.
    case TriangleRing = 0.41
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

/// Projection modes for Flatland's camera system.
enum CameraProjections: String, CaseIterable
{
    /// Perspective projection.
    case Perspective = "Perspective"
    /// Orthographic projection.
    case Orthographic = "Orthographic"
}

/// 3D view node names.
enum GlobeNodeNames: String
{
    /// Nodes related to earthquakes.
    case EarthquakeNodes = "EarthquakeNodes"
    /// Node that marks the home location.
    case HomeNode = "HomeNode"
    /// Node used to draw an hour.
    case HourNode = "HourNode"
    /// Node used to indicate recent earthquakes.
    case IndicatorNode = "IndicatorNode"
    /// Built-in camera node.
    case BuiltInCameraNode = "BuiltInCameraNode"
    /// Flatland camera node.
    case FlatlandCameraNode = "FlatlandCameraNode"
    /// City nodes.
    case CityNode = "CityNode"
}

/// 2D view node names.
enum NodeNames2D: String
{
    /// Hour text nodes.
    case HourNodes = "HourNode"
    /// Nodes in the grid.
    case GridNodes = "GridNode"
    /// The hour plane.
    case HourPlane = "HourPlane"
    /// Location (cities, etc) plane.
    case LocationPlane = "LocationPlane"
    /// A city on the location plane.
    case CityNode = "CityNode"
    /// Earthquake plane.
    case EarthquakePlane = "EarthquakePlane"
    /// World heritage site plane.
    case UnescoPlane = "UnescoPlane"
    /// World heritage site node.
    case WorldHeritageSite = "WorldHeritageSite"
    /// Home location node.
    case HomeNode = "HomeNode"
    /// User points of interest locations.
    case UserPOI = "UserPOI"
    /// Earthquake nodes.
    case Earthquake = "Earthquake"
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
    /// 3D status view layer.
    case StatusViewLayer = 20001
    #if DEBUG
    /// Debug layer.
    case DebugLayer = 19000
    #endif
}

/// Light masks for 3D scenes. The value of each case if the mask value for a given
/// light and as such, each value must be unique (which is enforced by Swift).
enum LightMasks3D: Int, CaseIterable
{
    /// Mask for the sun light.
    case Sun = 0b00001
    /// Mask for the metal sun light.
    case MetalSun = 0b00010
    /// Mask for the moon light.
    case Moon = 0b00100
    /// Mask for the metal moon light.
    case MetalMoon = 0b01000
    /// Mask for the grid light.
    case Grid = 0b10000
}

/// Light masks for 2D scenes. The value of each case if the mask value for a given
/// light and as such, each value must be unique (which is enforced by Swift).
enum LightMasks2D: Int, CaseIterable
{
    /// The sun light mask.
    case Sun = 0b00001
    /// The grid light mask.
    case Grid = 0b00010
    /// The polar light mask.
    case Polar = 0b00100
}

/// **Standard longitudes**. The raw value of each case is the percent away from the South Pole in
/// whatever units are used.
enum Longitudes: Double, CaseIterable
{
    /// Equator.
    case Equator = 0.5
    /// Arctic circle, measured in percent from the South Pole.
    case ArcticCircle = 0.869782
    /// Antartic circle, measured in percent from the South Pole.
    case AntarcticCircle = 0.130218
    /// Tropic of Cancer, measured in percent from the South Pole.
    case TropicOfCancer = 0.61718
    /// Tropic of Capricorn, measured in percent from the South Pole.
    case TropicOfCapricorn = 0.38282
}

/// **Standard latitudes.** The raw value of each case is the percent away from the left side of
/// the drawing surface in whatever units are used.
enum Latitudes: Double, CaseIterable
{
    /// Prime meridian (which is at 0°, or the center of the map).
    case PrimeMeridian = 0.5
    /// Meridian 180° away from the prime meridian.
    case OtherPrimeMeridian = 1.0
    /// Merdian on the other side of the prime meridian.
    case AntiPrimeMeridian = 0.25
    /// Meridian on the other side of the other prime meridian.
    case OtherAntiPrimeMeridian = 0.75
}

/// Where notifications appear.
enum NotificationLocations: String, CaseIterable
{
    /// Notifications appear in the system's notification center. On Macs, if Flatland has
    /// focus, no notification will appear on the system (but will be logged).
    case NotificationCenter = "System"
    /// Use Flatland's notification system.
    case Flatland = "Flatland"
    /// Use both Flatland's and the system's notification center.
    case Both = "Both"
}

enum StartupTasks: String, CaseIterable
{
    case Initialize = "Initialization"
    case UIInitialize = "UI Iniatilization"
    case LoadNASATiles = "Fetching Image Tiles"
    case LoadUSGSQuakes = "Fetching USGS Earthquakes"
}

/// Constants for environmental variables.
enum EnvironmentVars: String, CaseIterable
{
    /// Value that determines whether to enable or disable downloading images from NASA.
    case SatelliteMaps = "enable_nasa_tiles"
}

/// Small set of relative sizes.
enum RelativeSizes: String, CaseIterable
{
    /// Something is small.
    case Small = "Small"
    /// Something is medium.
    case Medium = "Medium"
    /// Something is large.
    case Large = "Large"
}

/// Default Double and CGFloat values (CGFloat values must be cast) for various
/// settings. These are used instead of hard-coded numbers embedded in the code.
enum Defaults: Double
{
    /// How often the Earth clock is called.
    case EarthClockTick = 1.0
    /// Tolerance for the Earth clock.
    case EarthClockTickTolerance = 0.1
    /// Number of seconds for the rotation of the Earth to the proper orientation.
    case EarthRotationDuration = 0.95
    /// Sphere segment count.
    case SphereSegmentCount = 100.00000005
    /// Number of seconds to rotate the Earth in attract mode.
    case AttractRotationDuration = 30.0
    /// Closest z value allowed.
    case ClosestZ = 60.0
    /// Camera z far value.
    case ZFar = 1000.0
    /// Camera z near value.
    case ZNear = 0.100001
    ///Initial z position for the camera.
    case InitialZ = 175.0
    /// Default view of view.
    case FieldOfView = 10.0
    /// Duration in seconds for resetting the camera.
    case ResetCameraAnimationDuration = 1.001
    /// Ambient light intensity.
    case AmbientLightIntensity = 800.0
    /// Shadow color alpha level.
    case ShadowAlpha = 0.8
    /// Shadow radius.
    case ShadowRadius = 2.0001
    /// Ambient light Z location.
    case AmbientLightZ = 80.0002
    /// Sun light Z location.
    case SunLightZ = 80.005
    /// Sun light intensity.
    case SunLightIntensity = 801.0
    /// Metal sun light intensity.
    case MetalSunLightIntensity = 1200.03
    /// Moon light Z location.
    case MoonLightZ = -100.3
    /// Moon light intensity.
    case MoonLightIntensity = 300.024
    /// Metal moon light intensity
    case MetalMoonLightIntensity = 800.0008
    /// Moon light shadow radius.
    case MoonLightShadowRadius = 4.0
    /// Grid light 1 Z position.
    case Grid1Z = -80.05
    /// Grid light 2 Z position.
    case Grid2Z = 80.05
    /// Opacity of the earthquake map.
    case EarthquakeMapOpacity = 0.751
    /// Opacity level of earthquake maps.
    case EarthquakeMapColorAlpha = 0.4006
    /// Fast globe animation duration.
    case FastAnimationDuration = 30.0002
    /// Standard map image width.
    case StandardMapWidth = 3600.0
    /// Standard map image height.
    case StandardMapHeight = 1800.0
    /// Minor grid gap for minor grid lines.
    case MinorGridGap = 15.0
    /// Line width for grid lines.
    case GridLineWidth = 4.00001
}

/// Values used by the flat view.
enum FlatConstants: Double, CaseIterable
{
    /// Used as part of the conversion process to conver latitude, longitude pairs into polar coordinates.
    case InitialBearingOffset = 180.0
    /// The radius of the flat map.
    case FlatRadius = 11.00001
    /// The thickness of the flat map.
    case FlatThickness = 0.099
    /// The thickness of the mask layer.
    case NightMaskThickness = 0.15
    /// The thickness of the grid layer.
    case GridLayerThickness = 0.104
    /// The radius of the invisible ring holding hours.
    case HourRadius = 11.5
    /// The flatness of hour text in 2D mode.
    case HourFlatness = 0.1
    /// Extrusion of hour text in 2D mode.
    case HourExtrusion = 1.0
    /// Chamfer value for hour text in 2D mode.
    case HourChamfer = 0.2
    /// Number of segments for the cylinder shape for the view.
    case FlatSegments = 100.0
    /// Scale value for the hour text.
    case HourScale = 0.05
    /// Initial rotation duration.
    case InitialRotation = 0.112
    /// Normal rotation duration.
    case NormalRotation = 1.0001
    /// Maximum arc height of the polar sun when animated from one pole to the other.
    case MaxArcHeight = 5.0
    /// Number of steps when animating the polar sun across the Earth.
    case ArcStepCount = 11.0
    /// Distance from the edge of the disc of the Earth in flat mode for the polar sun.
    case PolarSunRimOffset = 5.01
    /// Duration (in seconds) of the animation of the polar sun when movine from pole to pole.
    case PolarAnimationDuration = 1.4
    /// Z coordinate of the grid light.
    case GridLightZ = 80.0
    /// Standard polar light intensity.
    case PolarLightIntensity = 3600.0
    /// Standard sun light intensity.
    case SunLightIntensity = 1000.01
    /// Z coordinate of the sun light.
    case SunLightZ = 80.0005
    /// Polar light zFar value.
    case PolarZFar = 1000.0
    /// Polar light zNear value.
    case PolarZNear = 0.100101
    /// Polar light spot outer angle.
    case PolarLightOuterAngle = 90.001
    /// Shadow cascade splitter factor for the polar light shadow rendering.
    case ShadowSplitting = 0.09
    /// Side length of the shadow map for polor light shadow rendering.
    case ShadowMapSide = 2048.0
    /// Orientation angle for the X-axis rotation of the polar light.
    case PolarLightXOrientation = 85.0
    /// Z value of the polar light at either pole.
    case PolarLightZTerminal = 3.0
    /// Base size for cones used to plot user-cities.
    case UserCityBaseSize = 0.1500001
    /// Height of cones used to plot user-cities.
    case UserCityHeight = 0.45
    /// Radius of spheres for uniform cities.
    case CitySphereRadius = 0.150002
    /// How to adjust the relative city size offset.
    case RelativeCitySizeAdjustment = 1.005
    /// Scale to use for the home shape.
    case HomeSizeScale = 0.035
}

/// Values intended to be constants for one reason or another.
enum Constants: Double, CaseIterable
{
    /// Font size offset value for earthquake magnitude values in higher latitudes.
    case StencilFontSize = 60.0
    /// Font size offset value for city names in higher latitudes.
    case StencilCitySize = 25.0
    /// Horizontal text offset for city names the names are far enough away from any 3D shapes.
    case StencilCityTextOffset = 15.0
    /// World Heritage Site shape Y offset.
    case WHSYOffset = 12.0
    /// World Heritage Site shape left X.
    case WHSLeftX = -8.0
    /// World Heritage Site shape right X.
    case WHSRightX = 8.0
    /// Stroke width for stenciled text.
    case StencilTextStrokeWidth = -2.0
    /// Number of seconds between up-timer notifications.
    case UpTimerDuration = 600.0
}

/// Layers for the globe view.
enum GlobeLayers: String, CaseIterable
{
    /// Grid lines.
    case GridLines = "GridLines"
    /// City names.
    case CityNames = "CityNames"
    /// Earthquake magnitudes.
    case Magnitudes = "Magnitudes"
    /// World heritage sites.
    case WorldHeritageSites = "WorldHeritageSites"
    /// General purpose lines.
    case Lines = "Lines"
    /// Rectangular regions.
    case Regions = "Regions"
    #if true
    /// Test layer.
    case Test = "Test"
    #endif
}

/// Physical constants.
enum PhysicalConstants: Double, CaseIterable
{
    /// Circumference of the Earth in kilometers.
    case EarthCircumference = 40075.0
    /// Half of the circumference of the Earth in kilometers.
    case HalfEarthCircumference = 20037.5
    /// Radius of the Earth in kilometers.
    case EarthRadius = 6371.0
    /// Diameter of the Earth in kilometers.
    case EarthDiameter = 12742.0
}
