//
//  +ChangedSettingsHandler.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension GlobeView: SettingChangedProtocol
{
    /// Required by the `SettingChangedProtocol`.
    /// - Returns: ID of the class.
    func SubscriberID() -> UUID
    {
        return ClassID
    }
    
    /// Handle changed setting notifications.
    /// - Parameter Setting: The setting that was changed.
    /// - Parameter OldValue: The previous value of the setting (may be nil).
    /// - Parameter NewValue: The new value of the setting (may be nil).
    func SettingChanged(Setting: SettingKeys, OldValue: Any?, NewValue: Any?)
    {
        switch Setting
        {
            case .HourType:
                if let NewHourType = NewValue as? HourValueTypes
                {
                    UpdateHourLabels(With: NewHourType)
                }
                
            case .UseHDRCamera:
                SetHDR()
                
            case .CityShapes:
                PlotCities()
                ApplyStencils(Caller: "SettingChanged(.CityShapes)")
                
            case .PopulationType:
                PlotCities()
                
            case .ShowHomeLocation:
                PlotCities()
                
            case .HomeColor:
                PlotCities()
                
            case .UserLocations:
                PlotCities()
                
            case .ShowUserLocations:
                PlotCities()
                
            case .HomeShape:
                PlotHomeLocation()
                
            case .PolarShape:
                PlotPolarShape()
                
            case .ShowWorldHeritageSites:
                ApplyStencils(Caller: "SettingChanged(.ShowWorldHeritageSites)")
                PlotWorldHeritageSites()
                
            case .WorldHeritageSiteType:
                ApplyStencils(Caller: "SettingChanged(.WorldHeritageSiteType)")
                PlotWorldHeritageSites()
                
            case .Show3DEquator, .Show3DTropics, .Show3DMinorGrid, .Show3DPolarCircles, .Show3DPrimeMeridians,
                 .MinorGrid3DGap, .Show3DGridLines, .GridLineColor, .MinorGridLineColor:
                SetLineLayer()
                ApplyStencils(Caller: "SettingChanged(.{Multiple})")
                
            case .Script:
                PlotPolarShape()
                UpdateHours()
                
            case .HourColor:
                UpdateHours()
                
            case .ShowMoonLight:
                SetMoonlight(Show: Settings.GetBool(.ShowMoonLight))
                
            case .ShowPOIEmission:
                if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                {
                    PlotCities()
                }
                
            case .EarthquakeStyles:
                ClearEarthquakes()
                PlotEarthquakes()
                
            case .RecentEarthquakeDefinition:
                ClearEarthquakes()
                PlotEarthquakes()
                
            case .EarthquakeTextures:
                ClearEarthquakes()
                PlotEarthquakes()
                
            case .EarthquakeColor:
                ClearEarthquakes()
                PlotEarthquakes()
                
            case .BaseEarthquakeColor:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        ClearEarthquakes()
                        PlotEarthquakes()
                    }
                }
                
            case .HighlightRecentEarthquakes:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        ClearEarthquakes()
                        PlotEarthquakes()
                    }
                }
                
            case .ColorDetermination:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        ClearEarthquakes()
                        PlotEarthquakes()
                        ApplyStencils(Caller: "SettingChanged(.ColorDetermination)")
                    }
                }
                
            case .EarthquakeShapes:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        ClearEarthquakes()
                        PlotEarthquakes()
                    }
                }
                
            case .EarthquakeMagnitudeColors:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        ClearEarthquakes()
                        PlotEarthquakes()
                        ApplyStencils(Caller: "SettingChanged(.EarthquakeMagnitudeColors)")
                    }
                }
                
            case .UseAmbientLight:
                SetupLights()
                
            case .EarthquakeFontName:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        ClearEarthquakes()
                        PlotEarthquakes()
                        ApplyStencils(Caller: ".EarthquakeFontName")
                    }
                }
                
            case .EarthquakeMagnitudeViews:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        ClearEarthquakes()
                        PlotEarthquakes()
                    }
                }
                
            case .CombinedEarthquakeColor:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        ClearEarthquakes()
                        PlotEarthquakes()
                    }
                }
                
            case .CityFontName, .CityFontRelativeSize, .MagnitudeRelativeFontSize:
                PlotCities()
                ApplyStencils(Caller: "{.Multiple}")
                
            case .WorldCityColor, .AfricanCityColor, .AsianCityColor, .EuropeanCityColor,
                 .NorthAmericanCityColor, .SouthAmericanCityColor, .CapitalCityColor,
                 .CustomCityListColor, .CityNodesGlow, .PopulationColor:
                PlotCities()
                ApplyStencils()
                
            case .ShowCustomCities, .ShowAfricanCities, .ShowAsianCities,
                 .ShowEuropeanCities, .ShowNorthAmericanCities, .ShowSouthAmericanCities,
                 .ShowCapitalCities, .ShowWorldCities, .ShowCitiesByPopulation,
                 .PopulationRank, .PopulationRankIsMetro, .PopulationFilterValue,
                 .PopulationFilterGreater, .PopulationFilterType:
                PlotCities()
                ApplyStencils()
                
            case .CustomCityList:
                if Settings.GetBool(.ShowCustomCities)
                {
                    PlotCities()
                    ApplyStencils()
                }
                
            case .HourFontName:
                UpdateHours()
                
            case .GridLinesDrawnOnMap, .MagnitudeValuesDrawnOnMap,
                 .EarthquakeRegions, .ShowEarthquakeRegions,
                 .CityNamesDrawnOnMap:
                if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .CubicWorld) == .Globe3D
                {
                    ClearEarthquakes()
                    ApplyStencils(Caller: "SettingChanged(.{Multiple})")
                }
                
            case .UseSystemCameraControl:
                InitializeSceneCamera(!Settings.GetBool(.UseSystemCameraControl))
                
            case .CameraProjection, .CameraOrthographicScale, .CameraFieldOfView:
                UpdateFlatlandCamera()
                
            #if DEBUG
            case .ShowSkeletons, .ShowWireframes, .ShowBoundingBoxes, .ShowLightExtents,
                 .ShowLightInfluences, .ShowConstraints, .ShowStatistics:
                let ViewType = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .CubicWorld)
                if ViewType == .Globe3D || ViewType == .CubicWorld
                {
                    Settings.QueryBool(.ShowStatistics)
                    {
                        Show in
                        showsStatistics = Show
                    }
                    var DebugTypes = [DebugOptions3D]()
                    Settings.QueryBool(.ShowSkeletons)
                    {
                        Show in
                        if Show
                        {
                            DebugTypes.append(.Skeleton)
                        }
                    }
                    Settings.QueryBool(.ShowBoundingBoxes)
                    {
                        Show in
                        if Show
                        {
                            DebugTypes.append(.BoundingBoxes)
                        }
                    }
                    Settings.QueryBool(.ShowWireframes)
                    {
                        Show in
                        if Show
                        {
                            DebugTypes.append(.WireFrame)
                        }
                    }
                    Settings.QueryBool(.ShowLightInfluences)
                    {
                        Show in
                        if Show
                        {
                            DebugTypes.append(.LightInfluences)
                        }
                    }
                    Settings.QueryBool(.ShowLightExtents)
                    {
                        Show in
                        if Show
                        {
                            DebugTypes.append(.LightExtents)
                        }
                    }
                    Settings.QueryBool(.ShowConstraints)
                    {
                        Show in
                        if Show
                        {
                            DebugTypes.append(.Constraints)
                        }
                    }
                    /*
                    Settings.QueryBool(.ShowCamera)
                    {
                        Show in
                        if Show
                        {
                            DebugTypes.append(.Cameras)
                        }
                    }
 */
                    SetDebugOption(DebugTypes)
                }
            #endif
            
            default:
                return
        }
        Debug.Print("Setting \(Setting) handled in GlobeView")
    }
}
