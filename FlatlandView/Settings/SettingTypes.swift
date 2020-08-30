//
//  SettingTypes.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

/// Settings. Each case refers to a single setting and is used
/// by the settings class to access the setting.
enum SettingTypes: String, CaseIterable
{
    // MARK: - Infrastructure/initialization-related settings.
    case InitializationFlag = "InitializationFlag"
    
    // MARK: - Map-related settings.
    /// The type of map to view (the map image). This is used for both 2D and 3D modes
    /// (but not the cubic mode).
    case MapType = "MapType"
    /// Determines the view type - 2D (one of two types) or 3D (one of two types).
    case ViewType = "ViewType"
    /// Boolean: Determines if the night mask is shown in 2D mode.
    case ShowNight = "ShowNight"
    /// Double: The alpha level of the night mask. See `NightDarkness`.
    case NightMaskAlpha = "NightMaskAlpha"
    /// Darkness level that determines the actual alpha level of the night mask. See
    /// `NightMaskAlpha`.
    case NightDarkness = "NightDarkness"
    /// The type of hour to display.
    case HourType = "HourType"
    /// The type of time label to display.
    case TimeLabel = "TimeLabel"
    /// Boolean: Determines whether seconds are shown in the time label.
    case TimeLabelSeconds = "TimeLabelSeconds"
    /// Boolean: Show the sun in 2D mode.
    case ShowSun = "ShowSun"
    /// Determines the script to use for certain display elements.
    case Script = "Script"
    /// The type of sun image to display.
    case SunType = "SunType"
    /// The type of view to show in the sample map image display.
    case SampleViewType = "SampleViewType"
    
    // MARK: - 2D view settings.
    /// Boolean: Display the equator in 2D mode.
    case Show2DEquator = "Show2DEquator"
    /// Boolean: Display polar circles in 2D mode.
    case Show2DPolarCircles = "Show2DPolarCircles"
    /// Boolean: Display tropic circles in 2D mode.
    case Show2DTropics = "Show2DTropics"
    /// Boolean: Display prime meridians in 2D mode.
    case Show2DPrimeMeridians = "Show2DPrimeMeridians"
    /// Boolean: Display noon meridians in 2D mode.
    case Show2DNoonMeridians = "Show2DNoonMeridians"
    
