//
//  +RectangleSettingsHandler.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension RectangleView
{
    func SubscriberID() -> UUID
    {
        return ClassID
    }
    
    /// Handle setting changes that affect us.
    /// - Parameter Setting: The setting that changed.
    /// - Parameter OldValue: The setting value before the change. May be nil.
    /// - Parameter NewValue: The setting value after the change. May be nil.
    func SettingChanged(Setting: SettingKeys, OldValue: Any?, NewValue: Any?)
    {
        switch Setting
        {
            case .MapType:
                let MapValue = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
                let CurrentView = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Rectangular)
                if [.Rectangular].contains(CurrentView)
                {
                    if let MapImage = MapManager.ImageFor(MapType: MapValue, ViewType: CurrentView)
                    {
                        let IntensityMultiplier = MapManager.GetLightMulitplier(MapType: MapValue)
                        PrimaryLightMultiplier = IntensityMultiplier
                        UpdatePolarLight(With: PrimaryLightMultiplier)
                        SetEarthMap(MapImage)
                    }
                }
                else
                {
                    HorizontalShift = 0
                }
                
            case .EnableEarthquakes:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    PlotEarthquakes(PreviousEarthquakes, Replot: true)
                }
                else
                {
                    Remove2DEarthquakes()
                }
                
            case .ViewType:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    PlotSameEarthquakes()
                }
                if Settings.GetBool(.ShowCities)
                {
                    PlotCities()
                }
                else
                {
                    HideCities()
                }
                UpdateLightsForShadows(ShowShadows: Settings.GetBool(.Show2DShadows))
                
            case .EarthquakeShape2D:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    PlotSameEarthquakes()
                }
                
            case .ShowNight:
                HorizontalShift = 0
                if Settings.GetBool(.ShowNight)
                {
                    AddNightMask()
                }
                else
                {
                    HideNightMask()
                }
                
            case .NightDarkness:
                if Settings.GetBool(.ShowNight)
                {
                    AddNightMask()
                }
                
            case .HourType:
                AddHours(HourRadius: FlatConstants.HourRadius.rawValue)
                
            case .UseHDRCamera:
                CameraNode.camera?.wantsHDR = Settings.GetBool(.UseHDRCamera)
                
            case .Earthquake2DStyles:
                break
                
            case .ShowCities:
                if Settings.GetBool(.ShowCities)
                {
                    PlotCities()
                }
                else
                {
                    HideCities()
                }
                
            case .Show2DShadows:
                UpdateLightsForShadows(ShowShadows: Settings.GetBool(.Show2DShadows))
                
            case .ShowWorldHeritageSites, .WorldHeritageSiteType:
                if Settings.GetBool(.ShowWorldHeritageSites)
                {
                    PlotWorldHeritageSites()
                }
                else
                {
                    HideWorldHeritageSites()
                }
                
            case .HighlightNodeUnderMouse:
                if PreviousNode != nil
                {
                    PreviousNode?.HideBoundingShape()
                }
                
            #if DEBUG
            case .ShowSkeletons, .ShowWireframes, .ShowBoundingBoxes, .ShowLightExtents,
                 .ShowLightInfluences, .ShowConstraints, .ShowStatistics, .RenderAsWireframe,
                 .ShowCreases, .ShowPhysicsShapes, .ShowPhysicsFields, .Enable3DDebugging,
                 .Debug3DMap:
                Settings.QueryBool(.ShowStatistics)
                {
                    Show in
                    showsStatistics = Show
                }
                var DebugTypes = [DebugOptions3D]()
                Settings.QueryBool(.ShowCreases)
                {
                    Show in
                    if Show
                    {
                        DebugTypes.append(.Creases)
                    }
                }
                Settings.QueryBool(.RenderAsWireframe)
                {
                    Show in
                    if Show
                    {
                        DebugTypes.append(.RenderWireFrame)
                    }
                }
                Settings.QueryBool(.ShowPhysicsShapes)
                {
                    Show in
                    if Show
                    {
                        DebugTypes.append(.PhysicsShapes)
                    }
                }
                Settings.QueryBool(.ShowPhysicsFields)
                {
                    Show in
                    if Show
                    {
                        DebugTypes.append(.PhysicsFields)
                    }
                }
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
                SetDebugOption(DebugTypes)
            #endif
            
            default:
                return
        }
        
        Debug.Print("Setting \(Setting) handled in RectangleView")
    }
}
