//
//  +CubicEarth.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension GlobeView
{
    /// Draws a cubical Earth for no other reason than being silly.
    func ShowCubicEarth()
    {
        EarthNode?.removeAllActions()
        EarthNode?.removeFromParentNode()
        SeaNode?.removeAllActions()
        SeaNode?.removeFromParentNode()
        LineNode?.removeAllActions()
        LineNode?.removeFromParentNode()
        SystemNode?.removeAllActions()
        SystemNode?.removeFromParentNode()
        HourNode?.removeAllActions()
        HourNode?.removeFromParentNode()
        
        let EarthCube = SCNBox(width: 10.0, height: 10.0, length: 10.0, chamferRadius: 0.5)
        EarthNode = SCNNode(geometry: EarthCube)
        EarthNode?.categoryBitMask = LightMasks.Sun.rawValue | LightMasks.Moon.rawValue
        
        EarthNode?.position = SCNVector3(0.0, 0.0, 0.0)
        EarthNode?.geometry?.materials.removeAll()
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.nx)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.pz)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.px)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.nz)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.pym90)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.ny90)!)
        
        EarthNode?.geometry?.firstMaterial?.specular.contents = NSColor.clear
        EarthNode?.geometry?.firstMaterial?.lightingModel = .blinn
        
        let HourType = Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self, Default: .None)
        UpdateHourLabels(With: HourType)
        
        let Declination = Sun.Declination(For: Date())
        SystemNode = SCNNode()
        SystemNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
        HourNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
        
        self.prepare([EarthNode!, HourNode!], completionHandler:
            {
                success in
                if success
                {
                    self.SystemNode?.addChildNode(self.EarthNode!)
                    self.SystemNode?.addChildNode(self.HourNode!)
                    self.scene?.rootNode.addChildNode(self.SystemNode!)
                }
        }
        )
    }
}