    // MARK: - 3D view settings.
    /// Boolean: Display grid lines in 3D mode.
    case Show3DGridLines = "Show3DGridLines"
    /// Boolean: Display the equator in 3D mode.
    case Show3DEquator = "Show3DEquator"
    /// Boolean: Display polar circles in 3D mode.
    case Show3DPolarCircles = "Show3DPolarCircles"
    /// Boolean: Display tropic circles in 3D mode.
    case Show3DTropics = "Show3DTropics"
    /// Boolean: Display prime meridians in 3D mode.
    case Show3DPrimeMeridians = "Show3DPrimeMeridians"
    /// Boolean: Display minor grid lines in 3D mode.
    case Show3DMinorGrid = "Show3DMinorGrid"
    /// Integer: Grid gap for minor grid lines in 3D mode.
    case MinorGrid3DGap = "MinorGrid3DGap"
    /// Double: Alpha level for the 3D globe.
    case GlobeTransparencyLevel = "GlobeTransparencyLevel"
    /// Determines how fast stars move when visible.
    case StarSpeeds = "StarSpeeds"
    /// Boolean: Show moonlight on 3D globes for the night side.
    case ShowMoonLight = "ShowMoonLight"
    /// Determines the shape of the object marking the poles.
    case PolarShape = "PolarShape"
    #if false
    /// Determines the shape of the object making locations in the user's location list.
    case UserLocationShape = "UserLocationShape"
    #endif
    /// Boolean: Reset hour labels periodically. Performance debug option.
    case ResetHoursPeriodically = "ResetHoursPeriodically"
    /// Double: How often to reset hours. Performance debug option.
    case ResetHourTimeInterval = "ResetHourTimeInterval"
    /// NSColor: The color of the 3D background
    case BackgroundColor3D = "BackgroundColor3D"
    /// Boolean: If true, an ambient light (rather than sun and moon lights) is used.
    case UseAmbientLight = "UseAmbientLight"
    /// Boolean: If true, user POI locations show light emission. If false, no emission is used.
    case ShowPOIEmission = "ShowPOIEmission"
    /// Boolean: If true, the 3D view will try to attract people via animation and other effects.
    case InAttractMode = "InAttractMode"
    /// Boolean: If true, the scene's camera is set to HDR mode.
    case UseHDRCamera = "UseHDRCamera"
    /// NSColor: Color of the hours.
    case HourColor = "HourColor"
    /// String: Name of the hour font.
    case HourFontName = "HourFontName"
    /// NSColor: Color of major grid lines.
    case GridLineColor = "GridLineColor"
    /// NSColor: Color of minor grid lines.
    case MinorGridLineColor = "MinorGridLineColor"
    /// CGFloat: User camera field of view.
    case FieldOfView = "FieldOfView"
    /// Double: User camera orthographic scale value.
    case OrthographicScale = "OrthographicScale"
    /// Double: Camera's z-far value.
    case ZFar = "ZFar"
    /// Double: Camera's z-near value.
    case ZNear = "ZNear"
    /// CGFloat: Closest the user is allowed to zoom in.
    case ClosestZ = "ClosestZ"
    /// Integer: Number of sphere segments.
    case SphereSegmentCount = "SphereSegmentCount"
    /// Boolean: If true, grid lines are drawn on the map itself. If false, they are drawn
    /// semi-three dimensionally.
    case GridLinesDrawnOnMap = "GridLineDrawnOnMap"
    /// Boolean: If true, city names are drawn on the map itself. If false, they are drawn
    /// with 3D extruded text.
    case CityNamesDrawnOnMap = "CityNamesDrawnOnMap"
    /// Boolean: If true, earthquake magnitude values are drawn on the map itself. If false,
    /// they are drawn with 3D extruded text.
    case MagnitudeValuesDrawnOnMap = "MagnitudeValuesDrawnOnMap"
    /// NSColor: The color to use to draw earthquake region bords.
    case EarthquakeRegionBorderColor = "EarthquakeRegionBorderColor"
    /// Double: The width of earthquake borders.
    case EarthquakeRegionBorderWidth = "EarthquakeRegionBorderWidth"
    // Camera settings.
    /// SCNVector3: Initial position of the camera.
    case InitialCameraPosition = "InitialCameraPosition"
    /// Boolean: If true, `allowsCameraControl` is used to let the user control how the scene
    /// looks. If false, use the camera control implemented in Flatland.
    case UseSystemCameraControl = "UseSystemCameraControl"
    /// Boolean: It true, the user can zoom with Flatland's camera.
    case EnableZooming = "EnableZooming"
    /// Boolean: If true, the user can drag/rotate the scene with Flatland's camera.
    case EnableDragging = "EnableDragging"
    /// Boolean: If true, the user can move/translate the scene with Flatland's camera.
    case EnableMoving = "EnableMoving"
    /// Flatland's camera projection.
    case CameraProjection = "CameraProjection"
    /// CGFloat: The field of view for Flatland's camera system.
    case CameraFieldOfView = "CameraFieldOfView"
    /// Double: The orthographic scale for Flatland's camera system.
    case CameraOrthographicScale = "CameraOrthographicScale"
    #if DEBUG
    //3D debug settings.
    /// Render 3D elements as wireframes.
    case ShowWireframes = "ShowWireframes"
    /// Show bounding boxes around 3D elements.
    case ShowBoundingBoxes = "ShowBoundingBoxes"
    /// Show skeletons.
    case ShowSkeletons = "ShowSkeletons"
    /// Show node constraints.
    case ShowConstraints = "ShowConstraints"
    /// Show light influences.
    case ShowLightInfluences = "ShowLightInfluences"
    /// Show light extents.
    case ShowLightExtents = "ShowLightExtents"
    /// Show rendering statistics.
    case ShowStatistics = "ShowStatistics"
    #endif
    
    // MARK: - Performance and optimization settings.
    /// Boolean: If true, hours have a chamfer value set.
    case UseHourChamfer = "UseHourChamfer"
    /// Boolean: If true, live data labels have a chamfer value set.
    case UseLiveDataChamfer = "UseLiveDataChamfer"
    /// CGFloat: Determines text smoothness.
    case TextSmoothness = "TextSmoothness"
    
