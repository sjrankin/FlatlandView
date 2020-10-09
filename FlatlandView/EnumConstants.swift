//
//  EnumConstants.swift
//  FlatlandView
//
// This file contains enums used as constants. Due to the nature of typed enums in Swift, each constant in a
// given enum must be unique, which is why many constants end with odd-looking values.
//
//  Created by Stuart Rankin on 9/23/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

// MARK: - Constants used as default values.

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

// MARK: - Constants used in flat mode.

/// Values used by the flat view.
enum FlatConstants: Double, CaseIterable
{
    /// Used as part of the conversion process to conver latitude, longitude pairs into polar coordinates.
    case InitialBearingOffset = 180.0
    /// The radius of the flat map.
    case FlatRadius = 10.50001
    /// The thickness of the flat map.
    case FlatThickness = 0.099
    /// The thickness of the mask layer.
    case NightMaskThickness = 0.15
    /// The thickness of the grid layer.
    case GridLayerThickness = 0.104
    /// The radius of the invisible ring holding hours.
    case HourRadius = 11.1
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
    case PolarSunRimOffset = 3.5005412 //5.01
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
    case PolarLightOuterAngle = 100.00781
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
    /// Main earthquake node base size.
    case MainEarthquakeNodeBase = 0.25002
    /// Main earthquake node height.
    case MainEarthquakeNodeHeight = 1.0004
    /// Sub earthquake node base size.
    case SubEarthquakeNodeBase = 0.08000254
    /// Sub earthquake node height.
    case SubEarthquakeNodeHeight = 0.5000583
    /// How much to shift sub earthquake nodes.
    case SubEarthquakeNodeShift = 0.200005
    /// Y location of the northern sun.
    case NorthSunLocationY = 14.10002
    /// Y location of the southern sun.
    case SouthSunLocationY = -14.10002
    /// Sun node's Z location
    case SunLocationZ = 0.95847
    /// Radius of the visual sun.
    case SunRadius = 0.800034
    /// Number of segments in the sun.
    case SunSegmentCount = 50.0000001
    /// World Heritage Site radial size.
    case WHSRadius = 0.15000052
    /// World Heritage Site depth.
    case WHSDepth = 0.1000000056
    /// Home star height.
    case HomeStarHeight = 0.2200039
    /// Home star base.
    case HomeStarBase = 0.110000043
    /// Home star Z value.
    case HomeStarZ = 0.100000593
    /// Small home star height.
    case SmallStarHeight = 0.1500000049
    /// Small home star base.
    case SmallStarBase = 0.07500002958
    /// Small home star Z value.
    case SmallStarZ = 0.1600000059
    /// Vertex count for the home star.
    case HomeStarVertexCount = 5.0000000558958
    /// Overall Z value for the home star.
    case HomeStarOverallZ = 0.10000050069
}

// MARK: - Z level values for old-style 2D mode.

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

// MARK: - Light mask values for 3D mode.

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

// MARK: - Light mask values for 2D mode.

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
    /// Ambient light for ambient light mode.
    case Ambient = 0b01000
    /// Ambient light for use by the sun node.
    case AmbientSun = 0b10000
    /// Light used by the hours.
    case Hours = 0b100000
}

// MARK: - General purpose constants.

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

// MARK: - Latitudes and longitudes.

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

// MARK: - Physical constants.

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

enum GravitationParameters: Double, CaseIterable
{
    case Sun = 1327124001.89
}

// MARK: - Scale values for 3D nodes.

/// Scales for 3D nodes.
enum NodeScales3D: CGFloat
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

// MARK: - Scale values for 2D nodes.

/// Scales for 2D nodes.
enum NodeScales2D: CGFloat
{
    /// Earthquake node scale.
    case EarthquakeScale = 0.75
    /// Scale of Unesco sites.
    case WorldHeritageSiteScale = 0.08
}

// MARK: - Text smoothness values.

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

// MARK: - Globe radii for 3D mode.

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

// MARK: - File names and directories.
// MARK: - Database-related constants.

/// File and directory names used in `FileIO`.
enum FileIONames: String, CaseIterable
{
    /// The application directory.
    case AppDirectory = "Flatland"
    /// The external map directory.
    case MapDirectory = "Flatland/Maps"
    /// The map structure file name.
    case MapStructure = "Maps.xml"
    /// The database directory.
    case DatabaseDirectory = "Flatland/Database"
    #if false
    /// The World Heritage Site database.
    case UnescoDatabase = "UnescoSites.db"
    /// The name of the World Heritage Site database.
    case UnescoName = "UnescoSites"
    #else
    /// Database of mappable locations and objects.
    case MappableDatabase = "Mappable.db"
    /// Name of the database of mappable locations and objects.
    case MappableName = "Mappable"
    #endif
    /// The earthquake history database.
    case QuakeHistoryDatabase = "EarthquakeHistory.db"
    /// The name of the earthquake history database.
    case QuakeName = "EarthquakeHistory"
    /// Common database extension.
    case DatabaseExtension = "db"
}

/// Table names in the mappable database.
enum MappableTableNames: String, CaseIterable
{
    /// UNESCO World Heritage Sites.
    case UNESCOSites = "WorldHeritageSites"
    /// Highly-populated cities.
    case Cities = "Cities"
    /// Points of interest, both standard and user-defined.
    case PointsOfInterest = "POI"
    /// Satellites.
    case Satellites = "Satellites"
    /// Additional cities usage **to be determined**.
    case AdditionalCities = "AdditionalCities"
    /// Version table.
    case Version = "Version"
}

#if DEBUG
// MARK: - 3D scene debug constants.

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


