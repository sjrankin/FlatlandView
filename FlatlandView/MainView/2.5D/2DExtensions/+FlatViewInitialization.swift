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
        AddFollowPlane()
        AddSun()
        UpdateLightsForShadows(ShowShadows: Settings.GetBool(.Show2DShadows))
        #if false
        SetupMouseHandling()
        #endif
        
        CameraObserver = self.observe(\.pointOfView?.position, options: [.new, .initial])
        {
            (Node, Change) in
            OperationQueue.current?.addOperation
            {
                let Location = Node.pointOfView!.position
                let Distance = sqrt((Location.x * Location.x) + (Location.y * Location.y) + (Location.z * Location.z))
                if self.PreviousCameraDistance == nil
                {
                    self.PreviousCameraDistance = Int(Distance)
                }
                else
                {
                    if self.PreviousCameraDistance != Int(Distance)
                    {
                        self.PreviousCameraDistance = Int(Distance)
                        self.UpdateViewForCameraLocation(Distance: Distance)
                    }
                }
            }
        }
    }
    
    /// Update the view depending on the distance of the camera from the center of the scene.
    /// - Parameter Distance: The distance from the camera to the center of the scene.
    func UpdateViewForCameraLocation(Distance: CGFloat)
    {
        var FinalQuakeScale: CGFloat? = nil
        let QDist = Int(Distance)
        for (Final, Min, Max) in QuakeScaleMap
        {
            if QDist >= Min && QDist <= Max
            {
                FinalQuakeScale = Final
                break
            }
        }
        if FinalQuakeScale == nil
        {
            FinalQuakeScale = QuakeScaleMap.last!.ScaleLevel
        }
        var UpdateQuakes: Bool = true
        if PreviousQuakeScale == nil
        {
            PreviousQuakeScale = FinalQuakeScale
        }
        else
        {
            if PreviousQuakeScale! == FinalQuakeScale
            {
                UpdateQuakes = false
            }
            PreviousQuakeScale = FinalQuakeScale
        }
        if UpdateQuakes
        {
            UpdateQuakeTextNodes(To: FinalQuakeScale!)
        }
        
        var FinalCityScale: CGFloat? = nil
        let CDist = Int(Distance)
        for (Final, Min, Max) in CityScaleMap
        {
            if CDist >= Min && CDist <= Max
            {
                FinalQuakeScale = Final
                break
            }
        }
        if FinalCityScale == nil
        {
            FinalCityScale = CityScaleMap.last!.ScaleLevel
        }
        var UpdateCities: Bool = true
        if PreviousCityScale == nil
        {
            PreviousCityScale = FinalCityScale
        }
        else
        {
            if PreviousCityScale! == FinalCityScale
            {
                UpdateCities = false
            }
            PreviousCityScale = FinalCityScale
        }
        if UpdateCities
        {
            UpdateCityTextNodes(To: FinalCityScale!)
        }
    }
    
    /// Update the scale of earthquake text nodes.
    /// - Parameter To: The new scale to apply to earthquake text nodes.
    func UpdateQuakeTextNodes(To Scale: CGFloat)
    {
        for Node in QuakePlane.ChildNodes2()
        {
            if Node.IsTextNode
            {
                Node.scale = SCNVector3(Scale)
            }
        }
    }
    
    /// Update the scale of city name text nodes.
    /// - Parameter To: The new scale to apply to city name text nodes.
    func UpdateCityTextNodes(To Scale: CGFloat)
    {
        for Node in CityPlane.ChildNodes2()
        {
            if Node.IsTextNode
            {
                Node.scale = SCNVector3(Scale)
            }
        }
    }
    
    func UpdateGrid()
    {
        AddGridLayer()
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
    
    #if false
    /// Initialize handling the mouse in 2D mode for certain tasks.
    func SetupMouseHandling()
    {
        let ClickRecognizer = NSClickGestureRecognizer(target: self, action: #selector(HandleMouseClick(Recognizer:)))
        self.addGestureRecognizer(ClickRecognizer)
    }
    
    /// If the user clicks on the sun, change the view (from north-centered to south-centered and back).
    @objc func HandleMouseClick(Recognizer: NSGestureRecognizer)
    {
        let Where = Recognizer.location(in: self)
        if Recognizer.state == .ended
        {
            let Results = self.hitTest(Where, options: [.boundingBoxOnly: true])
            if Results.count > 0
            {
                let Node = Results[0].node
                if let NodeName = Node.name
                {
                    if NodeName == NodeNames2D.Sun.rawValue
                    {
                        let MapCenter = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter)
                        switch MapCenter
                        {
                            case .CubicWorld:
                                return
                                
                            case .Globe3D:
                                return
                                
                            case .FlatNorthCenter:
                                Settings.SetEnum(.FlatSouthCenter, EnumType: ViewTypes.self, ForKey: .ViewType)
                                
                            case .FlatSouthCenter:
                                Settings.SetEnum(.FlatNorthCenter, EnumType: ViewTypes.self, ForKey: .ViewType)
                                
                            case .Rectangular:
                                Settings.SetEnum(.Rectangular, EnumType: ViewTypes.self, ForKey: .ViewType)
                        }
                        MainDelegate?.UpdateViewType()
                        return
                    }
                }
            }
        }
        print("Passing hit to super")
        super.hitTest(Where, options: nil)
    }
    #endif
    
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
