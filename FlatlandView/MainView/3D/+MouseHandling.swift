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
    
    override func menu(for event: NSEvent) -> NSMenu?
    {
        if event.type == .rightMouseDown
        {
            let Menu = NSMenu(title: "Actions")
            Menu.items =
                [
                    MakeResetMenu(),
                    NSMenuItem.separator(),
                    MakePOIMenu(),
                    MakeEarthquakeMenu()
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
    
    func MouseMovedTo(Point: CGPoint)
    {
        if Settings.GetBool(.FollowMouse)
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
                    //do something only if Node is the globe
                }
            }
        }
    }
    
    /// Handle mouse motion reported by the main view controller.
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
    
}
