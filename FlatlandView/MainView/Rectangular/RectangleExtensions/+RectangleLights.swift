//
//  +RectangleLights.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension RectangleView
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
        PolarLight.intensity = 1300//CGFloat(FlatConstants.PolarLightIntensity.rawValue)
        PolarLight.castsShadow = true
        PolarLight.shadowColor = NSColor.black//.withAlphaComponent(0.95)//CGFloat(Defaults.ShadowAlpha.rawValue))
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
        //let PolarNodeY = CGFloat(FlatConstants.FlatRadius.rawValue) + CGFloat(FlatConstants.PolarSunRimOffset.rawValue)
        let PolarNodeY = CGFloat(35)
        let PolarNodeZ = CGFloat(10)
        PolarNode.position = SCNVector3(0.0, PolarNodeY, PolarNodeZ)
//        PolarNode.position = SCNVector3(0.0, PolarNodeY, CGFloat(FlatConstants.PolarLightZTerminal.rawValue))
        #if true
        PolarNode.eulerAngles = SCNVector3(CGFloat(240.0.Radians), CGFloat(180.0.Radians), 0.0)
        #else
        let XOrientation = CGFloat(-FlatConstants.PolarLightXOrientation.rawValue.Radians)
        PolarNode.eulerAngles = SCNVector3(XOrientation, CGFloat(180.0.Radians), 0.0)
        #endif
        self.scene?.rootNode.addChildNode(PolarNode)
    }
    
    /// Update the intensity of the polar light.
    /// - Note: If `With` is not `1.0`, the default polar light intensity is multiplied by `With` to form the
    ///         final intensity value. This is to prevent multiple changes from causing unexpected values.
    /// - Parameter With: New intensity multiplier. If this value is `1.0`, the polar light's intensity is
    ///                   reset to the default value found in `FlatConstants.PolarLightIntensity`.
    func UpdatePolarLight(With IntensityMultiplier: Double)
    {
        #if false
        if IntensityMultiplier == 1.0
        {
            PolarNode.light?.intensity = CGFloat(FlatConstants.PolarLightIntensity.rawValue)
            return
        }
        let NewIntensity = CGFloat(FlatConstants.PolarLightIntensity.rawValue * IntensityMultiplier)
        PolarNode.light?.intensity = NewIntensity
        #endif
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
