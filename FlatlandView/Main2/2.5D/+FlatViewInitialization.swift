//
//  +FlatViewInitialization.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/20/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension FlatView
{
    /// Initialize the view.
    func InitializeView()
    {
        Settings.AddSubscriber(self)
        
        #if DEBUG
        showsStatistics = true
        var DebugTypes = [DebugOptions3D]()
        Settings.QueryBool(.ShowSkeletons)
        {
            Show in
            if Show
            {
                DebugTypes.append(.Skeleton)
            }
        }
        Settings.QueryBool(.ShowBoundingBoxes)
        {
            Show in
            if Show
            {
                DebugTypes.append(.BoundingBoxes)
            }
        }
        Settings.QueryBool(.ShowWireframes)
        {
            Show in
            if Show
            {
                DebugTypes.append(.WireFrame)
            }
        }
        Settings.QueryBool(.ShowLightInfluences)
        {
            Show in
            if Show
            {
                DebugTypes.append(.LightInfluences)
            }
        }
        Settings.QueryBool(.ShowLightExtents)
        {
            Show in
            if Show
            {
                DebugTypes.append(.LightExtents)
            }
        }
        Settings.QueryBool(.ShowConstraints)
        {
            Show in
            if Show
            {
                DebugTypes.append(.Constraints)
            }
        }
        SetDebugOption(DebugTypes)
        #endif
        
        self.allowsCameraControl = true
        self.autoenablesDefaultLighting = false
        self.scene = SCNScene()
        self.backgroundColor = NSColor.clear
        self.antialiasingMode = .multisampling2X
        self.isJitteringEnabled = true
        
        CreateCamera()
        CreateLights()
        AddEarth()
        StartClock()
        UpdateEarthView()
        AddHourLayer()
        AddHours(HourRadius: FlatConstants.HourRadius.rawValue)
        AddNightMaskLayer()
        AddGridLayer()
        AddCityLayer()
        AddHeritageLayer()
        AddEarthquakeLayer()
        
        if Settings.GetBool(.ShowCities)
        {
            PlotCities()
        }
        else
        {
            HideCities()
        }
    }
    
    func CreateCamera()
    {
        RemoveNodeWithName(GlobeNodeNames.FlatlandCameraNode.rawValue)
        Camera = SCNCamera()
        Camera.wantsHDR = Settings.GetBool(.UseHDRCamera)
        Camera.fieldOfView = Settings.GetCGFloat(.FieldOfView, Defaults.FieldOfView)
        let ZFar = Settings.GetDouble(.ZFar, Defaults.ZFar)
        let ZNear = Settings.GetDouble(.ZNear, Defaults.ZNear)
        Camera.zFar = ZFar
        Camera.zNear = ZNear
        CameraNode = SCNNode()
        CameraNode.name = GlobeNodeNames.BuiltInCameraNode.rawValue
        CameraNode.camera = Camera
        CameraNode.position = Settings.GetVector(.InitialCameraPosition, SCNVector3(0.0, 0.0, Defaults.InitialZ.rawValue))
        self.scene?.rootNode.addChildNode(CameraNode)
    }
    
    func CreateLights()
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
    
    /// Create an ambient light for the scene.
    func CreateAmbientLight()
    {
        let Ambient = SCNLight()
        Ambient.categoryBitMask = LightMasks.Sun.rawValue
        Ambient.type = .ambient
        Ambient.intensity = CGFloat(Defaults.AmbientLightIntensity.rawValue)
        Ambient.castsShadow = true
        Ambient.shadowColor = NSColor.black.withAlphaComponent(CGFloat(Defaults.ShadowAlpha.rawValue))
        Ambient.shadowMode = .forward
        Ambient.shadowRadius = CGFloat(Defaults.ShadowRadius.rawValue)
        Ambient.color = NSColor.white
        AmbientLightNode = SCNNode()
        AmbientLightNode?.light = Ambient
        AmbientLightNode?.position = SCNVector3(0.0, 0.0, Defaults.AmbientLightZ.rawValue)
        self.scene?.rootNode.addChildNode(AmbientLightNode!)
        
        let BackNode = SCNNode()
        BackNode.light = Ambient
        BackNode.position = SCNVector3(0.0, 0.0, -Defaults.AmbientLightZ.rawValue)
        self.scene?.rootNode.addChildNode(BackNode)
    }
    
    /// Set up "sun light" for the scene.
    func SetSunlight()
    {
        SunLight = SCNLight()
        SunLight.categoryBitMask = LightMasks.Sun.rawValue
        SunLight.type = .directional
        SunLight.intensity = CGFloat(Defaults.SunLightIntensity.rawValue)
        SunLight.castsShadow = true
        SunLight.shadowColor = NSColor.black.withAlphaComponent(CGFloat(Defaults.ShadowAlpha.rawValue))
        SunLight.shadowMode = .forward
        SunLight.shadowRadius = CGFloat(Defaults.ShadowRadius.rawValue)
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
            let MoonLight = SCNLight()
            MoonLight.categoryBitMask = LightMasks.Moon.rawValue
            MoonLight.type = .directional
            MoonLight.intensity = CGFloat(Defaults.MoonLightIntensity.rawValue)
            MoonLight.castsShadow = true
            MoonLight.shadowColor = NSColor.black.withAlphaComponent(CGFloat(Defaults.ShadowAlpha.rawValue))
            MoonLight.shadowMode = .forward
            MoonLight.shadowRadius = CGFloat(Defaults.MoonLightShadowRadius.rawValue)
            MoonLight.color = NSColor.cyan
            MoonNode = SCNNode()
            MoonNode?.light = MoonLight
            MoonNode?.position = SCNVector3(0.0, 0.0, Defaults.MoonLightZ.rawValue)
            MoonNode?.eulerAngles = SCNVector3(180.0 * CGFloat.pi / 180.0, 0.0, 0.0)
            self.scene?.rootNode.addChildNode(MoonNode!)
            
            MetalMoonLight = SCNLight()
            MetalMoonLight.categoryBitMask = LightMasks.MetalMoon.rawValue
            MetalMoonLight.type = .directional
            MetalMoonLight.intensity = CGFloat(Defaults.MetalMoonLightIntensity.rawValue)
            MetalMoonLight.castsShadow = true
            MetalMoonLight.shadowColor = NSColor.black.withAlphaComponent(CGFloat(Defaults.ShadowAlpha.rawValue))
            MetalMoonLight.shadowMode = .forward
            MetalMoonLight.shadowRadius = CGFloat(Defaults.MoonLightShadowRadius.rawValue)
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
        MetalSunLight = SCNLight()
        MetalSunLight.categoryBitMask = LightMasks.MetalSun.rawValue
        MetalSunLight.type = .directional
        MetalSunLight.intensity = CGFloat(Defaults.MetalSunLightIntensity.rawValue)
        MetalSunLight.castsShadow = true
        MetalSunLight.shadowColor = NSColor.black.withAlphaComponent(CGFloat(Defaults.ShadowAlpha.rawValue))
        MetalSunLight.shadowMode = .forward
        MetalSunLight.shadowRadius = CGFloat(Defaults.ShadowRadius.rawValue)
        MetalSunLight.color = NSColor.white
        MetalSunNode = SCNNode()
        MetalSunNode.light = MetalSunLight
        MetalSunNode.position = SCNVector3(0.0, 0.0, Defaults.SunLightZ.rawValue)
        self.scene?.rootNode.addChildNode(MetalSunNode)
        
        MetalMoonLight = SCNLight()
        MetalMoonLight.categoryBitMask = LightMasks.MetalMoon.rawValue
        MetalMoonLight.type = .directional
        MetalMoonLight.intensity = CGFloat(Defaults.MetalMoonLightIntensity.rawValue)
        MetalMoonLight.castsShadow = true
        MetalMoonLight.shadowColor = NSColor.black.withAlphaComponent(CGFloat(Defaults.ShadowAlpha.rawValue))
        MetalMoonLight.shadowMode = .forward
        MetalMoonLight.shadowRadius = CGFloat(Defaults.MoonLightShadowRadius.rawValue)
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
        GridLight1 = SCNLight()
        GridLight1.type = .omni
        GridLight1.color = NSColor.white
        GridLight1.categoryBitMask = LightMasks.Grid.rawValue
        GridLightNode1 = SCNNode()
        GridLightNode1.light = GridLight1
        GridLightNode1.position = SCNVector3(0.0, 0.0, Defaults.Grid1Z.rawValue)
        self.scene?.rootNode.addChildNode(GridLightNode1)
        GridLight2 = SCNLight()
        GridLight2.type = .omni
        GridLight2.color = NSColor.white
        GridLight2.categoryBitMask = LightMasks.Grid.rawValue
        GridLightNode2 = SCNNode()
        GridLightNode2.light = GridLight2
        GridLightNode2.position = SCNVector3(0.0, 0.0, Defaults.Grid2Z.rawValue)
        self.scene?.rootNode.addChildNode(GridLightNode2)
    }
}
