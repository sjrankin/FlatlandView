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
    //Infrastructure/initialization-related settings.
    case InitializationFlag = "InitializationFlag"
    
    //Map-related settings.
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
    /// Boolean: If true, show the local data grid.
    case ShowLocalData = "ShowLocalData"
    /// Determines the script to use for certain display elements.
    case Script = "Script"
    /// The type of sun image to display.
    case SunType = "SunType"
    /// The type of view to show in the sample map image display.
    case SampleViewType = "SampleViewType"
    
    //2D view settings.
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
    
    //3D view settings.
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
    /// Boolean: Show moving stars in the background.
    case ShowMovingStars = "ShowMovingStars"
    /// Determines how fast stars move when visible.
        case StarSpeeds = "StarSpeeds"
    /// Boolean: Show moonlight on 3D globes for the night side.
    case ShowMoonLight = "ShowMoonLight"
    /// Determines the shape of the object marking the poles.
    case PolarShape = "PolarShape"
    /// Determines the shape of the object making locations in the user's location list.
    case UserLocationShape = "UserLocationShape"
    /// Boolean: Reset hour labels periodically. Performance debug option.
    case ResetHoursPeriodically = "ResetHoursPeriodically"
    /// Double: How often to reset hours. Performance debug option.
    case ResetHourTimeInterval = "ResetHourTimeInterval"
    
    //Local and home locations.
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
    
    //City-related settings.
    /// Boolean: Show cities on the map. This is a filter boolean meaning if it is false,
    /// no cities will be shown regardless of their settings.
    case ShowCities = "ShowCities"
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
    /// NSColor: Determines the shape of cities.
    case CityShapes = "CityShapes"
    /// Determines how the relative size of cities is calculated.
    case PopulationType = "PopulationType"
    
    //World Heritage Site settings
    /// Boolean: Determines whether World Heritage Sites are shown.
    case ShowWorldHeritageSites = "ShowWorldHeritageSites"
    /// Determines the type of site to display.
    case WorldHeritageSiteType = "WorldHeritageSiteType"
    /// Site type filter.
    case SiteTypeFilter = "SiteTypeFilter"
    /// County filter for World Heritage Sites.
    case SiteCountry = "SiteCountry"
    /// Inclusion year for sites.
    case SiteYear = "SiteYear"
    /// Inclusion year filter for sites.
    case SiteYearFilter = "SiteYearFilter"
}
