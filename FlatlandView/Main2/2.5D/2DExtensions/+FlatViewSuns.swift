//
//  +FlatViewSuns.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/23/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension FlatView
{
    /// Add the sun node. The sun node uses its own ambient light so it won't cast shadows but more importantly
    /// as a code simplification technique to not have to worry about light changes.
    func AddSun()
    {
        Debug.Print("At AddSun: \(Debug.PrettyStackTrace(Debug.StackFrameContents(5)))")
        let MapCenter = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter)
        let SunLocationY = MapCenter == .FlatSouthCenter ? FlatConstants.NorthSunLocationY.rawValue : FlatConstants.SouthSunLocationY.rawValue
        let SunShape = SCNSphere(radius: CGFloat(FlatConstants.SunRadius.rawValue))
        SunShape.segmentCount = Int(FlatConstants.SunSegmentCount.rawValue)
        SunNode = SCNNode(geometry: SunShape)
        SunNode.castsShadow = false
        SunNode.geometry?.firstMaterial?.diffuse.contents = NSImage(named: "NASASolarSurface1")
        SunNode.geometry?.firstMaterial?.selfIllumination.contents = NSColor.yellow
        SunNode.categoryBitMask = LightMasks2D.AmbientSun.rawValue
        SunNode.eulerAngles = SCNVector3(90.0.Radians, 0.0, 0.0)
        SunNode.position = SCNVector3(0.0, SunLocationY, FlatConstants.PolarLightZTerminal.rawValue)
        self.scene?.rootNode.addChildNode(SunNode)
        
        let SunRotation = SCNAction.rotateBy(x: 0.0, y: 0.0, z: CGFloat(360.0.Radians), duration: 20.0)
        let RotateForever = SCNAction.repeatForever(SunRotation)
        SunNode.runAction(RotateForever)
    }
    
    /// Move the sun.
    /// - Parameter ToNorth: If true, the sun will be moved to the "north" (upper) part of the view. Otherwise,
    ///                      it will be moved to the "south" (lower) part of the view.
    func MoveSun(ToNorth: Bool)
    {
        let SunLocationY = ToNorth ? FlatConstants.NorthSunLocationY.rawValue : FlatConstants.SouthSunLocationY.rawValue
        SunNode.position = SCNVector3(0.0, SunLocationY, FlatConstants.PolarLightZTerminal.rawValue)
    }
    
    /// Hide or show the sun node.
    func SunVisibility(IsShowing: Bool)
    {
        SunNode.isHidden = !IsShowing
    }
}
