//
//  +RectangleViewInitialization.swift
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
        AddSun()
        UpdateLightsForShadows(ShowShadows: Settings.GetBool(.Show2DShadows))
        SetupMouseHandling()
    }
    
    /// Initialize location objects (eg, cities and World Heritage Sites).
    func InitializeLocations()
    {
        if Settings.GetBool(.ShowCities)
        {
            PlotCities()
        }
        else
        {
            HideCities()
        }
        
        if Settings.GetBool(.ShowWorldHeritageSites)
        {
            PlotWorldHeritageSites() 
        }
        else
        {
            HideWorldHeritageSites()
        }
    }
    
    /// Initialize handling the mouse in 2D mode for certain tasks.
    func SetupMouseHandling()
    {
    }
    
    /// Create the camera. Remove any previously created cameras.
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
    
    /// Create the lights.
    func CreateLights()
    {
        if Settings.GetBool(.UseAmbientLight)
        {
            CreateAmbientLight() 
            LightNode.removeAllActions()
            LightNode.removeFromParentNode()
            GridLightNode.removeAllActions()
            GridLightNode.removeFromParentNode()
            PolarNode.removeAllActions()
            PolarNode.removeFromParentNode()
        }
        else
        {
            RemoveAmbientLight()
            SetGridLight()
            SetSunlight()
            SetPolarLight()
            SetHourLight()
        }
    }
}
