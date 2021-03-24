//
//  +FlatViewMenuHandling.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/23/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension FlatView
{
    // MARK: - Menu handling.
    
    override func menu(for event: NSEvent) -> NSMenu?
    {
        if event.type == .rightMouseDown
        {
            let Menu = NSMenu(title: "Actions")
            Menu.items =
                [
                    MakeWhatsHereMenu(),
                    NSMenuItem.separator(),
                    MakeMapMenu(),
                    MakeTimeMenu(),
                    NSMenuItem.separator(),
                    MakeResetMenu(),
                    MakeLockMenu(),
                    MakeSunMenu(),
                    NSMenuItem.separator(),
                    MakePOIMenu(),
                    MakeEarthquakeMenu(),
                    NSMenuItem.separator(),
                    MakeFollowMenu(),
                ]
            return Menu
        }
        return nil
    }
    
    func MakeWhatsHereMenu() -> NSMenuItem
    {
        UnderMouseMenu = NSMenuItem(title: "What's Here?", action: #selector(HandleWhatsHereMenu), keyEquivalent: "")
        return UnderMouseMenu!
    }
    
    @objc func HandleWhatsHereMenu(_ sender: Any)
    {
        
    }
    
    func SmallIconImage(_ Name: String) -> NSImage
    {
        var IconImage = NSImage(named: Name)
        IconImage = Utility.ResizeImage(Image: IconImage!, Longest: 24.0)
        return IconImage!
    }
    
    func MakeMapMenu() -> NSMenuItem
    {
        MapTypeMenu = NSMenuItem()
        MapTypeMenu?.title = "Map Type"
        MapTypeMenu?.submenu = NSMenu(title: "Map Types")
        
        let CurrentMap = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D)
        
        NCenter = NSMenuItem(title: "North-Centered Flat", action: #selector(Context_SetMapType), keyEquivalent: "")
        NCenter?.image = SmallIconImage("NorthCenterIcon")
        NCenter?.target = self
        NCenter?.state = CurrentMap == .FlatNorthCenter ? .on : .off
        SCenter = NSMenuItem(title: "South-Centered Flat", action: #selector(Context_SetMapType), keyEquivalent: "")
        SCenter?.image = SmallIconImage("SouthCenterIcon")
        SCenter?.target = self
        SCenter?.state = CurrentMap == .FlatSouthCenter ? .on : .off
        RectMap = NSMenuItem(title: "Rectangular Flat", action: #selector(Context_SetMapType), keyEquivalent: "")
        RectMap?.image = SmallIconImage("RectangleIcon")
        RectMap?.target = self
        RectMap?.state = CurrentMap == .Rectangular ? .on : .off
        GlobeMapMenu = NSMenuItem(title: "Globe", action: #selector(Context_SetMapType), keyEquivalent: "")
        GlobeMapMenu?.image = SmallIconImage("GlobeIcon")
        GlobeMapMenu?.target = self
        MapTypeMenu?.submenu?.items.append(NCenter!)
        MapTypeMenu?.submenu?.items.append(SCenter!)
        MapTypeMenu?.submenu?.items.append(RectMap!)
        MapTypeMenu?.submenu?.items.append(GlobeMapMenu!)
        Features.FeatureEnabled(.CubicEarth)
        {
            IsEnabled in
            if IsEnabled
            {
                self.GlobeMapMenu?.state = CurrentMap == .Globe3D ? .on : .off
                self.CubicMapMenu = NSMenuItem(title: "Cubic", action: #selector(self.Context_SetMapType),
                                               keyEquivalent: "")
                self.CubicMapMenu?.image = self.SmallIconImage("CubeIcon")
                self.CubicMapMenu?.target = self
                self.CubicMapMenu?.state = CurrentMap == .CubicWorld ? .on : .off
                self.MapTypeMenu?.submenu?.items.append(self.CubicMapMenu!)
            }
        }
        
        return MapTypeMenu!
    }
    
    @objc func Context_SetMapType(_ sender: Any)
    {
        if let MenuItem = sender as? NSMenuItem
        {
            switch MenuItem
            {
                case NCenter:
                    Settings.SetEnum(.FlatNorthCenter, EnumType: ViewTypes.self, ForKey: .ViewType)
                    let ActualMap = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
                    Settings.SetEnum(ActualMap, EnumType: MapTypes.self, ForKey: .MapType)
                    
                case SCenter:
                    Settings.SetEnum(.FlatSouthCenter, EnumType: ViewTypes.self, ForKey: .ViewType)
                    let ActualMap = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
                    Settings.SetEnum(ActualMap, EnumType: MapTypes.self, ForKey: .MapType)
                    
                case RectMap:
                    Settings.SetEnum(.Rectangular, EnumType: ViewTypes.self, ForKey: .ViewType)
                    let ActualMap = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
                    Settings.SetEnum(ActualMap, EnumType: MapTypes.self, ForKey: .MapType)
                    
                case CubicMapMenu:
                    Settings.SetEnum(.CubicWorld, EnumType: ViewTypes.self, ForKey: .ViewType)
                    
                case GlobeMapMenu:
                    Settings.SetEnum(.Globe3D, EnumType: ViewTypes.self, ForKey: .ViewType)
                    
                default:
                    return
            }
        }
    }
    
    func MakeTimeMenu() -> NSMenuItem
    {
        TimeMenu = NSMenuItem()
        TimeMenu?.title = "Hours"
        TimeMenu?.submenu = NSMenu(title: "Hours")
        
        let HourType = Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self, Default: HourValueTypes.Solar)
        
        NoTimeMenu = NSMenuItem(title: "No Hours Shown", action: #selector(Context_SetHourType), keyEquivalent: "")
        NoTimeMenu?.image = SmallIconImage("CircleIcon")
        NoTimeMenu?.target = self
        NoTimeMenu?.state = HourType == .None ? .on : .off
        SolarTimeMenu = NSMenuItem(title: "Solar Hours", action: #selector(Context_SetHourType), keyEquivalent: "")
        SolarTimeMenu?.image = SmallIconImage("ClockIcon")
        SolarTimeMenu?.target = self
        SolarTimeMenu?.state = HourType == .Solar ? .on : .off
        DeltaTimeMenu = NSMenuItem(title: "Relative to Noon", action: #selector(Context_SetHourType), keyEquivalent: "")
        DeltaTimeMenu?.image = SmallIconImage("DeltaIcon")
        DeltaTimeMenu?.target = self
        DeltaTimeMenu?.state = HourType == .RelativeToNoon ? .on : .off
        PinnedTimeMenu = NSMenuItem(title: "Relative to Location", action: #selector(Context_SetHourType), keyEquivalent: "")
        PinnedTimeMenu?.image = SmallIconImage("PinIcon")
        PinnedTimeMenu?.target = self
        PinnedTimeMenu?.state = HourType == .RelativeToLocation ? .on : .off
        WallClockTimeMenu = NSMenuItem(title: "Wall Clock", action: #selector(Context_SetHourType), keyEquivalent: "")
        WallClockTimeMenu?.image = SmallIconImage("WallClockIcon")
        WallClockTimeMenu?.target = self
        WallClockTimeMenu?.state = HourType == .WallClock ? .on : .off
        
        TimeMenu?.submenu?.items.append(NoTimeMenu!)
        TimeMenu?.submenu?.items.append(SolarTimeMenu!)
        TimeMenu?.submenu?.items.append(DeltaTimeMenu!)
        TimeMenu?.submenu?.items.append(PinnedTimeMenu!)
        TimeMenu?.submenu?.items.append(WallClockTimeMenu!)
        return TimeMenu!
    }
    
    @objc func Context_SetHourType(_ sender: Any)
    {
        if let MenuItem = sender as? NSMenuItem
        {
            switch MenuItem
            {
                case NoTimeMenu:
                    Settings.SetEnum(.None, EnumType: HourValueTypes.self, ForKey: .HourType)
                    
                case SolarTimeMenu:
                    Settings.SetEnum(.Solar, EnumType: HourValueTypes.self, ForKey: .HourType)
                    
                case DeltaTimeMenu:
                    Settings.SetEnum(.RelativeToNoon, EnumType: HourValueTypes.self, ForKey: .HourType)
                    
                case PinnedTimeMenu:
                    Settings.SetEnum(.RelativeToLocation, EnumType: HourValueTypes.self, ForKey: .HourType)
                    
                case WallClockTimeMenu:
                    Settings.SetEnum(.WallClock, EnumType: HourValueTypes.self, ForKey: .HourType)
                    
                default:
                    return
            }
        }
    }
    
    @objc func Context_AddPOI(_ sender: Any)
    {
        print("Add POI here!")
    }
    
    @objc func Context_EditPOI(_ sender: Any)
    {
        print("Edit POI here!")
    }
    
    @objc func Context_AddQuakeRegion(_ sender: Any)
    {
        #if false
        let Storyboard = NSStoryboard(name: "SubPanels", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "EarthquakeRegionWindow2") as? EarthquakeRegionWindow2
        {
            let Window = WindowController.window
            if let Controller = Window?.contentViewController as? EarthquakeRegionController2
            {
                Controller.IsModal(false)
                WindowController.showWindow(nil)
            }
        }
        #endif
    }
    
    @objc func Context_AddPolarQuakeRegion(_ sender: Any)
    {
        #if false
        let Storyboard = NSStoryboard(name: "SubPanels", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "EarthquakeRegionWindow2") as? EarthquakeRegionWindow2
        {
            let Window = WindowController.window
            if let Controller = Window?.contentViewController as? EarthquakeRegionController2
            {
                Controller.IsModal(false)
                WindowController.showWindow(nil)
            }
        }
        #endif
    }
    
    @objc func HandleLockMenu(_ sender: Any)
    {
        Settings.InvertBool(.WorldIsLocked)
    }
    
    func MakeLockMenu() -> NSMenuItem
    {
        LockMenu = NSMenuItem(title: "Lock Camera", action: #selector(HandleLockMenu), keyEquivalent: "")
        LockMenu?.target = self
        let IsLocked = Settings.GetBool(.WorldIsLocked)
        LockMenu?.state = IsLocked ? .on : .off
        return LockMenu!
    }
    
    func MakeResetMenu() -> NSMenuItem
    {
        ResetMenu = NSMenuItem(title: "Reset View", action: #selector(HandleResetViewMenu), keyEquivalent: "")
        ResetMenu?.target = self
        return ResetMenu!
    }
    
    func MakeSunMenu() -> NSMenuItem
    {
        SunMenu = NSMenuItem(title: "Move Sun to Other Pole", action: #selector(SwapSunLocation), keyEquivalent: "")
        return SunMenu!
    }
    
    @objc func SwapSunLocation(_ sender: Any)
    {
        let MapCenter = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter)
        switch MapCenter
        {
            case .FlatSouthCenter:
                Settings.SetEnum(.FlatNorthCenter, EnumType: ViewTypes.self, ForKey: .ViewType)
                
            case .FlatNorthCenter:
                Settings.SetEnum(.FlatSouthCenter, EnumType: ViewTypes.self, ForKey: .ViewType)
                
            default:
                return
        }
    }
    
    @objc func HandleResetViewMenu(_ sender: Any)
    {
        ResetCamera()
    }
    
    func MakeFollowMenu() -> NSMenuItem
    {
        FollowMenu = NSMenuItem()
        FollowMenu?.title = "Follow Mode"
        FollowMenu?.submenu = NSMenu(title: "Follow")
        let FollowMouse = NSMenuItem(title: "Follow Mouse", action: #selector(ContextToggleFollowMouse), keyEquivalent: "")
        FollowMouse.target = self
        FollowMouse.state = Settings.GetBool(.FollowMouse) ? .on : .off
        FollowMenu?.submenu?.items.append(FollowMouse)
        return FollowMenu!
    }
    
    @objc func ContextToggleFollowMouse(_ sender: Any)
    {
        Settings.ToggleBool(.FollowMouse)
        if !Settings.GetBool(.FollowMouse)
        {
            MouseIndicator?.removeAllActions()
            MouseIndicator?.removeAllAnimations()
            MouseIndicator?.removeFromParentNode()
            MouseIndicator = nil
        }
    }
    
    func MakePOIMenu() -> NSMenuItem
    {
        POIMenu = NSMenuItem()
        POIMenu?.title = "Points of Interest"
        POIMenu?.submenu = NSMenu(title: "Points of Interest")
        let AddPOI = NSMenuItem(title: "Add POI", action: #selector(Context_AddPOI), keyEquivalent: "")
        AddPOI.target = self
        let EditPOI = NSMenuItem(title: "Edit POI", action: #selector(Context_EditPOI), keyEquivalent: "")
        EditPOI.target = self
        POIMenu?.submenu?.items.append(AddPOI)
        POIMenu?.submenu?.items.append(EditPOI)
        return POIMenu!
    }
    
    func MakeEarthquakeMenu() -> NSMenuItem
    {
        QuakeMenu = NSMenuItem()
        QuakeMenu?.title = "Earthquakes"
        QuakeMenu?.submenu = NSMenu(title: "Earthquakes")
        let AddRegion = NSMenuItem(title: "Add Earthquake Region", action: #selector(Context_AddQuakeRegion), keyEquivalent: "")
        AddRegion.target = self
        let AddPolarRegion = NSMenuItem(title: "Add Polar Earthquake Region", action: #selector(Context_AddPolarQuakeRegion), keyEquivalent: "")
        AddPolarRegion.target = self
        QuakeMenu?.submenu?.items.append(AddRegion)
        QuakeMenu?.submenu?.items.append(AddPolarRegion)
        return QuakeMenu!
    }
}
