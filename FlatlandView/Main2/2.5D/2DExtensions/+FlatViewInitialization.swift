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
            LightNode.removeAllActions()
            LightNode.removeFromParentNode()
            GridLightNode1.removeAllActions()
            GridLightNode1.removeFromParentNode()
            GridLightNode2.removeAllActions()
            GridLightNode2.removeFromParentNode()
            NorthNode.removeAllActions()
            NorthNode.removeFromParentNode()
            SouthNode.removeAllActions()
            SouthNode.removeFromParentNode()
        }
        else
        {
            RemoveAmbientLight()
            SetGridLight()
            SetSunlight()
            SetPolarLights()
        }
    }
    
    /// Create an ambient light for the scene.
    func CreateAmbientLight()
    {
        let Ambient = SCNLight()
        Ambient.categoryBitMask = LightMasks3D.Sun.rawValue
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
    }
    
    /// Set up "sun light" for the scene.
    func SetSunlight()
    {
        SunLight = SCNLight()
        SunLight.categoryBitMask = LightMasks2D.Sun.rawValue
        SunLight.type = .omni//.directional
        //SunLight.intensity = CGFloat(Defaults.SunLightIntensity.rawValue)
        SunLight.intensity = 400.0
        
        /*
        SunLight.castsShadow = true
        SunLight.shadowColor = NSColor.black.withAlphaComponent(CGFloat(Defaults.ShadowAlpha.rawValue))
        SunLight.shadowMode = .forward
        SunLight.shadowRadius = CGFloat(Defaults.ShadowRadius.rawValue)
 */
        SunLight.color = NSColor.white
        LightNode = SCNNode()
        LightNode.light = SunLight
        LightNode.position = SCNVector3(0.0, 0.0, Defaults.SunLightZ.rawValue)
        self.scene?.rootNode.addChildNode(LightNode)
    }
    
    func SetPolarLights()
    {
        NorthLight = SCNLight()
        NorthLight.categoryBitMask = LightMasks2D.North.rawValue
        NorthLight.type = .spot
        NorthLight.intensity = 3000
        NorthLight.castsShadow = true
        NorthLight.shadowColor = NSColor.black.withAlphaComponent(CGFloat(Defaults.ShadowAlpha.rawValue))
        NorthLight.shadowMode = .forward
        NorthLight.shadowRadius = CGFloat(Defaults.ShadowRadius.rawValue)
        NorthLight.shadowSampleCount = 1
        NorthLight.shadowMapSize = CGSize(width: 2048, height: 2048)
        NorthLight.automaticallyAdjustsShadowProjection = true
        NorthLight.shadowCascadeCount = 3
        NorthLight.shadowCascadeSplittingFactor = 0.09
        NorthLight.color = NSColor.white
        NorthLight.zFar = 100
        NorthLight.spotOuterAngle = 80.0
        NorthNode = SCNNode()
        NorthNode.light = NorthLight
        NorthNode.position = SCNVector3(0.0, CGFloat(FlatConstants.FlatRadius.rawValue) + 6, 2.5)
        NorthNode.eulerAngles = SCNVector3(-85.0.Radians, 0.0, 0.0)
        self.scene?.rootNode.addChildNode(NorthNode)
        #if false
        SouthLight = SCNLight()
        SouthLight.categoryBitMask = LightMasks2D.South.rawValue
        SouthLight.type = .spot
        SouthLight.intensity = 1000
        SouthLight.castsShadow = true
        SouthLight.shadowColor = NSColor.black.withAlphaComponent(CGFloat(Defaults.ShadowAlpha.rawValue))
        SouthLight.shadowMode = .forward
        SouthLight.shadowRadius = CGFloat(Defaults.ShadowRadius.rawValue)
        SouthLight.color = NSColor.yellow
        SouthNode = SCNNode()
        SouthNode.light = SouthLight
        SouthNode.position = SCNVector3(0.0, -CGFloat(FlatConstants.FlatRadius.rawValue), 0.1)
        SouthNode.eulerAngles = SCNVector3(90.0.Radians, 0.0, 0.0)
        self.scene?.rootNode.addChildNode(SouthNode)
        #endif
    }
    
    /// Set the lights for the grid. The grid needs a separate light because when it's over the night
    /// side, it's not easily visible. There are two grid lights - one for day time and one for night time.
    func SetGridLight()
    {
        GridLight1 = SCNLight()
        GridLight1.type = .omni
        GridLight1.color = NSColor.white
        GridLight1.categoryBitMask = LightMasks2D.Grid.rawValue
        GridLightNode1 = SCNNode()
        GridLightNode1.light = GridLight1
        GridLightNode1.position = SCNVector3(0.0, 0.0, Defaults.Grid1Z.rawValue)
        self.scene?.rootNode.addChildNode(GridLightNode1)
        GridLight2 = SCNLight()
        GridLight2.type = .omni
        GridLight2.color = NSColor.white
        GridLight2.categoryBitMask = LightMasks2D.Grid.rawValue
        GridLightNode2 = SCNNode()
        GridLightNode2.light = GridLight2
        GridLightNode2.position = SCNVector3(0.0, 0.0, Defaults.Grid2Z.rawValue)
        self.scene?.rootNode.addChildNode(GridLightNode2)
    }
}
