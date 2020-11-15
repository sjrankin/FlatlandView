//
//  +FlatViewMouseHandling.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension FlatView
{
    // MARK: - Menum handling.
    
    override func menu(for event: NSEvent) -> NSMenu?
    {
        if event.type == .rightMouseDown
        {
            let Menu = NSMenu(title: "Actions")
            Menu.items =
            [
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
            test?.removeAllActions()
            test?.removeAllAnimations()
            test?.removeFromParentNode()
            test = nil
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
    
    /// Handle mouse motion reported by the main view controller.
    /// - Note: Depending on various parameters, the mouse's location is translated to scene coordinates and
    ///         the node under the mouse is queried and its associated data may be displayed.
    /// - Parameter Point: The point in the view reported by the main controller.
    func MouseAt(Point: CGPoint)
    {
        let MapCenter = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter)
        if MapCenter == .FlatSouthCenter || MapCenter == .FlatNorthCenter
        {
//            let HitObject = self.hitTest(Point, options: [.boundingBoxOnly: true])
            let SearchOptions: [SCNHitTestOption: Any] =
                [
                    .searchMode: SCNHitTestSearchMode.closest.rawValue,
                    .ignoreHiddenNodes: true,
                    .ignoreChildNodes: false,
                    .rootNode: self.FlatEarthNode as Any
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
    
    func MouseMovedTo(Point: CGPoint)
    {
        let Mode = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: ViewTypes.Rectangular)
        if Mode == .FlatNorthCenter || Mode == .FlatSouthCenter
        {
            if Settings.GetBool(.FollowMouse)
            {
                let SearchOptions: [SCNHitTestOption: Any] =
                    [
                        .searchMode: SCNHitTestSearchMode.closest.rawValue,
                        .ignoreHiddenNodes: true,
                        .ignoreChildNodes: true,
                        .rootNode: FollowPlane! as Any
                    ]
                let HitObject = self.hitTest(Point, options: SearchOptions)
                if HitObject.count > 0
                {
                    if HitObject[0].node.self is SCNNode2
                    {
                        let Where = HitObject[0].worldCoordinates
                        if test == nil
                        {
                            test = maketestnode()
                            FollowPlane?.addChildNode(test!)
                        }
                        
                        let CurrentAngle = PrettyPercent * 360.0
                        let MousePoint = SCNVector3(-Where.x, -0.75, -Where.y)
                        test?.position = MousePoint
                        var Theta: Double = 0.0
                        let (Lat, Lon) = Utility.ConvertCircleToGeo(Point: MousePoint,
                                                                    Radius: FlatConstants.FlatRadius.rawValue,
                                                                    Angle: 90.0,
                                                                    NorthCenter: Mode == .FlatNorthCenter,
                                                                    ThetaValue: &Theta)
                        var FinalLon = Lon
                        if Mode == .FlatSouthCenter
                        {
                            FinalLon = fmod(FinalLon, 360.0) - 180.0
                            if (-270.0 ... -180.0).contains(FinalLon)
                            {
                                let Delta = 180.0 + FinalLon
                                FinalLon = 180.0 - abs(Delta)
                            }
                            FinalLon = FinalLon * -1.0
                            FinalLon = FinalLon - CurrentAngle
                            print("FinalLon=\(FinalLon)")
                            if FinalLon > 180.0
                            {
                                FinalLon = fmod(FinalLon, 180.0)
                                print(" Adjusted=\(FinalLon)")
                            }
                        }
                        else
                        {
                            if FinalLon > 180.0
                            {
                                let Delta = FinalLon - 180.0
                                FinalLon = 180.0 - Delta
                                FinalLon = FinalLon * -1.0
                            }
                            if FinalLon < -180.0
                            {
                                let Delta = 180.0 + FinalLon
                                FinalLon = 180.0 - abs(Delta)
                                FinalLon = FinalLon * -1.0
                            }
                            FinalLon = FinalLon - CurrentAngle
                            print("FinalLon=\(FinalLon)")
                            if FinalLon < -180.0
                            {
                                FinalLon = fmod(FinalLon, 360.0)
                                if (-360.0 ... -180.0).contains(FinalLon)
                                {
                                    FinalLon = 360.0 + FinalLon
                                }
                                print(" Adjusted=\(FinalLon)")
                            }
                        }
                        
                        MainDelegate?.MouseAtLocation(Latitude: Lat, Longitude: FinalLon)
                    }
                }
            }
        }
    }
    
    func maketestnode() -> SCNNode2
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
