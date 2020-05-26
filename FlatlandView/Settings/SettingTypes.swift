//
//  SettingTypes.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

enum SettingTypes: String, CaseIterable
{
    //Infrastructure/initialization-related settings.
    case InitializationFlag = "InitializationFlag"
    
    //Map-related settings.
    case MapType = "MapType"
    case ShowNight = "ShowNight"
    case NightMaskAlpha = "NightMaskAlpha"
    case HourType = "HourType"
    case TimeLabel = "TimeLabel"
    case ShowGrid = "ShowGrid"
    
    //2D view grid settings.
    case ShowEquator = "ShowEquator"
    case ShowPolarCircles = "ShowPolarCircles"
    case ShowTropics = "ShowTropics"
    case ShowPrimeMeridians = "ShowPrimeMeridians"
    case ShowNoonMeridians = "ShowNoonMeridians"
    
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
