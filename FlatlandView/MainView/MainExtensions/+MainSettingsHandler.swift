//
//  +MainSettingsHandler.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainController: SettingChangedProtocol
{
    // MARK: - Setting changed handler
    
    func SubscriberID() -> UUID
    {
        return ClassID
    }
    
    /// Handle changes that affect Flatland overall or that need to take place at a main program level. Other
    /// changes may be handled lower in the code.
    /// - Parameter Setting: The setting that changed.
    /// - Parameter OldValue: The value of the setting before it was changed. May be nil.
    /// - Parameter NewValue: The new value of the setting. May be nil.
    func SettingChanged(Setting: SettingKeys, OldValue: Any?, NewValue: Any?)
    {
        switch Setting
        {
            case .MapType:
                let NewMap = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
                let MapViewType = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatNorthCenter)
                switch MapViewType
                {
                    case .Globe3D:
                        Main3DView.play(self)
                        Main2DView.pause(self)
                        Rect2DView.pause(self)
                        let (Earth, Sea) = Main3DView.MakeMaps(NewMap)
                        if Sea != nil
                        {
                            Main3DView.AddEarth()
                        }
                        else
                        {
                            Main3DView.ChangeEarthBaseMap(To: Earth)
                        }
                        if Settings.GetBool(.EnableEarthquakes)
                        {
                            Main3DView.ClearEarthquakes()
                            Main3DView.PlotEarthquakes()
                        }
                        
                    case .FlatNorthCenter, .FlatSouthCenter:
                        Main3DView.pause(self)
                        Main2DView.play(self)
                        Rect2DView.pause(self)
                        if let FlatImage = MapManager.ImageFor(MapType: NewMap, ViewType: MapViewType)
                        {
                            Main2DView.ApplyNewMap(FlatImage)
                            Main2DView.PlotEarthquakes(LatestEarthquakes, Replot: true)
                        }
                        else
                        {
                            Debug.Print("MapManager.ImageFor(\(NewMap), \(MapViewType)) returned nil for image in \(#function)")
                        }
                        
                    case .Rectangular:
                        Main3DView.pause(self)
                        Main2DView.pause(self)
                        Rect2DView.play(self)
                        if let FlatImage = MapManager.ImageFor(MapType: NewMap, ViewType: MapViewType)
                        {
                            Rect2DView.ApplyNewMap(FlatImage)
                            Rect2DView.PlotEarthquakes(LatestEarthquakes, Replot: true)
                        }
                        else
                        {
                            Debug.Print("MapManager.ImageFor(\(NewMap), \(MapViewType)) returned nil for image in \(#function)")
                        }
                        
                    default:
                        break
                }
                
            case .ViewType:
                if let New = NewValue as? ViewTypes
                {
                    var IsFlat = false
                    switch New
                    {
                        case .FlatNorthCenter, .FlatSouthCenter, .Rectangular:
                            IsFlat = true
                            
                        case .CubicWorld:
                            Main3DView.AddEarth()
                            IsFlat = false
                            
                        case .Globe3D:
                            IsFlat = false
                            Main3DView.AddEarth()
                            if Settings.GetBool(.EnableEarthquakes)
                            {
                                Main3DView.PlotEarthquakes()
                            }
                    }
                    SetFlatMode(IsFlat)
                }
                
            case .SunType:
                UpdateSunLocations()
                
            case .EnableEarthquakes:
                if Settings.GetBool(.EnableEarthquakes)
                {
                    let FetchInterval = Settings.GetDouble(.EarthquakeFetchInterval, 60.0)
                    Earthquakes?.GetEarthquakes(Every: FetchInterval)
                    switch Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D)
                    {
                        case .Globe3D:
                            Main3DView.ClearEarthquakes()
                            Main3DView.PlotEarthquakes()
                            Main3DView.ApplyAllStencils()
                            
                        case .FlatNorthCenter, .FlatSouthCenter:
                            Main2DView.Remove2DEarthquakes()
                            Main2DView.Plot2DEarthquakes(PreviousEarthquakes)
                            
                        case .Rectangular:
                            Rect2DView.Remove2DEarthquakes()
                            Rect2DView.Plot2DEarthquakes(PreviousEarthquakes)
                            
                        default:
                            break
                    }
                }
                else
                {
                    Earthquakes?.StopReceivingEarthquakes()
                    Main3DView.ClearEarthquakes()
                    Main3DView.ApplyAllStencils()
                    Main2DView.Remove2DEarthquakes()
                    Rect2DView.Remove2DEarthquakes()
                }
                
            case .EarthquakeFetchInterval:
                let FetchInterval = Settings.GetDouble(.EarthquakeFetchInterval, 60.0)
                Earthquakes?.StopReceivingEarthquakes()
                Earthquakes?.GetEarthquakes(Every: FetchInterval)
                
            case .LocalLongitude, .LocalLatitude:
                (view.window?.windowController as? MainWindow)!.HourSegment.setEnabled(Settings.HaveLocalLocation(), forSegment: 3)
                
            case .BackgroundColor3D:
                let NewBackgroundColor = Settings.GetColor(.BackgroundColor3D, NSColor.black)
                BackgroundView.layer?.backgroundColor = NewBackgroundColor.cgColor
                let Opposite = Utility.OppositeColor(From: NewBackgroundColor)
                UpdateScreenText(With: Opposite)
                
            case .WorldIsLocked:
                //Just need to update user interface elements.
                SetWorldLock(Settings.GetBool(.WorldIsLocked))
                
            case .FollowMouse:
                SetMouseLocationVisibility(Visible: Settings.GetBool(.FollowMouse))
                
            default:
                return
        }
        
        Debug.Print("Setting \(Setting) handled in MainController")
    }
}
