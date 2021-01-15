//
//  +RectangleMouseHandling.swift
//  Flatland
//
//  Created by Stuart Rankin on 12/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension RectangleView
{
    // MARK: - Menum handling.
    
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
        GlobeMapMenu?.state = CurrentMap == .Globe3D ? .on : .off
        CubicMapMenu = NSMenuItem(title: "Cubic", action: #selector(Context_SetMapType), keyEquivalent: "")
        CubicMapMenu?.image = SmallIconImage("CubeIcon")
        CubicMapMenu?.target = self
        CubicMapMenu?.state = CurrentMap == .CubicWorld ? .on : .off
        
        MapTypeMenu?.submenu?.items.append(NCenter!)
        MapTypeMenu?.submenu?.items.append(SCenter!)
        MapTypeMenu?.submenu?.items.append(RectMap!)
        MapTypeMenu?.submenu?.items.append(GlobeMapMenu!)
        MapTypeMenu?.submenu?.items.append(CubicMapMenu!)
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
        
        TimeMenu?.submenu?.items.append(NoTimeMenu!)
        TimeMenu?.submenu?.items.append(SolarTimeMenu!)
        TimeMenu?.submenu?.items.append(DeltaTimeMenu!)
        TimeMenu?.submenu?.items.append(PinnedTimeMenu!)
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
        print("Add earthquake region")
    }
    
    @objc func Context_EditQuakeRegion(_ sender: Any)
    {
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
    }
    
    @objc func Context_MakeCircularRegion(_ sender: Any)
    {
        
    }
    
    @objc func Context_MakeRectangularRegion(_ sender: Any)
    {
        
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
        let EditRegion = NSMenuItem(title: "Edit Earthquake Region", action: #selector(Context_EditQuakeRegion), keyEquivalent: "")
        EditRegion.target = self
        QuakeMenu?.submenu?.items.append(AddRegion)
        QuakeMenu?.submenu?.items.append(EditRegion)
        QuakeMenu?.submenu?.items.append(NSMenuItem.separator())
        let CircleRegion = NSMenuItem(title: "Create Circular Region", action: #selector(Context_MakeCircularRegion), keyEquivalent: "")
        CircleRegion.target = self
        let RectRegion = NSMenuItem(title: "Create Rectangular Region", action: #selector(Context_MakeRectangularRegion), keyEquivalent: "")
        RectRegion.target = self
        QuakeMenu?.submenu?.items.append(CircleRegion)
        QuakeMenu?.submenu?.items.append(RectRegion)
        return QuakeMenu!
    }
    
    // MARK: Mouse handling.
    
    /// Handle mouse clicks reported by the main view controller.
    /// - Note:
    ///    - Depending on various parameters, the mouse's location is translated to scene coordinates and
    ///         the node under the mouse is queried and its associated data may be displayed.
    ///    - In order to work, the options for the hit test must be `.boundingBoxOnly: true`.
    /// - Parameter Point: The point in the view reported by the main controller.
    func MouseClickedAt(Point: CGPoint)
    {
        let MapCenter = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter)
        if MapCenter == .FlatSouthCenter || MapCenter == .FlatNorthCenter
        {
            let SearchOptions: [SCNHitTestOption: Any] = [.boundingBoxOnly: true]
            let HitObject = self.hitTest(Point, options: SearchOptions)
            if HitObject.count > 0
            {
                if let Node = HitObject[0].node as? SCNNode2
                {
                    if let NodeID = Node.NodeID
                    {
                        if PreviousNodeID != nil
                        {
                            if PreviousNodeID! == NodeID
                            {
                                return
                            }
                        }
                        PreviousNodeID = NodeID
                        if PreviousNode != nil
                        {
                            if Settings.GetBool(.HighlightNodeUnderMouse)
                            {
                                PreviousNode?.HideBoundingShape()
                            }
                        }
                        if let NodeData = NodeTables.GetItemData(For: NodeID)
                        {
                            if Settings.GetBool(.HighlightNodeUnderMouse)
                            {
                                Node.ShowBoundingShape(.Sphere,
                                                       LineColor: NSColor.red,
                                                       SegmentCount: 10)
                            }
                            PreviousNode = Node
                            MakePopOver(At: Point, For: NodeData)
                        }
                    }
                }
                else
                {
                    Pop?.performClose(self)
                }
            }
        }
    }
    
    func MakePopOver(At: CGPoint, For: DisplayItem)
    {
        if let PopController = NSStoryboard(name: "Popovers", bundle: nil).instantiateController(withIdentifier: "POIPopover") as? POIPopover
        {
            Pop = NSPopover()
            Pop?.contentSize = NSSize(width: 376, height: 159)
            Pop?.behavior = .semitransient
            Pop?.animates = true
            Pop?.contentViewController = PopController
            Pop?.show(relativeTo: NSRect(x: At.x, y: At.y, width: 10.0, height: 10.0), of: self, preferredEdge: .minX)
            PopController.DisplayItem(For)
            PopController.SetSelf(Pop!)
        }
    }
    
    /// Handle mouse motion reported by the main view controller.
    /// - Note: Depending on various parameters, the mouse's location is translated to scene coordinates and
    ///         the node under the mouse is queried and its associated data may be displayed. If mouse follow
    ///         mode is not on, control returns immediately.
    /// - Parameter Point: The point in the view reported by the main controller.
    func MouseMovedTo(Point: CGPoint)
    {
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: ViewTypes.Globe3D) != .Rectangular
        {
            return
        }
        if !Settings.GetBool(.FollowMouse)
        {
            return
        }
        
        if InFollowMode
        {
            let SearchOptions: [SCNHitTestOption: Any] =
                [
                    .searchMode: SCNHitTestSearchMode.closest.rawValue,
                    .ignoreHiddenNodes: true,
                    .ignoreChildNodes: true,
                    .rootNode: self.FlatEarthNode as Any
                ]
            let HitObject = self.hitTest(Point, options: SearchOptions)
            if HitObject.count > 0
            {
                if HitObject[0].node.self is SCNNode2
                {
                    let Where = HitObject[0].worldCoordinates
                    if test == nil
                    {
                        test = MakeMousePointer()
                        FlatEarthNode.addChildNode(test!)
                    }
                    let RawPosition = SCNVector3(-Where.x,
                                                 -0.75,
                                                 -Where.y)
                    let (Lat, Lon) = Geometry.ConvertRectangleToGeo(Point: RawPosition, Width: RectMode.MapWidth.rawValue,
                                                                    Height: RectMode.MapHeight.rawValue)
                    test?.position = RawPosition
                    MainDelegate?.MouseAtLocation(Latitude: Lat, Longitude: Lon, Caller: "Rectangle")
                }
            }
        }
    }
    
    func MakeMouseIndicator() -> SCNNode2
    {
        let top = SCNCone(topRadius: 0.0, bottomRadius: 0.25, height: 0.5)
        let bottom = SCNCone(topRadius: 0.25, bottomRadius: 0.0, height: 0.5)
        let topnode = SCNNode2(geometry: top)
        let bottomnode = SCNNode2(geometry: bottom)
        topnode.categoryBitMask = LightMasks2D.Polar.rawValue
        bottomnode.categoryBitMask = LightMasks2D.Polar.rawValue
        topnode.position = SCNVector3(0.0, 0.5, 0.0)
        topnode.geometry?.firstMaterial?.diffuse.contents = NSColor.systemOrange
        bottomnode.geometry?.firstMaterial?.diffuse.contents = NSColor.yellow
        let final = SCNNode2()
        final.addChildNode(topnode)
        final.addChildNode(bottomnode)
        return final
    }
}
