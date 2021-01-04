//
//  EnumList.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/12/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

typealias EnumCases = [String]

class EnumList
{
    /// Map between enum names and their cases.
    private static var _Enums: [String: EnumCases] =
    [
        "SettingKeys": SettingKeys.allCases.map{"\($0)"},
        "ViewTypes": ViewTypes.allCases.map{"\($0)"},
        "EarthquakeNotifications": EarthquakeNotifications.allCases.map{"\($0)"},
        "NotificationSounds": NotificationSounds.allCases.map{"\($0)"},
        "HourValueTypes": HourValueTypes.allCases.map{"\($0)"},
        "TimeLabels": TimeLabels.allCases.map{"\($0)"},
        "SunLocations": SunLocations.allCases.map{"\($0)"},
        "CityColorOverrides": CityColorOverrides.allCases.map{"\($0)"},
        "Continents": Continents.allCases.map{"\($0)"},
        "CityGroups": CityGroups.allCases.map{"\($0)"},
        "YearFilters": YearFilters.allCases.map{"\($0)"},
        "SiteTypeFilters": WorldHeritageSiteTypes.allCases.map{"\($0)"},
        "PolarShapes": PolarShapes.allCases.map{"\($0)"},
        "Scripts": Scripts.allCases.map{"\($0)"},
        "CityDisplayTypes": CityDisplayTypes.allCases.map{"\($0)"},
        "PopulationTypes": PopulationTypes.allCases.map{"\($0)"},
        "HomeShapes": HomeShapes.allCases.map{"\($0)"},
        "SunNames": SunNames.allCases.map{"\($0)"},
        "NightDarknesses": NightDarknesses.allCases.map{"\($0)"},
        "PopulationFilterTypes": PopulationFilterTypes.allCases.map{"\($0)"},
        "LocationShapes2D": LocationShapes2D.allCases.map{"\($0)"},
        "StarSpeeds": StarSpeeds.allCases.map{"\($0)"},
        "AsynchronousDataCategories": AsynchronousDataCategories.allCases.map{"\($0)"},
        "EarthquakeColorMethods": EarthquakeColorMethods.allCases.map{"\($0)"},
        "TimeUnits": TimeUnits.allCases.map{"\($0)"},
        "EarthquakeMagnitudes": EarthquakeMagnitudes.allCases.map{"\($0)"},
        "EarthquakeAges": EarthquakeAges.allCases.map{"\($0)"},
        "EarthquakeShapes": EarthquakeShapes.allCases.map{"\($0)"},
        "EarthquakeIndicators": EarthquakeIndicators.allCases.map{"\($0)"},
        "EarthquakeMagnitudeViews": EarthquakeMagnitudeViews.allCases.map{"\($0)"},
        "EarthquakeIndicators2D": EarthquakeIndicators2D.allCases.map{"\($0)"},
        "MultipleQuakeOrders": MultipleQuakeOrders.allCases.map{"\($0)"},
        "EarthquakeRecents": EarthquakeRecents.allCases.map{"\($0)"},
        "EarthquakeTextures": EarthquakeTextures.allCases.map{"\($0)"},
        "EarthquakeListStyles": EarthquakeListStyles.allCases.map{"\($0)"},
        "StencilTypes": StencilTypes.allCases.map{"\($0)"},
        "SettingGroups": SettingGroups.allCases.map{"\($0)"},
        "TimeControls": TimeControls.allCases.map{"\($0)"},
        "LayerNames": LayerNames.allCases.map{"\($0)"},
        "CameraProjections": CameraProjections.allCases.map{"\($0)"},
        "GlobeNodeNames": GlobeNodeNames.allCases.map{"\($0)"},
        "NodeNames2D": NodeNames2D.allCases.map{"\($0)"},
        "QuakeShapes2D": QuakeShapes2D.allCases.map{"\($0)"},
        "NotificationLocations": NotificationLocations.allCases.map{"\($0)"},
        "StartupTasks": StartupTasks.allCases.map{"\($0)"},
        "EnvironmentVars": EnvironmentVars.allCases.map{"\($0)"},
        "RelativeSizes": RelativeSizes.allCases.map{"\($0)"},
        "GlobeLayers": GlobeLayers.allCases.map{"\($0)"},
        "LightNames": LightNames.allCases.map{"\($0)"},
        "Debug_MapTypes": Debug_MapTypes.allCases.map{"\($0)"},
        "Defaults": Defaults.allCases.map{"\($0) = \($0.rawValue)"},
        "FlatConstants": FlatConstants.allCases.map{"\($0) = \($0.rawValue)"},
        "RectMode": RectMode.allCases.map{"\($0) = \($0.rawValue)"},
        "LayerZLevels": LayerZLevels.allCases.map{"\($0) = \($0.rawValue)"},
        "LightMasks3D": LightMasks3D.allCases.map{"\($0) = \($0.rawValue)"},
        "Quake3D": Quake3D.allCases.map{"\($0) = \($0.rawValue)"},
        "LightMasks2D": LightMasks2D.allCases.map{"\($0) = \($0.rawValue)"},
        "Constants": Constants.allCases.map{"\($0) = \($0.rawValue)"},
        "Longitudes": Longitudes.allCases.map{"\($0) = \($0.rawValue)"},
        "Latitudes": Latitudes.allCases.map{"\($0) = \($0.rawValue)"},
        "PhysicalConstants": PhysicalConstants.allCases.map{"\($0) = \($0.rawValue)"},
        "GravitionParameters": GravitationParameters.allCases.map{"\($0) = \($0.rawValue)"},
        "NodeScales3D": NodeScales3D.allCases.map{"\($0) = \($0.rawValue)"},
        "NodeScales2D": NodeScales2D.allCases.map{"\($0) = \($0.rawValue)"},
        "TextSmoothnesses": TextSmoothnesses.allCases.map{"\($0) = \($0.rawValue)"},
        "GlobeRadius": GlobeRadius.allCases.map{"\($0) = \($0.rawValue)"},
        "FileIONames": FileIONames.allCases.map{"\($0) = \($0.rawValue)"},
        "MappableTableNames": MappableTableNames.allCases.map{"\($0)"},
        "POITableNames": POITableNames.allCases.map{"\($0)"},
        //"DebugOptions3D": DebugOptions3D.allCases.map{"\($0) = \($0.rawValue)"},
        "StencilStages": StencilStages.allCases.map{"\($0) = \($0.rawValue)"},
        "NodeUsages": NodeUsages.allCases.map{"\($0) = \($0.rawValue)"},
        "DebugAxes": DebugAxes.allCases.map{"\($0) = \($0.rawValue)"},
        "SceneJitters": SceneJitters.allCases.map{"\($0) = \($0.rawValue)"},
    ]
    
    #if DEBUG
    /// Map between debug enums and their cases.
    private static var _DebugEnums: [String: EnumCases] =
    [
        "DebugOptions3D": DebugOptions3D.allCases.map{"\($0) = \($0.rawValue)"}
    ]
    #endif
    
    /// Returns a map of enum names and their cases.
    /// - Note: If compiled such that `#DEBUG` is true, more values may be returned.
    public static var Enums: [String: EnumCases]
    {
        get
        {
            #if DEBUG
            var Scratch = _Enums
            for (Name, Values) in _DebugEnums
            {
                Scratch[Name] = Values
            }
            return Scratch
            #else
            return _Enums
            #endif
        }
    }
}
