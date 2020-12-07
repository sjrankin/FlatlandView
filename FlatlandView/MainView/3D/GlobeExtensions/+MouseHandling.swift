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
                    MakeResetMenu(),
                    MakeLockMenu(),
                    NSMenuItem.separator(),
                    MakePOIMenu(),
                    MakeEarthquakeMenu(),
                    NSMenuItem.separator(),
                    MakeFollowMenu()
                ]
            return Menu
        }
        return nil
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
                    let (Latitude, Longitude) = MakeWhereFromTexture(TxWhere)
                    MainDelegate?.MouseAtLocation(Latitude: Latitude, Longitude: Longitude)
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
        MainDelegate?.MouseAtLocation(Latitude: Latitude, Longitude: Longitude)
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
        
        return FinalIndicator
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
