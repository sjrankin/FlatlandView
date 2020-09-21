//
//  +Lights.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension GlobeView
{
    // MARK: - Light-related functions
    
    /// Setup lights to use to view the 3D scene.
    func SetupLights()
    {
        if Settings.GetBool(.UseAmbientLight)
        {
            CreateAmbientLight()
            MoonNode?.removeAllActions()
            MoonNode?.removeFromParentNode()
            MoonNode = nil
            LightNode.removeAllActions()
            LightNode.removeFromParentNode()
            MetalSunNode.removeAllActions()
            MetalSunNode.removeFromParentNode()
            MetalMoonNode.removeAllActions()
            MetalMoonNode.removeFromParentNode()
            GridLightNode1.removeAllActions()
            GridLightNode1.removeFromParentNode()
            GridLightNode2.removeAllActions()
            GridLightNode2.removeFromParentNode()
        }
        else
        {
            RemoveAmbientLight()
            SetGridLight()
            SetMetalLights()
            SetSunlight()
            SetMoonlight(Show: Settings.GetBool(.ShowMoonLight))
        }
    }
    
    /// Create a light to use for the 3D scene.
    /// - Parameter CastsShadow: If true, the light will cast a shadow. If false, no shadow will be shown.
    /// - Parameter Mask: The category mask for the light. If not specified `0` is used.
    /// - Returns: An `SCNLight` for the 3D scene.
    func CreateDefaultLight(CastsShadow: Bool = true, Mask: Int = 0) -> SCNLight
    {
        let Light = SCNLight()
        Light.categoryBitMask = Mask
        if CastsShadow
        {
            Light.castsShadow = true
            Light.shadowColor = NSColor.black.withAlphaComponent(CGFloat(Defaults.ShadowAlpha.rawValue))
            Light.shadowMode = .forward
            Light.shadowRadius = CGFloat(Defaults.ShadowRadius.rawValue)
            Light.shadowSampleCount = 1
            Light.shadowMapSize = CGSize(width: 2048, height: 2048)
            Light.automaticallyAdjustsShadowProjection = true
            Light.shadowCascadeCount = 3
            Light.shadowCascadeSplittingFactor = 0.09
        }
        Light.zFar = 1000
        Light.zNear = 0.1
        return Light
    }
    
    /// Create an ambient light for the scene.
    func CreateAmbientLight()
    {
        let Ambient = CreateDefaultLight(Mask: LightMasks3D.Sun.rawValue)
        Ambient.type = .ambient
        Ambient.intensity = CGFloat(Defaults.AmbientLightIntensity.rawValue)
        Ambient.color = NSColor.white
        AmbientLightNode = SCNNode()
        AmbientLightNode?.light = Ambient
        AmbientLightNode?.position = SCNVector3(0.0, 0.0, Defaults.AmbientLightZ.rawValue)
        self.scene?.rootNode.addChildNode(AmbientLightNode!)
    }
    
    /// Remove the ambient light from the scene.
    func RemoveAmbientLight()
    {
        AmbientLightNode?.removeAllActions()
        AmbientLightNode?.removeFromParentNode()
        AmbientLightNode = nil
    }
    
    /// Set up "sun light" for the scene.
    func SetSunlight()
    {
        SunLight = CreateDefaultLight(Mask: LightMasks3D.Sun.rawValue)
        SunLight.type = .directional
        SunLight.intensity = CGFloat(Defaults.SunLightIntensity.rawValue)
        SunLight.color = NSColor.white
        LightNode = SCNNode()
        LightNode.light = SunLight
        LightNode.position = SCNVector3(0.0, 0.0, Defaults.SunLightZ.rawValue)
        self.scene?.rootNode.addChildNode(LightNode)
    }
    
    /// Show or hide the moonlight node.
    /// - Parameter Show: Determines if moonlight is shown or removed.
    func SetMoonlight(Show: Bool)
    {
        if Show
        {
            let MoonLight = CreateDefaultLight(Mask: LightMasks3D.Moon.rawValue)
            MoonLight.type = .directional
            MoonLight.intensity = CGFloat(Defaults.MoonLightIntensity.rawValue)
            MoonLight.color = NSColor.cyan
            MoonNode = SCNNode()
            MoonNode?.light = MoonLight
            MoonNode?.position = SCNVector3(0.0, 0.0, Defaults.MoonLightZ.rawValue)
            MoonNode?.eulerAngles = SCNVector3(180.0 * CGFloat.pi / 180.0, 0.0, 0.0)
            self.scene?.rootNode.addChildNode(MoonNode!)
            
            MetalMoonLight = CreateDefaultLight(Mask: LightMasks3D.MetalMoon.rawValue)
            MetalMoonLight.type = .directional
            MetalMoonLight.intensity = CGFloat(Defaults.MetalMoonLightIntensity.rawValue)
            MetalMoonLight.color = NSColor.cyan
            MetalMoonNode = SCNNode()
            MetalMoonNode.light = MetalMoonLight
            MetalMoonNode.position = SCNVector3(0.0, 0.0, Defaults.MoonLightZ.rawValue)
            MetalMoonNode.eulerAngles = SCNVector3(180.0 * CGFloat.pi / 180.0, 0.0, 0.0)
            self.scene?.rootNode.addChildNode(MetalMoonNode)
        }
        else
        {
            MetalMoonNode.removeAllActions()
            MetalMoonNode.removeFromParentNode()
            MoonNode?.removeAllActions()
            MoonNode?.removeFromParentNode()
            MoonNode = nil
        }
    }
    
    /// Set the lights used for metallic components.
    func SetMetalLights()
    {
        MetalSunLight = CreateDefaultLight(Mask: LightMasks3D.MetalSun.rawValue)
        MetalSunLight.type = .directional
        MetalSunLight.intensity = CGFloat(Defaults.MetalSunLightIntensity.rawValue)
        MetalSunLight.color = NSColor.white
        MetalSunNode = SCNNode()
        MetalSunNode.light = MetalSunLight
        MetalSunNode.position = SCNVector3(0.0, 0.0, Defaults.SunLightZ.rawValue)
        self.scene?.rootNode.addChildNode(MetalSunNode)
        
        MetalMoonLight = CreateDefaultLight(Mask: LightMasks3D.MetalMoon.rawValue)
        MetalMoonLight.type = .directional
        MetalMoonLight.intensity = CGFloat(Defaults.MetalMoonLightIntensity.rawValue)
        MetalMoonLight.color = NSColor.cyan
        MetalMoonNode = SCNNode()
        MetalMoonNode.light = MetalMoonLight
        MetalMoonNode.position = SCNVector3(0.0, 0.0, Defaults.MoonLightZ.rawValue)
        MetalMoonNode.eulerAngles = SCNVector3(180.0 * CGFloat.pi / 180.0, 0.0, 0.0)
        self.scene?.rootNode.addChildNode(MetalMoonNode)
    }
    
    /// Set the lights for the grid. The grid needs a separate light because when it's over the night
    /// side, it's not easily visible. There are two grid lights - one for day time and one for night time.
    func SetGridLight()
    {
        GridLight1 = CreateDefaultLight(Mask: LightMasks3D.Grid.rawValue)
        GridLight1.type = .omni
        GridLight1.color = NSColor.white
        GridLightNode1 = SCNNode()
        GridLightNode1.light = GridLight1
        GridLightNode1.position = SCNVector3(0.0, 0.0, Defaults.Grid1Z.rawValue)
        self.scene?.rootNode.addChildNode(GridLightNode1)
        
        GridLight2 = CreateDefaultLight(Mask: LightMasks3D.Grid.rawValue)
        GridLight2.type = .omni
        GridLight2.color = NSColor.white
        GridLightNode2 = SCNNode()
        GridLightNode2.light = GridLight2
        GridLightNode2.position = SCNVector3(0.0, 0.0, Defaults.Grid2Z.rawValue)
        self.scene?.rootNode.addChildNode(GridLightNode2)
    }
}
