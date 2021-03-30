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
    
    /// Make a pop-over window at the specified location for the specified item.
    /// - Parameter At: The location where to display the pop-over window.
    /// - Parameter For: The item for which information will be displayed.
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
        if !Settings.GetBool(.FollowMouse)
        {
            return
        }
        let Mode = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: ViewTypes.Rectangular)
        if Mode == .FlatNorthCenter || Mode == .FlatSouthCenter
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
                    if MouseIndicator == nil
                    {
                        MouseIndicator = MakeMouseIndicator()
                        FollowPlane?.addChildNode(MouseIndicator!)
                    }
                    
                    let CurrentAngle = PrettyPercent * 360.0
                    let MousePoint = SCNVector3(-Where.x, -0.75, -Where.y)
                    MouseIndicator?.position = MousePoint
                    var Theta: Double = 0.0
                    let InitialAngle = Mode == .FlatNorthCenter ? 90.0 : 0.0
                    let (Lat, Lon) = Geometry.ConvertCircleToGeo(Point: MousePoint,
                                                                Radius: FlatConstants.FlatRadius.rawValue,
                                                                Angle: InitialAngle,
                                                                NorthCenter: Mode == .FlatNorthCenter,
                                                                ThetaValue: &Theta)
                    let FinalLat = Lat
                    var FinalLon = Lon
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
                    let AngleAdjustment = Mode == .FlatNorthCenter ? -1.0 : 1.0
                    FinalLon = FinalLon + (CurrentAngle * AngleAdjustment)
                    if Mode == .FlatSouthCenter
                    {
                        FinalLon = FinalLon - 90.0
                        FinalLon = FinalLon * -1.0
                        if FinalLon > 180.0
                        {
                            let Delta = FinalLon - 180.0
                            FinalLon = -(180.0 - Delta)
                        }
                    }
                    else
                    {
                        if FinalLon < -180.0
                        {
                            FinalLon = fmod(FinalLon, 360.0)
                            if (-360.0 ... -180.0).contains(FinalLon)
                            {
                                FinalLon = 360.0 + FinalLon
                            }
                        }
                    }
                    MouseIndicator?.Latitude = FinalLat
                    MouseIndicator?.Longitude = FinalLon
                    //MainDelegate?.MouseAtLocation(Latitude: Lat, Longitude: FinalLon, Caller: "Round")
                }
            }
        }
    }
    
    /// Make a mouse indicator to show the user where the mouse is over the Earth.
    /// - Returns: A shape to be used as a mouse indicator.
    func MakeMouseIndicator() -> SCNNode2
    {
        let Top = SCNCone(topRadius: 0.0, bottomRadius: 0.25, height: 0.5)
        let Bottom = SCNCone(topRadius: 0.25, bottomRadius: 0.0, height: 0.5)
        let TopNode = SCNNode2(geometry: Top)
        let BottomNode = SCNNode2(geometry: Bottom)
        TopNode.categoryBitMask = LightMasks2D.Polar.rawValue
        BottomNode.categoryBitMask = LightMasks2D.Polar.rawValue
        TopNode.position = SCNVector3(0.0, 0.5, 0.0)
        TopNode.geometry?.firstMaterial?.diffuse.contents = NSColor.systemOrange
        BottomNode.geometry?.firstMaterial?.diffuse.contents = NSColor.yellow
        
        TopNode.SetState(ForDay: true, Color: NSColor.orange, Emission: nil, CastsShadow: true)
        TopNode.SetState(ForDay: false, Color: NSColor.orange, Emission: NSColor.orange, CastsShadow: false)
        TopNode.IsInDaylight = true
        BottomNode.SetState(ForDay: true, Color: NSColor.yellow, Emission: nil, CastsShadow: true)
        BottomNode.SetState(ForDay: false, Color: NSColor.yellow, Emission: NSColor.yellow, CastsShadow: false)
        BottomNode.IsInDaylight = true
        
        let Final = SCNNode2()
        Final.addChildNode(TopNode)
        Final.addChildNode(BottomNode)
        return Final
    }
}
