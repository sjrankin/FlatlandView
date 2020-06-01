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
    case MapType = "MapType"
    case ViewType = "ViewType"
    case ShowNight = "ShowNight"
    case NightMaskAlpha = "NightMaskAlpha"
    case HourType = "HourType"
    case TimeLabel = "TimeLabel"
    case ShowGrid = "ShowGrid"
    case ShowSun = "ShowSun"
    case CurrentMap = "CurrentMap"
    
    //2D view grid settings.
    case Show2DEquator = "Show2DEquator"
    case Show2DPolarCircles = "Show2DPolarCircles"
    case Show2DTropics = "Show2DTropics"
    case Show2DPrimeMeridians = "Show2DPrimeMeridians"
    case Show2DNoonMeridians = "Show2DNoonMeridians"
    
    //3D view grid settings.
    case Show3DEquator = "Show3DEquator"
    case Show3DPolarCircles = "Show3DPolarCircles"
    case Show3DTropics = "Show3DTropics"
    case Show3DPrimeMeridians = "Show3DPrimeMeridians"
    case Show3DMinorGrid = "Show3DMinorGrid"
    case MinorGrid3DGap = "MinorGrid3DGap"
    
    //Local location.
    case ShowUserLocation = "ShowUserLocation"
    case LocalLatitude = "LocalLatitude"
    case LocalLongitude = "LocalLongitude"
    case LocalName = "LocalName"
    case LocalTimeZoneOffset = "LocalTimeZoneOffset"
    
    //User locations.
    case UserLocations = "UserLocations"
    
    //City-related settings.
    case ShowCities = "ShowCities"
    case AfricanCityColor = "AfricanCityColor"
    case AsianCityColor = "AsianCityColor"
    case EuropeanCityColor = "EuropeanCityColor"
    case NorthAmericanCityColor = "NorthAmericanCityColor"
    case SouthAmericanCityColor = "SouthAmericanCityColor"
    case CapitalCityColor = "CapitalCityColors"
    case WorldCityColor = "WorldCityColors"
    
    //World Heritage Site settings
    case SiteTypeFilter = "SiteTypeFilter"
    case SiteCountry = "SiteCountry"
    case SiteYear = "SiteYear"
    case SiteYearFilter = "SiteYearFilter"
}