    // MARK: - Local and home locations.
    /// Boolean: Show user locations.
    case ShowUserLocations = "ShowUserLocations"
    /// Double?: The user's home latitude. If nil, not set.
    case LocalLatitude = "LocalLatitude"
    /// Double?: The user's home longitude. If nil, not set.
    case LocalLongitude = "LocalLongitude"
    /// String: Name of the user's home location.
    case LocalName = "LocalName"
    /// Integer: Time zone offset for the user's home location.
    case LocalTimeZoneOffset = "LocalTimeZoneOffset"
    /// Determines the shape of the object marking the user's home location.
    case HomeShape = "HomeShape"
    /// String: List of locations created by the user.
    case UserLocations = "UserLocations"
    /// Boolean: Determines if the user's location is shown, regardless if it is available.
    case ShowHomeLocation = "ShowHomeLocation"
    /// NSColor: Color of the home location for shapes that use it.
    case HomeColor = "HomeColor"
    
    // MARK: - City-related settings.
    /// Boolean: Show cities on the map. This is a filter boolean meaning if it is false,
    /// no cities will be shown regardless of their settings.
    case ShowCities = "ShowCities"
    /// Boolean: Show custom cities.
    case ShowCustomCities = "ShowCustomCities"
    /// Boolean: Show African cities.
    case ShowAfricanCities = "ShowAfricanCities"
    /// Boolean: Show Asian cities.
    case ShowAsianCities = "ShowAsianCities"
    /// Boolean: Show European cities.
    case ShowEuropeanCities = "ShowEuropeanCities"
    /// Boolean: Show North American cities.
    case ShowNorthAmericanCities = "ShowNorthAmericanCities"
    /// Boolean: Show South American cities.
    case ShowSouthAmericanCities = "ShowSouthAmericanCities"
    /// Boolean: Show national capital cities.
    case ShowCapitalCities = "ShowCapitalCities"
    /// Boolean: Show world cities.
    case ShowWorldCities = "ShowWorldCities"
    /// NSColor: Color to use for African cities.
    case AfricanCityColor = "AfricanCityColor"
    /// NSColor: Color to use for Asian cities.
    case AsianCityColor = "AsianCityColor"
    /// NSColor: Color to use for European cities.
    case EuropeanCityColor = "EuropeanCityColor"
    /// NSColor: Color to use for North American cities.
    case NorthAmericanCityColor = "NorthAmericanCityColor"
    /// NSColor: Color to use for South American cities.
    case SouthAmericanCityColor = "SouthAmericanCityColor"
    /// NSColor: Color to use for capital cities.
    case CapitalCityColor = "CapitalCityColors"
    /// NSColor: Color to use for world cities.
    case WorldCityColor = "WorldCityColors"
    /// NSColor: Color to use for custom cities.
    case CustomCityListColor = "CustomCityListColor"
    /// NSColor: Determines the shape of cities.
    case CityShapes = "CityShapes"
    /// Determines how the relative size of cities is calculated.
    case PopulationType = "PopulationType"
    /// The font to use for city names.
    case CityFontName = "CityFontName"
    /// List of user-customized cities.
    case CustomCityList = "CustomCityList"
    /// Boolean: City nodes glow if applicable.
    case CityNodesGlow = "CityNodesGlow"
    
    // MARK: - World Heritage Site settings
    /// Boolean: Determines whether World Heritage Sites are shown.
    case ShowWorldHeritageSites = "ShowWorldHeritageSites"
    /// Determines the type of site to display.
    case WorldHeritageSiteType = "WorldHeritageSiteType"
    /// County filter for World Heritage Sites.
    case SiteCountry = "SiteCountry"
    /// Inclusion year for sites.
    case SiteYear = "SiteYear"
    /// Inclusion year filter for sites.
    case SiteYearFilter = "SiteYearFilter"
    /// Boolean: If true, sites are plotted on the stencil layer. If false, sites are plotted as 3D objects.
    case PlotSitesAs2D = "PlotSitesAs2D"
    
