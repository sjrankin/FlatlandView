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
                #if true
                let Distance = self.CameraDistance(POV: Node.pointOfView!)
                #else
                let Location = Node.pointOfView!.position
                let Distance = sqrt((Location.x * Location.x) + (Location.y * Location.y) + (Location.z * Location.z))
                #endif
                if self.PreviousCameraDistance == nil
                {
                    self.PreviousCameraDistance = Int(Distance)
                }
                else
                {
                    if self.PreviousCameraDistance != Int(Distance)
                    {
                        self.PreviousCameraDistance = Int(Distance)
                        self.UpdateQuakeTextForCameraLocation(Distance: Distance)
                        self.UpdateCityTextForCameraLocation(Distance: Distance)
                    }
                }
            }
        }
        
        StartDarknessClock()
    }
    
    /// Start the darkness clock to update node states depending on whether the node is in the sun or not.
    func StartDarknessClock()
    {
        DarknessClock = Timer.scheduledTimer(timeInterval: HourConstants.DaylightCheckInterval.rawValue,
                                             target: self,
                                             selector: #selector(UpdateNodesForSunlight),
                                             userInfo: nil,
                                             repeats: true)
        UpdateNodesForSunlight()
    }
    
    /// Update nodes in the map for sunlight for those nodes that may need to change state.
    /// - Note: Shapes in `QuakePlane` and `CityPlane` are updated.
    @objc func UpdateNodesForSunlight()
    {
        QuakePlane.ForEachChild2
        {
            Node in
            if Node.CanSwitchState && Node.HasLocation()
            {
                let NodeLocation = GeoPoint(Node.Latitude!, Node.Longitude!)
                NodeLocation.CurrentTime = Date()
                if let SunIsVisible = Solar.IsInDaylight(Node.Latitude!, Node.Longitude!)
                {
                    Node.IsInDaylight = SunIsVisible
                }
            }
        }
        CityPlane.ForEachChild2
        {
            Node in
            if Node.CanSwitchState && Node.HasLocation()
            {
                let NodeLocation = GeoPoint(Node.Latitude!, Node.Longitude!)
                NodeLocation.CurrentTime = Date()
                if let SunIsVisible = Solar.IsInDaylight(Node.Latitude!, Node.Longitude!)
                {
                    Node.IsInDaylight = SunIsVisible
                }
            }
        }
    }
    
    /// Given the point-of-view node, return the distance from it to the center of the scene.
    /// - Parameter POV: The point-of-view node. This code will work for any node to the center but is assumed
    ///                  to be intended for the point-of-view node.
    /// - Returns: Distance to the center of the scene from the passed node.
    func CameraDistance(POV Node: SCNNode) -> CGFloat
    {
        let Location = Node.position
        let Distance = sqrt((Location.x * Location.x) + (Location.y * Location.y) + (Location.z * Location.z))
        return Distance
    }
    
    /// Calculates the scale value for earthquake magnitude objects based on the distance from the point-of
    /// view node to the center of the scene.
    /// - Parameter From: The distance from the point-of-view node to the center of the scene.
    /// - Returns: The scale value to use for earthquake magnitude objects.
    func GetQuakeTextScale(From Distance: CGFloat) -> CGFloat
    {
        let QuakeRange = FlatConstants.QuakeMagnitudeScaleHigh.rawValue - FlatConstants.QuakeMagnitudeScaleLow.rawValue
        var DistPercent = Double(Distance) / Defaults.InitialZ.rawValue
        if DistPercent > 1.0
        {
            DistPercent = 1.0
        }
        let FinalQuakeScale = CGFloat(QuakeRange * DistPercent) + CGFloat(FlatConstants.QuakeMagnitudeScaleLow.rawValue)
        return FinalQuakeScale
    }
    
    /// Update the quake text depending on the distance of the camera from the center of the scene.
    /// - Parameter Distance: The distance from the camera to the center of the scene.
    func UpdateQuakeTextForCameraLocation(Distance: CGFloat)
    {
        let FinalQuakeScale = GetQuakeTextScale(From: Distance)
        for Node in QuakePlane.ChildNodes2()
        {
            if Node.IsTextNode
            {
                Node.scale = SCNVector3(FinalQuakeScale)
            }
        }
    }
    
    /// Calculates the scale value for city name objects based on the distance from the point-of
    /// view node to the center of the scene.
    /// - Parameter From: The distance from the point-of-view node to the center of the scene.
    /// - Returns: The scale value to use for city name objects.
    func GetCityTextScale(From Distance: CGFloat) -> CGFloat
    {
        let CityRange = FlatConstants.CityNameScaleHigh.rawValue - FlatConstants.CityNameScaleLow.rawValue
        var DistPercent = Double(Distance) / Defaults.InitialZ.rawValue
        if DistPercent > 1.0
        {
            DistPercent = 1.0
        }
        let FinalCityScale = CGFloat(CityRange * DistPercent) + CGFloat(FlatConstants.CityNameScaleLow.rawValue)
        return FinalCityScale
    }
    
    /// Update the city text depending on the distance of the camera from the center of the scene.
    /// - Parameter Distance: The distance from the camera to the center of the scene.
    func UpdateCityTextForCameraLocation(Distance: CGFloat)
    {
        let FinalCityScale = GetCityTextScale(From: Distance)
        for Node in CityPlane.ChildNodes2()
        {
            if Node.IsTextNode
            {
                Node.scale = SCNVector3(FinalCityScale)
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
