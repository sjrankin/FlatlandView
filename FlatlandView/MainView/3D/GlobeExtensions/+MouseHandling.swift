//
//  +MouseHandling.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension GlobeView
{
    // MARK: - Mouse and menu handling
    
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
    
    @objc func HandleWhatsHereMenu(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "Popovers", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "WhatsHereWindow") as? WhatsHereWindow
        {
            let Window = WindowController.window
            let Controller = Window?.contentViewController as? WhatsHereViewer
            WindowController.showWindow(nil)
            let (Latitude, Longitude) = MakeWhereFromTexture(CurrentMouseLocation)
            Controller?.SetLocation(Latitude, Longitude, Main: MainDelegate)
            ShowSearchForLocation(Latitude, Longitude)
        }
    }
    
    func ShowSearchForLocation(_ Latitude: Double, _ Longitude: Double)
    {
        let (X, Y, Z) = Geometry.ToECEF(Latitude, Longitude, Radius: Double(GlobeRadius.Primary.rawValue + 0.2))
        let QM = SCNExtrudedLetter(Letter: "?", Font: NSFont.boldSystemFont(ofSize: 20.0), Depth: 4.0, Scale: 0.05)
        QM.geometry?.firstMaterial?.emission.contents = NSColor.systemYellow
        QM.geometry?.firstMaterial?.specular.contents = NSColor.black
        QM.position = SCNVector3(X, Y, Z)
        QM.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        let Rotation = 90 - Latitude
        let Rotation2 = 180.0 - Longitude
        //QM.eulerAngles = SCNVector3(Rotation.Radians, Rotation2.Radians, 0.0)
        let ex = 90.0 - (90.0 - Latitude)
        print("Latitude=\(Latitude.RoundedTo(3)), ex=\(ex.RoundedTo(3))")
        QM.eulerAngles = SCNVector3(ex.Radians, 0.0, 0.0)
        EarthNode?.addChildNode(QM)
        let RotateQM = SCNAction.rotateBy(x: 0.0, y: -1.0, z: 0.0, duration: 1.0)
        let RotateForever = SCNAction.repeatForever(RotateQM)
        //QM.runAction(RotateForever)
    }
    
    /// Return a menu to display provided the passed event is a right mouse down event.
    /// - Parameter for: The event that determines if a menu is returned.
    /// - Returns: An `NSMenu` if `event` is `.rightMouseDown`, nil if not.
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
                    NSMenuItem.separator(),
                    MakePOIMenu(),
                    MakeEarthquakeMenu(),
                    NSMenuItem.separator(),
                    MakeFollowMenu()
                ]
            #if DEBUG
            Menu.items.append(NSMenuItem.separator())
            Menu.items.append(MakeDebugMenu())
            #endif
            return Menu
        }
        return nil
    }
    
    func SmallIconImage(_ Name: String) -> NSImage
    {
        var IconImage = NSImage(named: Name)
        IconImage = Utility.ResizeImage(Image: IconImage!, Longest: 24.0)
        return IconImage!
    }
    
    func MakeDebugMenu() -> NSMenuItem
    {
        #if DEBUG
        DebugMenu = NSMenuItem()
        DebugMenu?.title = "Debug"
        DebugMenu?.submenu = NSMenu(title: "Debug")
        RotateTo0Menu = NSMenuItem(title: "Rotate to 0°", action: #selector(TestRotation), keyEquivalent: "")
        RotateTo0Menu?.target = self
        RotateTo90Menu = NSMenuItem(title: "Rotate to 90°", action: #selector(TestRotation), keyEquivalent: "")
        RotateTo90Menu?.target = self
        RotateTo180Menu = NSMenuItem(title: "Rotate to 180°", action: #selector(TestRotation), keyEquivalent: "")
        RotateTo180Menu?.target = self
        RotateTo270Menu = NSMenuItem(title: "Rotate to 270°", action: #selector(TestRotation), keyEquivalent: "")
        RotateTo270Menu?.target = self
        CoupleTimerMenu = NSMenuItem(title: "Couple Earth to Timer", action: #selector(TestRotation), keyEquivalent: "")
        CoupleTimerMenu?.target = self
        DebugMenu?.submenu?.items.append(RotateTo0Menu!)
        DebugMenu?.submenu?.items.append(RotateTo90Menu!)
        DebugMenu?.submenu?.items.append(RotateTo180Menu!)
        DebugMenu?.submenu?.items.append(RotateTo270Menu!)
        DebugMenu?.submenu?.items.append(CoupleTimerMenu!)
        return DebugMenu!
        #else
        return NSMenuItem()
        #endif
    }
    
    @objc func TestRotation(_ sender: Any)
    {
        if let Menu = sender as? NSMenuItem
        {
            switch Menu
            {
                case RotateTo0Menu:
                    RotateEarthTo(Latitude: 0.0, Longitude: 0.0)
                    
                case RotateTo90Menu:
                    RotateEarthTo(Latitude: 0.0, Longitude: 90.0)
                    
                case RotateTo180Menu:
                    RotateEarthTo(Latitude: 0.0, Longitude: 180.0)
                    
                case RotateTo270Menu:
                    RotateEarthTo(Latitude: 0.0, Longitude: -90.0)
                    
                case CoupleTimerMenu:
                    ResetEarthRotation()
                    
                default:
                    return
            }
        }
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
    
    func MakeWhatsHereMenu() -> NSMenuItem
    {
        UnderMouseMenu = NSMenuItem(title: "What's Here?", action: #selector(HandleWhatsHereMenu), keyEquivalent: "")
        return UnderMouseMenu!
    }
    
    func MakeResetMenu() -> NSMenuItem
    {
        ResetMenu = NSMenuItem(title: "Reset View", action: #selector(HandleResetViewMenu), keyEquivalent: "")
        return ResetMenu!
    }
    
    /// Reset the camera.
    /// - Parameter sender: Not used.
    @objc func HandleResetViewMenu(_ sender: Any)
    {
        ResetCamera()
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
    
    func MakeLockMenu() -> NSMenuItem
    {
        LockMenu = NSMenuItem(title: "Lock Camera", action: #selector(HandleLockMenu), keyEquivalent: "")
        LockMenu?.target = self
        let IsLocked = Settings.GetBool(.WorldIsLocked)
        LockMenu?.state = IsLocked ? .on : .off
        return LockMenu!
    }
    
    /// Toggle the world locked flag. Settings changed handlers will detect the change and act accordingly.
    /// - Parameter sender: Not used.
    @objc func HandleLockMenu(_ sender: Any)
    {
        Settings.InvertBool(.WorldIsLocked)
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
    
    /// Toggle the mouse follow mode. If disabling, the mouse indicator is removed from the scene.
    /// - Parameter sender: Not used.
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
    
    /// Handle mouse motion reported by the main view controller.
    /// - Note: Depending on various parameters, the mouse's location is translated to scene coordinates and
    ///         the node under the mouse is queried and its associated data may be displayed.
    /// - Note: The implementation for mouse over node is slightly different between the 2D and 3D displays...
    /// - Parameter Point: The point in the view reported by the main controller.
    func MouseMovedTo(Point: CGPoint)
    {
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: ViewTypes.Globe3D) != .Globe3D
        {
            return
        }
        if Settings.GetBool(.FollowMouse)
        {
            let SearchOptions: [SCNHitTestOption: Any] =
                [
                    .searchMode: SCNHitTestSearchMode.closest.rawValue,
                    .ignoreHiddenNodes: true,
                    .ignoreChildNodes: true,
                    .rootNode: self.EarthNode as Any
                ]
            let HitObject = self.hitTest(Point, options: SearchOptions)
            if HitObject.count > 0
            {
                if HitObject[0].node.self is SCNNode2
                {
                    let TxWhere = HitObject[0].textureCoordinates(withMappingChannel: 0)
                    CurrentMouseLocation = TxWhere
                    let (Latitude, Longitude) = MakeWhereFromTexture(TxWhere)
                    //print("Location=\(Latitude.RoundedTo(3)),\(Longitude.RoundedTo(3))")
                    MainDelegate?.MouseAtLocation(Latitude: Latitude, Longitude: Longitude, Caller: "Globe")
                    PlotMouseIndicator(Latitude: Latitude, Longitude: Longitude)
                }
            }
        }
    }
    
    /// Create the latitude and longitude from the passed texture location. The texture location is the location
    /// of the mouse on the globe's texture where the top is at Y == 0.0, the bototm at Y == 1.0, left is X == 0.0
    /// and right is X == 1.0.
    /// - Parameter TextureLocation: The location of the mouse on the texture of the globe. See summary for
    ///                              description.
    /// - Returns: Tuple of the latitude and longitude.
    func MakeWhereFromTexture(_ TextureLocation: CGPoint) -> (Latitude: Double, Longitude: Double)
    {
        if TextureLocation == CGPoint.zero
        {
            return (0.0, 0.0)
        }
        var Latitude: Double = 0.0
        var Longitude: Double = 0.0
        if TextureLocation.x < 0.5
        {
            //Western hemisphere
            let AdjustedX = 0.5 - Double(TextureLocation.x)
            Longitude = (AdjustedX * 2.0) * 180.0 * -1.0
            if TextureLocation.y <= 0.5
            {
                //Northern hemisphere
                let AdjustedY = 0.5 - Double(TextureLocation.y)
                Latitude = (AdjustedY * 2.0) * 90.0
            }
            else
            {
                //Southern hemisphere
                let AdjustedY = Double(TextureLocation.y) - 0.5
                Latitude = (AdjustedY * 2.0) * 90.0 * -1.0
            }
        }
        else
        {
            //Eastern hemisphere
            let AdjustedX = Double(TextureLocation.x) - 0.5
            Longitude = (AdjustedX * 2.0) * 180.0
            if TextureLocation.y <= 0.5
            {
                //Nothern hemisphere
                let AdjustedY = 0.5 - Double(TextureLocation.y)
                Latitude = (AdjustedY * 2.0) * 90.0
            }
            else
            {
                //Southern hemisphere
                let AdjustedY = Double(TextureLocation.y) - 0.5
                Latitude = (AdjustedY * 2.0) * 90.0 * -1.0
            }
        }
        return (Latitude, Longitude)
    }
    
    /// Draw the mouse indicator on the surface of the globe.
    /// - Parameter Latitude: The latitude of where to draw the indicator.
    /// - Parameter Longitude: The longitude of where to draw the indicator.
    func PlotMouseIndicator(Latitude: Double, Longitude: Double)
    {
        if MouseIndicator == nil
        {
            MouseIndicator = MakeMouseIndicator()
            EarthNode?.addChildNode(MouseIndicator!)
        }
        let (X, Y, Z) = ToECEF(Latitude, Longitude,
                               Radius: Double(GlobeRadius.Primary.rawValue) + Double(MouseShape.RadialOffset.rawValue))
        MainDelegate?.MouseAtLocation(Latitude: Latitude, Longitude: Longitude, Caller: "Globe")
        MouseIndicator?.position = SCNVector3(X, Y, Z)
        MouseIndicator?.eulerAngles = SCNVector3(CGFloat(Latitude + 90.0).Radians,
                                                 CGFloat(Longitude + 180.0).Radians,
                                                 0.0)
    }
    
    /// Handle mouse clicks reported by the main view controller.
    /// - Note: Depending on various parameters, the mouse's location is translated to scene coordinates and
    ///         the node under the mouse is queried and its associated data may be displayed.
    /// - Note: The implementation for mouse over node is slightly different between the 2D and 3D displays...
    /// - Parameter Point: The point in the view reported by the main controller.
    func MouseAt(Point: CGPoint)
    {
        let MapView = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter)
        if MapView == .Globe3D
        {
            let SearchOptions: [SCNHitTestOption: Any] =
                [
                    .searchMode: SCNHitTestSearchMode.closest.rawValue,
                    .ignoreHiddenNodes: true,
                    .ignoreChildNodes: false,
                    .rootNode: self.EarthNode as Any
                ]
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
                        
                        if let NodeData = NodeTables.GetItemData(For: NodeID)
                        {
                            if Settings.GetBool(.HighlightNodeUnderMouse)
                            {
                                Node.ShowBoundingShape(.Sphere,
                                                       LineColor: NSColor.red,
                                                       SegmentCount: 10)
                                if let PN = PreviousNode
                                {
                                    PN.HideBoundingShape()
                                }
                            }
                            PreviousNodeID = NodeID
                            PreviousNode = Node
                            MakePopOver(At: Point, For: NodeData)
                        }
                        else
                        {
                            Pop?.performClose(self)
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
    
    /// Create a pop-over view to display information.
    /// - Parameter At: Where to create the pop-over window.
    /// - Parameter For: Information to display.
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
    
    /// Make a mouse indicator for the globe.
    /// - Returns: A shape to use for the indicator.
    func MakeMouseIndicator() -> SCNNode2
    {
        let top = SCNCone(topRadius: CGFloat(MouseShape.PointRadius.rawValue),
                          bottomRadius: CGFloat(MouseShape.BottomRadius.rawValue),
                          height: CGFloat(MouseShape.Height.rawValue))
        let bottom = SCNCone(topRadius: CGFloat(MouseShape.BottomRadius.rawValue),
                             bottomRadius: CGFloat(MouseShape.PointRadius.rawValue),
                             height: CGFloat(MouseShape.Height.rawValue))
        let topnode = SCNNode2(geometry: top)
        let bottomnode = SCNNode2(geometry: bottom)
        topnode.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        bottomnode.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        topnode.position = SCNVector3(0.0, CGFloat(MouseShape.Height.rawValue), 0.0)
        topnode.geometry?.firstMaterial?.diffuse.contents = NSColor.black
        topnode.geometry?.firstMaterial?.emission.contents = NSColor.systemOrange
        bottomnode.geometry?.firstMaterial?.diffuse.contents = NSColor.black
        bottomnode.geometry?.firstMaterial?.emission.contents = NSColor.systemYellow
        let SwapDuration: Double = MouseShape.ColorSwapDuration.rawValue
        #if true
        let BottomGradient = MakeGradient(NSColor.yellow, NSColor.blue, 0.5)
        bottomnode.geometry?.firstMaterial?.emission.contents = BottomGradient
        let TopGradient = MakeGradient(NSColor.blue, NSColor.black, 0.0, 0.5)
        topnode.geometry?.firstMaterial?.emission.contents = TopGradient
        #else
        let TopColorSwap = SCNAction.customAction(duration: SwapDuration)
        {
            Node, Elapsed in
            if Double(Elapsed) >= SwapDuration
            {
                if let OldColor = Node.geometry?.firstMaterial?.emission.contents as? NSColor
                {
                    if OldColor == NSColor.systemYellow
                    {
                        Node.geometry?.firstMaterial?.emission.contents = NSColor.systemOrange
                    }
                    else
                    {
                        Node.geometry?.firstMaterial?.emission.contents = NSColor.systemYellow
                    }
                }
            }
        }
        let SwapTopForever = SCNAction.repeatForever(TopColorSwap)
        topnode.runAction(SwapTopForever)
        let BottomColorSwap = SCNAction.customAction(duration: SwapDuration)
        {
            Node, Elapsed in
            if Double(Elapsed) >= SwapDuration
            {
                if let OldColor = Node.geometry?.firstMaterial?.emission.contents as? NSColor
                {
                    if OldColor == NSColor.systemOrange
                    {
                        Node.geometry?.firstMaterial?.emission.contents = NSColor.systemYellow
                    }
                    else
                    {
                        Node.geometry?.firstMaterial?.emission.contents = NSColor.systemOrange
                    }
                }
            }
        }
        let Test = MakeGradient(NSColor.red, NSColor.TeaGreen)
        let SwapBottomForever = SCNAction.repeatForever(BottomColorSwap)
        bottomnode.runAction(SwapBottomForever)
        #endif
        let FinalIndicator = SCNNode2()
        FinalIndicator.addChildNode(topnode)
        FinalIndicator.addChildNode(bottomnode)
        var Angles = [Double]()
        var Previous = 0.0
        let GenericAngle = 360.0 * (1.0 / MouseShape.AngleCount.rawValue)
        for _ in 0 ..< Int(MouseShape.AngleCount.rawValue)
        {
            let NewAngle = Previous + GenericAngle
            Previous = NewAngle
            Angles.append(NewAngle)
        }
        for Angle in Angles
        {
            let Radius = MouseShape.BottomRadius.rawValue
            let Sphere = SCNSphere(radius: CGFloat(MouseShape.SuperfluousSphereRadius.rawValue))
            let SNode = SCNNode2(geometry: Sphere)
            SNode.geometry?.firstMaterial?.emission.contents = NSColor.cyan
            let X = Radius * cos(Angle.Radians)
            let Y = Radius * sin(Angle.Radians)
            SNode.position = SCNVector3(X, MouseShape.Height.rawValue / 2.0, Y)
            FinalIndicator.addChildNode(SNode)
            let RotateDuration = MouseShape.SuperfluousSphereRotationDuration.rawValue
            let RotateSphere = SCNAction.customAction(duration: RotateDuration)
            {
                Node, Elapsed in
                let NewAngle = Angle + 360.0 * (Double(Elapsed) / RotateDuration)
                let NewX = Radius * cos(NewAngle.Radians)
                let NewY = Radius * sin(NewAngle.Radians)
                Node.position = SCNVector3(NewX, MouseShape.Height.rawValue / 2.0, NewY)
            }
            let Forever = SCNAction.repeatForever(RotateSphere)
            SNode.runAction(Forever)
        }
        
        return FinalIndicator
    }
    
    func MakePinnedLocation(Start: Bool, Latitude: Double, Longitude: Double) -> SCNNode2
    {
        let KnobColor = Start ? NSColor.green : NSColor.red
        let Pin = SCNPin(KnobHeight: 2.0, KnobRadius: 1.0, PinHeight: 1.4, PinRadius: 0.15,
                         KnobColor: KnobColor, PinColor: NSColor.gray)
        Pin.scale = SCNVector3(0.15, 0.15, 0.15)
        Pin.LightMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        let (X, Y, Z) = ToECEF(Latitude, Longitude, Radius: Double(GlobeRadius.Primary.rawValue))
        Pin.position = SCNVector3(X, Y, Z)
        let YRotation = Latitude + 90.0
        let XRotation = Longitude + 180.0
        Pin.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, 0.0)
        EarthNode?.addChildNode(Pin)
        return Pin
    }
    
    /// Create a gradient layer with the passed colors.
    /// - Parameter Color1: Initial color.
    /// - Parameter Color2: Second color.
    /// - Parameter Pos1: Position of first color. Defaults to `0.0`.
    /// - Parameter Pos2: Position of second color. Defaults to `1.0`.
    /// - Returns: `CAGradientLayer` with the specified gradient.
    func MakeGradient(_ Color1: NSColor, _ Color2: NSColor, _ Pos1: Double = 0.0, _ Pos2: Double = 1.0) -> CAGradientLayer
    {
        let GLayer = CAGradientLayer()
        GLayer.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 100.0, height: 100.0))
        GLayer.colors = [Color1.cgColor as Any, Color2.cgColor as Any]
        GLayer.locations = [NSNumber(value: Pos1), NSNumber(value: Pos2)]
        return GLayer
    }
}