    // MARK: - Asynchronous settings.
    //Earthquake asynchronous settings.
    /// Double: How often, in seconds, to fetch earthquake data.
    case EarthquakeFetchInterval = "EarthquakeFetchInterval"
    /// Boolean: Determines if remote earthquake data is fetched.
    case EnableEarthquakes = "EnableEarthquakes"
    /// How to modify the base color on a per-earthquake basis.
    case ColorDetermination = "ColorDetermination"
    /// NSColor: The base earthquake color.
    case BaseEarthquakeColor = "BaseEarthquakeColor"
    /// How to draw the earthquake.
    case EarthquakeShapes = "EarthquakeShapes"
    /// Boolean: Display only the largest earthquake in a region.
    case DisplayLargestOnly = "DisplayLargestOnly"
    /// Double: Radius for earthquake regions to determine when to suppress smaller
    /// earthquakes when `DisplayLargestOnly` is true.
    case EarthquakeRegionRadius = "EarthquakeRegionRadius"
    /// String: List of colors for various earthquake magnitudes.
    case EarthquakeMagnitudeColors = "EarthquakeMagnitudeColors"
    /// Determines how to list earthquakes.
    case EarthquakeListStyle = "EarthquakeListStyle"
    /// Boolean: Highlight recent earthquakes.
    case HighlightRecentEarthquakes = "HighlightRecentEarthquakes"
    /// The age an earthquake must be to be considered "recent."
    case RecentEarthquakeDefinition = "RecentEarthquakeDefinition"
    /// Texture to use for earthquake indicators that use textures.
    case EarthquakeTextures = "EarthquakeTextures"
    /// Earthquake indicator style.
    case EarthquakeStyles = "EarthquakeStyles"
    /// Earthquake indicator style for 2D earthquakes.
    case Earthquake2DStyles = "Earthquake2DStyles"
    /// Earthquake indicator color for indicators that use colors.
    case EarthquakeColor = "EarthquakeColor"
    /// String: Name of the font to use to display earthquake magnitudes.
    case EarthquakeFontName = "EarthquakeFontName"
    /// Age of earthquakes to view in the earthquake list dialog.
    case EarthquakeListAge = "EarthquakeListAge"
    /// Integer: Minimum magnitude earthquake to display in the earthquake list dialog.
    case EarthquakeDisplayMagnitude = "EarthquakeDisplayMagnitude"
    #if false
    /// Maximum distance (in kilometers) that earthquakes must be to be combined.
    case CombineDistance = "CombineDistance"
    #endif
    /// How (or if) to display earthquake magnitude values.
    case EarthquakeMagnitudeViews = "EarthquakeMagnitudeViews"
    /// NSColor: The color of the bars that indicate a combined earthquake.
    case CombinedEarthquakeColor = "CombinedEarthquakeColor"
    /// String: Contains all regions monitored for a set of earthquake parameters.
    /// - Warning: Do not access this setting directly.
    /// - Note: See also `GetEarthquakeRegions` and `SetEarthquakeRegions`.
    case EarthquakeRegions = "EarthquakeRegions"
    /// Boolean: Enables the visibility of 2D earthquake regions.
    case ShowEarthquakeRegions = "ShowEarthquakeRegions"
    /// Double: Minimum value that earthquakes must be to be included in any list.
    case GeneralMinimumMagnitude = "GeneralMinimumMagnitude"
    /// Boolean: If true, tiles from NASA servers are preloaded. Otherwise, they are not
    ///          loaded until the user requires them.
    case PreloadNASATiles = "PreloadNASATiles"
    /// List of earthquakes the use was notified about. Used to prevent excessive notifications.
    case NotifiedEarthquakes = "NotifiedEarthquakes"
    /// Where notifications appear.
    case NotifyLocation = "NotifyLocation"
    /// Boolean: Set according to the environment variable "enable_nasa_tiles". Not user
    ///          accessible. If "enable_nasa_tiles" is not present, true is put into this
    ///          settings.
    case EnableNASATiles = "EnableNASATiles"
    
    // MARK: - General settings.
    /// The last settings viewed by the user.
    case LastSettingsViewed = "LastSettingsViewed"
    /// Boolean: Determines if the splash screen is shown on start-up.
    case ShowSplashScreen = "ShowSplashScreen"
    /// Double: Amount of time the splash screen is shown, in seconds.
    case SplashScreenDuration = "SplashScreenDuration"
    
    #if DEBUG
    // MARK: - Time debug settings.
    /// Boolean: Enables debugging of time.
    case DebugTime = "DebugTime"
    /// Controls whether time is running or paused.
    case TimeControl = "TimeControl"
    /// Starting time one time resumes.
    case TestTime = "TestTime"
    /// Time will stop advancing once this time is reached.
    case StopTimeAt = "StopTimeAt"
    /// Double: Value to multipy time by.
    case TimeMultiplier = "TimeMultiplier"
    /// Boolean: Enables or disables the stop time.
    case EnableStopTime = "EnableStopTime"
    #endif
    
    // MARK: - Settings used in areas outside of the Settings system.
    /// Live data viewer.
    case LiveViewWindowFrame = "LiveViewWindowFrame"
    /// Earthquake data viewer.
    case EarthquakeViewWindowFrame = "EarthquakeViewWindowFrame"
}
