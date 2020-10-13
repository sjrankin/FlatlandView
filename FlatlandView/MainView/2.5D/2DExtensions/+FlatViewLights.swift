//
//  +FlatViewLights.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/22/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension FlatView
{
    /// Create an ambient light for the scene. Create a secondary ambient light for the sun nodes.
    func CreateAmbientLight()
    {
        let Ambient = SCNLight()
        Ambient.name = LightNames.Ambient2D.rawValue
        Ambient.categoryBitMask = LightMasks2D.Ambient.rawValue
        Ambient.type = .ambient
        Ambient.intensity = CGFloat(Defaults.AmbientLightIntensity.rawValue)
        Ambient.castsShadow = true
        Ambient.shadowColor = NSColor.black.withAlphaComponent(CGFloat(Defaults.ShadowAlpha.rawValue))
        Ambient.shadowMode = .forward
        Ambient.shadowRadius = CGFloat(Defaults.ShadowRadius.rawValue)
        Ambient.color = NSColor.white
        AmbientLightNode = SCNNode()
        AmbientLightNode?.name = LightNames.Ambient2D.rawValue
        AmbientLightNode?.light = Ambient
        AmbientLightNode?.position = SCNVector3(0.0, 0.0, Defaults.AmbientLightZ.rawValue)
        self.scene?.rootNode.addChildNode(AmbientLightNode!)
        
        let AmbientSun = SCNLight()
        AmbientSun.name = LightNames.AmbientSun2D.rawValue
        AmbientSun.categoryBitMask = LightMasks2D.AmbientSun.rawValue
        AmbientSun.intensity = CGFloat(Defaults.AmbientLightIntensity.rawValue)
        AmbientSun.castsShadow = false
        AmbientSunLightNode = SCNNode()
        AmbientSunLightNode.name = LightNames.AmbientSun2D.rawValue
        AmbientSunLightNode.light = AmbientSun
        self.scene?.rootNode.addChildNode(AmbientSunLightNode)
    }
    
    /// Set up "sun light" for the scene.
    func SetSunlight()
    {
        SunLight = SCNLight()
        SunLight.name = LightNames.Sun2D.rawValue
        SunLight.categoryBitMask = LightMasks2D.Sun.rawValue
        SunLight.type = .omni
        SunLight.intensity = CGFloat(FlatConstants.SunLightIntensity.rawValue)
        SunLight.color = NSColor.white
        LightNode = SCNNode()
        LightNode.name = LightNames.Sun2D.rawValue
        LightNode.light = SunLight
        LightNode.position = SCNVector3(0.0, 0.0, 20.0)//FlatConstants.SunLightZ.rawValue)
        self.scene?.rootNode.addChildNode(LightNode)
    }
    
    func SetHourLight()
    {
        HourLight = SCNLight()
        HourLight.name = LightNames.Hour2D.rawValue
        HourLight.categoryBitMask = LightMasks2D.Hours.rawValue
        HourLight.type = .directional
        HourLight.color = NSColor.white
        HourLightNode = SCNNode()
        HourLightNode.name = LightNames.Hour2D.rawValue
        HourLightNode.light = HourLight
        HourLightNode.position = SCNVector3(0.0, 0.0, 20.0)
        self.scene?.rootNode.addChildNode(HourLightNode)
    }
    
    /// Create the polar light.
    func SetPolarLight()
    {
        PolarLight = SCNLight()
        PolarLight.name = LightNames.Polar2D.rawValue
        PolarLight.categoryBitMask = LightMasks2D.Polar.rawValue
        PolarLight.type = .spot
        PolarLight.intensity = CGFloat(FlatConstants.PolarLightIntensity.rawValue)
        PolarLight.castsShadow = true
        PolarLight.shadowColor = NSColor.black.withAlphaComponent(CGFloat(Defaults.ShadowAlpha.rawValue))
        PolarLight.shadowMode = .forward
        PolarLight.shadowRadius = CGFloat(Defaults.ShadowRadius.rawValue)
        PolarLight.shadowSampleCount = 1
        PolarLight.shadowMapSize = CGSize(width: Int(FlatConstants.ShadowMapSide.rawValue),
                                          height: Int(FlatConstants.ShadowMapSide.rawValue))
        PolarLight.automaticallyAdjustsShadowProjection = true
        PolarLight.shadowCascadeCount = 3
        PolarLight.shadowCascadeSplittingFactor = CGFloat(FlatConstants.ShadowSplitting.rawValue)
        PolarLight.color = NSColor.white
        PolarLight.zFar = CGFloat(FlatConstants.PolarZFar.rawValue)
        PolarLight.zNear = CGFloat(FlatConstants.PolarZNear.rawValue)
        PolarLight.spotOuterAngle = CGFloat(FlatConstants.PolarLightOuterAngle.rawValue)
        PolarNode = SCNNode()
        PolarNode.name = LightNames.Polar2D.rawValue
        PolarNode.light = PolarLight
        let PolarNodeY = CGFloat(FlatConstants.FlatRadius.rawValue) + CGFloat(FlatConstants.PolarSunRimOffset.rawValue)
        PolarNode.position = SCNVector3(0.0, PolarNodeY, CGFloat(FlatConstants.PolarLightZTerminal.rawValue))
        let XOrientation = CGFloat(FlatConstants.PolarLightXOrientation.rawValue.Radians)
        PolarNode.eulerAngles = SCNVector3(XOrientation, 0.0, 0.0)
        self.scene?.rootNode.addChildNode(PolarNode)
    }
    
    /// Update the intensity of the polar light.
    /// - Note: If `With` is not `1.0`, the default polar light intensity is multiplied by `With` to form the
    ///         final intensity value. This is to prevent multiple changes from causing unexpected values.
    /// - Parameter With: New intensity multiplier. If this value is `1.0`, the polar light's intensity is
    ///                   reset to the default value found in `FlatConstants.PolarLightIntensity`.
    func UpdatePolarLight(With IntensityMultiplier: Double)
    {
        print("Updating polar light with multiplier: \(IntensityMultiplier)")
        if IntensityMultiplier == 1.0
        {
            PolarNode.light?.intensity = CGFloat(FlatConstants.PolarLightIntensity.rawValue)
            return
        }
        let NewIntensity = CGFloat(FlatConstants.PolarLightIntensity.rawValue * IntensityMultiplier)
        PolarNode.light?.intensity = NewIntensity
            print("  PolarNode.light?.intensity=\(PolarNode.light?.intensity)")
    }
    
    /// Move the polar light to the appropriate pole to cast shadows.
    /// - Note: The 2D sun node is also moved along with the light.
    /// - Parameter ToNorth: Determines if the polar light is moved to the north or south pole.
    func MovePolarLight(ToNorth: Bool)
    {
        var LightPath = Utility.PointsOnArc(Radius: FlatConstants.FlatRadius.rawValue + FlatConstants.PolarSunRimOffset.rawValue,
                                            Count: Int(FlatConstants.LightPathSegmentCount.rawValue))
        if ToNorth
        {
            LightPath = LightPath.reversed()
        }
        LightPath = Utility.AdjustPointsOnArc(LightPath, XValue: 0.0, ZOffset: Double(PolarNode.position.z),
                                              ZMultiplier: FlatConstants.PolarLightPathZMultiplier.rawValue)
        LightNode.position = LightPath[0]
        let OverallDuration = FlatConstants.PolarAnimationDuration.rawValue
        let XOrientation = CGFloat(FlatConstants.PolarLightXOrientation.rawValue.Radians)
        var NewPitch: CGFloat = 0.0
        if ToNorth
        {
            NewPitch = -XOrientation
        }
        else
        {
            NewPitch = XOrientation
        }
        let SegmentDuration = OverallDuration / Double(LightPath.count - 1)
        var ArcSegments = [SCNAction]()
        for Index in 1 ..< LightPath.count
        
        {
            let Motion = SCNAction.move(to: SCNVector3(0.0, LightPath[Index].y, LightPath[Index].z), duration: SegmentDuration)
            ArcSegments.append(Motion)
        }
        let MotionSequence = SCNAction.sequence(ArcSegments)
        
        let IntensityAnimation = SCNAction.customAction(duration: OverallDuration)
        {
            Node, Elapsed in
            let PercentElapsed = Elapsed / CGFloat(OverallDuration)
            var Percent = PercentElapsed > 0.5 ? 1.0 - PercentElapsed : PercentElapsed
            Percent = 1.0 - Percent
            Node.light?.intensity = CGFloat(FlatConstants.PolarLightIntensity.rawValue * self.PrimaryLightMultiplier) * Percent
        }
        
        let Pitch = SCNAction.rotateTo(x: NewPitch, y: 0.0, z: 0.0, duration: OverallDuration)
        let Batch = SCNAction.group([MotionSequence, Pitch, IntensityAnimation])
        PolarNode.runAction(Batch)
        {
            self.PolarNode.removeAllAnimations()
        }
        
        let SunPoleOrientation = SCNAction.rotateTo(x: CGFloat(180.0.Radians), y: 0.0, z: 0.0,
                                                    duration: OverallDuration)
        let SunBatch = SCNAction.group([MotionSequence, SunPoleOrientation])
        SunNode.runAction(SunBatch)
        {
            self.SunNode.removeAllAnimations()
        }
    }
    
    /// Set the light for the grid.
    func SetGridLight()
    {
        GridLight = SCNLight()
        GridLight.type = .omni
        GridLight.color = NSColor.white
        GridLight.categoryBitMask = LightMasks2D.Grid.rawValue
        GridLightNode = SCNNode()
        GridLightNode.castsShadow = false
        GridLightNode.light = GridLight
        GridLightNode.position = SCNVector3(0.0, 0.0, FlatConstants.GridLightZ.rawValue)
        self.scene?.rootNode.addChildNode(GridLightNode)
    }
}
