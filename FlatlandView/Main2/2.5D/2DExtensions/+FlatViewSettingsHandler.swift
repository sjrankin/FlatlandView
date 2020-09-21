//
//  +FlatViewSettingsHandler.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/20/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension FlatView
{
    func SubscriberID() -> UUID
    {
        return ClassID 
    }
    
    /// Handle setting changes that affect us.
    /// - Parameter Setting: The setting that changed.
    /// - Parameter OldValue: The setting value before the change. May be nil.
    /// - Parameter NewValue: The setting value after the change. May be nil.
    func SettingChanged(Setting: SettingTypes, OldValue: Any?, NewValue: Any?)
    {
        switch Setting
        {
            case .MapType:
                let MapValue = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
                let CurrentView = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatNorthCenter)
                if [.FlatNorthCenter, .FlatSouthCenter].contains(CurrentView)
                {
                    if let MapImage = MapManager.ImageFor(MapType: MapValue, ViewType: CurrentView)
                    {
                        SetEarthMap(MapImage)
                    }
                }
                
            case .ViewType:
                if Settings.GetBool(.ShowCities)
                {
                    PlotCities()
                }
                else
                {
                    HideCities()
                }
                
            case .ShowNight:
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
                
            case .EnableEarthquakes:
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
                
            #if DEBUG
            case .ShowSkeletons, .ShowWireframes, .ShowBoundingBoxes, .ShowLightExtents,
                 .ShowLightInfluences, .ShowConstraints, .ShowStatistics:
                let ViewType = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .CubicWorld)
                if ViewType == .FlatNorthCenter || ViewType == .FlatSouthCenter
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
                    SetDebugOption(DebugTypes)
                }
            #endif
            
            default:
                return
        }
        
        Debug.Print("Setting \(Setting) handled in FlatView")
    }
}
