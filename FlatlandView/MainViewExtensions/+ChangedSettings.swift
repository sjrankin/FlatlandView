//
//  +ChangedSettings.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/28/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainView: SettingChangedProtocol
{
    // MARK: - Settings changed required functions.
    
    /// ID of this class in relation to the settings changed protocol.
    func SubscriberID() -> UUID
    {
        return UUID(uuidString: "66629111-b430-4231-af5a-e39f35ae7883")!
    }
    
    /// Handle changed settings. Settings may be changed from anywhere at any time. This function
    /// will update the view when the setting change is reported.
    /// - Parameter Setting: The setting that changed.
    /// - Parameter OldValue: The value of the setting before the change.
    /// - Parameter NewValue: The new value of the setting.
    func SettingChanged(Setting: SettingTypes, OldValue: Any?, NewValue: Any?)
    {
        switch Setting
        {
            case .InAttractMode:
                let CurrentMode = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatNorthCenter)
                if CurrentMode == .Globe3D || CurrentMode == .CubicWorld
                {
                    World3DView.SetAttractMode()
                }
                
            case .MapType:
                let NewMap = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
                let MapViewType = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatNorthCenter)
                #if true
                if MapViewType == .Globe3D
                {
                    let (Earth, Sea) = World3DView.MakeMaps(NewMap)
                    if Sea != nil
                    {
                        World3DView.AddEarth()
                    }
                    else
                    {
                        World3DView.ChangeEarthBaseMap(To: Earth)
                    }
                    if Settings.GetBool(.EnableEarthquakes)
                    {
                        World3DView.PlotEarthquakes()
                    }
                }
                else
                {
                    FlatViewMainImage.image = MapManager.ImageFor(MapType: NewMap, ViewType: MapViewType)
                    Plot2DEarthquakes(LatestEarthquakes, Replot: true)
                }
                #else
                if let InterimImage: NSImage = MapManager.ImageFor(MapType: NewMap, ViewType: MapViewType)
                {
                    FlatViewMainImage.image = FinalizeImage(InterimImage)
                    World3DView.AddEarth()
                }
                else
                {
                    print("Error loading map \(NewMap) for view \(MapViewType)")
                }
                if MapViewType == .Globe3D
                {
                    if Settings.GetBool(.EnableEarthquakes)
                    {
                        World3DView.PlotEarthquakes()
                    }
                    Plot2DEarthquakes(LatestEarthquakes, Replot: true)
                }
                #endif
                
            case .ViewType:
                if let New = NewValue as? ViewTypes
                {
                    var IsFlat = false
                    switch New
                    {
                        case .FlatNorthCenter, .FlatSouthCenter:
                            IsFlat = true
                            if Settings.GetBool(.EnableEarthquakes)
                            {
                                Remove2DEarthquakes()
                                Plot2DEarthquakes(LatestEarthquakes, Replot: true)
                            }
                            
                        case .CubicWorld:
                            World3DView.AddEarth()
                            IsFlat = false
                            
                        case .Globe3D:
                            World3DView.AddEarth()
                            IsFlat = false
                            if Settings.GetBool(.EnableEarthquakes)
                            {
                                World3DView.PlotEarthquakes()
                            }
                    }
                    SetFlatlandVisibility(FlatIsVisible: IsFlat)
                }
                
            case .ShowNight:
                SetNightMask()
                
            case .NightDarkness:
                let NewMask = GetNightMask(ForDate: Date())
                NightMaskImageView.image = NewMask
                
            case .HourType:
                if let NewHourType = NewValue as? HourValueTypes
                {
                    World3DView.UpdateHourLabels(With: NewHourType)
                }
                
            case .UseHDRCamera:
                World3DView.SetHDR()
                
            case .SunType:
                UpdateSunLocations()
                
            case .CityShapes:
                World3DView.PlotCities()
                World3DView.ApplyStencils(Caller: "SettingChanged(.CityShapes)")
                
            case .PopulationType:
                World3DView.PlotCities()
                
            case .ShowHomeLocation:
                World3DView.PlotCities()
                
            case .HomeColor:
                World3DView.PlotCities()
                
            case .UserLocations:
                World3DView.PlotCities()
                
            case .ShowUserLocations:
                World3DView.PlotCities()
                
            case .HomeShape:
                World3DView.PlotHomeLocation()
                
            case .PolarShape:
                World3DView.PlotPolarShape()
                
            case .ShowWorldHeritageSites:
                World3DView.PlotWorldHeritageSites()
                
            case .WorldHeritageSiteType:
                World3DView.PlotWorldHeritageSites()
                
            case .Show3DEquator, .Show3DTropics, .Show3DMinorGrid, .Show3DPolarCircles, .Show3DPrimeMeridians,
                 .MinorGrid3DGap, .Show3DGridLines, .GridLineColor, .MinorGridLineColor:
                World3DView.SetLineLayer()
                World3DView.ApplyStencils(Caller: "SettingChanged(.{Multiple})")
                
            case .LocalLongitude, .LocalLatitude:
                (view.window?.windowController as? MainWindow)!.HourSegment.setEnabled(Settings.HaveLocalLocation(), forSegment: 3)
                
            case .ShowLocalData:
                UpdateInfoGridVisibility(Show: Settings.GetBool(.ShowLocalData))
                
            case .Script:
                World3DView.PlotPolarShape()
                World3DView.UpdateHours()
                
            case .HourColor:
                World3DView.UpdateHours()
                
            case .ShowMoonLight:
                World3DView.SetMoonlight(Show: Settings.GetBool(.ShowMoonLight))
                
            case .StarSpeeds:
                var SpeedValue = 1.0
                let Speed = Settings.GetEnum(ForKey: .StarSpeeds, EnumType: StarSpeeds.self, Default: .Medium)
                switch Speed
                {
                    case .Off:
                        StarView.Hide()
                    
                    case .Slow:
                        SpeedValue = 1.0
                        
                    case .Medium:
                        SpeedValue = 3.0
                        
                    case .Fast:
                        SpeedValue = 7.0
                }
                let ViewType = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .CubicWorld)
                if ViewType == .CubicWorld || ViewType == .Globe3D
                {
                    if Speed != .Off
                    {
                        StarView.Show(SpeedMultiplier: SpeedValue)
                    }
                }
                
            case .ShowPOIEmission:
                if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                {
                    World3DView.PlotCities()
                }
                
            case .EarthquakeStyles:
                World3DView.ClearEarthquakes()
                World3DView.PlotEarthquakes()
                
            case .EnableEarthquakes:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    let FetchInterval = Settings.GetDouble(.EarthquakeFetchInterval, 60.0)
                    Earthquakes?.GetEarthquakes(Every: FetchInterval)
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        World3DView.ClearEarthquakes()
                        World3DView.PlotEarthquakes()
                        World3DView.ApplyStencils(Caller: "SettingChanged(.EnableEarthquakes)")
                    }
                }
                else
                {
                    Earthquakes?.StopReceivingEarthquakes()
                    World3DView.ClearEarthquakes()
                    World3DView.ApplyStencils(Caller: "SettingChanged(.EnableEarthquakes)")
                }
                
            case .RecentEarthquakeDefinition:
                World3DView.ClearEarthquakes()
                World3DView.PlotEarthquakes()
                
            case .EarthquakeTextures:
                World3DView.ClearEarthquakes()
                World3DView.PlotEarthquakes()
                
            case .EarthquakeColor:
                World3DView.ClearEarthquakes()
                World3DView.PlotEarthquakes()
                
            case .EarthquakeFetchInterval:
                let FetchInterval = Settings.GetDouble(.EarthquakeFetchInterval, 60.0)
                Earthquakes?.StopReceivingEarthquakes()
                Earthquakes?.GetEarthquakes(Every: FetchInterval)
                
            case .BaseEarthquakeColor:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        World3DView.ClearEarthquakes()
                        World3DView.PlotEarthquakes()
                    }
                }
                
            case .HighlightRecentEarthquakes:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        World3DView.ClearEarthquakes()
                        World3DView.PlotEarthquakes()
                    }
                }
                
                #if false
            case .EarthquakeRegions:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    World3DView.ClearEarthquakes()
                    World3DView.PlotEarthquakes()
                    //Need to call Plot2DEarthquakes here?
                }
                #endif
                
            case .ColorDetermination:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        World3DView.ClearEarthquakes()
                        World3DView.PlotEarthquakes()
                        World3DView.ApplyStencils(Caller: "SettingChanged(.ColorDetermination)")
                    }
                }
                
            case .EarthquakeShapes:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        World3DView.ClearEarthquakes()
                        World3DView.PlotEarthquakes()
                    }
                }
                
            case .EarthquakeMagnitudeColors:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        World3DView.ClearEarthquakes()
                        World3DView.PlotEarthquakes()
                        World3DView.ApplyStencils(Caller: "SettingChanged(.EarthquakeMagnitudeColors)")
                    }
                }
                
            case .BackgroundColor3D:
                let NewBackgroundColor = Settings.GetColor(.BackgroundColor3D, NSColor.black)
                BackgroundView.layer?.backgroundColor = NewBackgroundColor.cgColor
                let Opposite = Utility.OppositeColor(From: NewBackgroundColor)
                UpdateScreenText(With: Opposite)
                
            case .UseAmbientLight:
                World3DView.SetupLights()
                
            case .EarthquakeFontName:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        World3DView.ClearEarthquakes()
                        World3DView.PlotEarthquakes()
                        World3DView.ApplyStencils(Caller: ".EarthquakeFontName")
                    }
                }
                
            case .EarthquakeMagnitudeViews:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        World3DView.ClearEarthquakes()
                        World3DView.PlotEarthquakes()
                    }
                }
                
            case .CombinedEarthquakeColor:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D) == .Globe3D
                    {
                        World3DView.ClearEarthquakes()
                        World3DView.PlotEarthquakes()
                    }
                }
                
            case .Earthquake2DStyles:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    Plot2DEarthquakes(LatestEarthquakes, Replot: true)
                }
                
            case .CityFontName:
                World3DView.PlotCities()
                World3DView.ApplyStencils(Caller: ".CityFontName")
                
            case .WorldCityColor, .AfricanCityColor, .AsianCityColor, .EuropeanCityColor,
                 .NorthAmericanCityColor, .SouthAmericanCityColor, .CapitalCityColor,
                 .CustomCityListColor:
                World3DView.PlotCities()
                
            case .ShowCustomCities, .ShowAfricanCities, .ShowAsianCities,
                 .ShowEuropeanCities, .ShowNorthAmericanCities, .ShowSouthAmericanCities,
                 .ShowCapitalCities, .ShowWorldCities:
                World3DView.PlotCities()
                
            case .CustomCityList:
                if Settings.GetBool(.ShowCustomCities)
                {
                World3DView.PlotCities()
                }
                
            case .HourFontName:
                World3DView.UpdateHours()
                
            case .GridLinesDrawnOnMap, .MagnitudeValuesDrawnOnMap,
                 .EarthquakeRegions, .ShowEarthquakeRegions,
                 .CityNamesDrawnOnMap:
                if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .CubicWorld) == .Globe3D
                {
                    World3DView.ClearEarthquakes()
                    World3DView.ApplyStencils(Caller: "SettingChanged(.{Multiple})")
                }
                
            #if DEBUG
            case .ShowSkeletons, .ShowWireframes, .ShowBoundingBoxes, .ShowLightExtents,
                 .ShowLightInfluences, .ShowConstraints, .ShowStatistics:
                let ViewType = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .CubicWorld)
                if ViewType == .Globe3D || ViewType == .CubicWorld
                {
                    Settings.QueryBool(.ShowStatistics)
                    {
                        Show in
                        World3DView.showsStatistics = Show
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
                    World3DView.SetDebugOption(DebugTypes)
                }
            #endif
            
            #if DEBUG
            case .TimeControl:
                if Settings.GetBool(.DebugTime)
                {
                    
                }
                
            case .DebugTime:
                if Settings.GetBool(.DebugTime)
                {
                    Settings.SetBool(.InAttractMode, false)
                    DebugTimeValue.textColor = NSColor.white
                    DebugTimeValue.isHidden = false
                    DebugTimeLabel.textColor = NSColor.white
                    DebugTimeLabel.isHidden = false
                    DebugRotationalLabel.textColor = NSColor.white
                    DebugRotationalLabel.isHidden = false
                    DebugRotationalValue.textColor = NSColor.white
                    DebugRotationalValue.isHidden = false
                }
                else
                {
                    DebugTimeValue.textColor = NSColor.white
                    DebugTimeValue.isHidden = true
                    DebugTimeLabel.textColor = NSColor.white
                    DebugTimeLabel.isHidden = true
                    DebugRotationalLabel.textColor = NSColor.white
                    DebugRotationalLabel.isHidden = true
                    DebugRotationalValue.textColor = NSColor.white
                    DebugRotationalValue.isHidden = true
                }
                World3DView.StopClock()
                World3DView.StartClock()
                
            case .TestTime:
                if Settings.GetBool(.DebugTime)
                {
                    World3DView.SetDebugTime(Settings.GetDate(.DebugTime, Date()))
                }
                
            case .StopTimeAt:
                if Settings.GetBool(.DebugTime)
                {
                    World3DView.SetStopTime(Settings.GetDate(.StopTimeAt, Date()))
                }
                
            case .EnableStopTime:
                break
                
            case .TimeMultiplier:
                if Settings.GetBool(.DebugTime)
                {
                    
                }
            #endif
            
            default:
                #if DEBUG
                print("Unhandled setting change: \(Setting)")
                #else
                //Don't be so verbose when not in debug mode.
                break
                #endif
        }
    }
    
}
