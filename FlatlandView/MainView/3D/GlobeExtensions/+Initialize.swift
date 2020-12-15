//
//  +Initialize.swift
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
    /// Initialize the globe view.
    /// - Note: See: [Get camera position.](https://stackoverflow.com/questions/24768031/can-i-get-the-scnview-camera-position-when-using-allowscameracontrol)
    func InitializeView()
    {
        Settings.AddSubscriber(self)
        
        #if DEBUG
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
        
        /// Watch the camera to ensure we always have the camera's orientation.
        CameraObserver = self.observe(\.pointOfView?.position, options: [.new, .initial])
        {
            (Node, Change) in
            OperationQueue.current?.addOperation
            {
                let Location = Node.pointOfView!.position
                self.CameraPointOfView = Location
                self.CameraOrientation = Node.pointOfView!.orientation
                self.CameraRotation = Node.pointOfView!.rotation
            }
        }
        
        #if false
        //If the user-camera control is enabled, this prevents the user from zooming in too close to the
        //view by checking the run-time Z value and resetting the current point of view to the minimum
        //value found in the user settings (but which is not user-accessible).
        if self.allowsCameraControl
        {
            //https://stackoverflow.com/questions/24768031/can-i-get-the-scnview-camera-position-when-using-allowscameracontrol
            CameraObserver = self.observe(\.pointOfView?.position, options: [.new, .initial])
            {
                (Node, Change) in
                OperationQueue.current?.addOperation
                {
                    let Location = Node.pointOfView!.position
                    Debug.Print("POV: \(Location)")
                    /*
                    if self.OldPointOfView == nil
                    {
                        self.OldPointOfView = Node.pointOfView!.position
                        return
                    }
                    let Distance = sqrt(Node.pointOfView!.position.x + Node.pointOfView!.position.y +
                                            Node.pointOfView!.position.z)
                    let Closest = Settings.GetCGFloat(.ClosestZ, Defaults.ClosestZ)
                    if Distance < Closest
                    {
                        print("\(Distance)<\(Closest)")
                        Node.pointOfView!.position = self.OldPointOfView!
                    }
                    else
                    {
                        self.OldPointOfView = Node.pointOfView!.position
                    }
 */
                }
            }
        }
        #endif
        
        self.autoenablesDefaultLighting = false
        self.scene = SCNScene()
        self.backgroundColor = NSColor.clear
        //Higher antialiasing mode values tend to use a lot of alpha which SceneKit uses when doing final
        //rendering, making the globe transparent along the edges of grid lines, which looks really weird.
        switch Settings.GetEnum(ForKey: .AntialiasLevel, EnumType: SceneJitters.self, Default: .Jitter4X)
        {
            case .None:
                self.antialiasingMode = .none
                
            case .Jitter2X:
                self.antialiasingMode = .multisampling2X
                
            case .Jitter4X:
                self.antialiasingMode = .multisampling4X
                
            case .Jitter8X:
                self.antialiasingMode = .multisampling8X
                
            case .Jitter16X:
                self.antialiasingMode = .multisampling16X
        }
        self.antialiasingMode = .multisampling16X
        self.isJitteringEnabled = Settings.GetBool(.EnableJittering)
        #if DEBUG
        self.showsStatistics = Settings.GetBool(.ShowStatistics)
        #else
        self.showsStatistics = false
        #endif
        
        #if false
        InitializeSceneCamera(Settings.GetBool(.UseSystemCameraControl))
        #else
        CreateCamera()
        #endif
        SetupLights()
        
        AddEarth()
        if Settings.GetBool(.InAttractMode)
        {
            StopClock()
            AttractEarth()
        }
        else
        {
            StartClock()
        }
        UpdateEarthView()
        StartDarknessClock()
        #if DEBUG
        //TestMouseIndicator()
        #endif
        #if DEBUG
        if Settings.GetBool(.ShowAxes)
        {
            AddAxis()
        }
        if Settings.GetBool(.ShowKnownLocations)
        {
            PlotKnownLocations()
        }
        #endif
        ApplyInitialStencils()
    }
    
    #if DEBUG
    /// Test the mouse indicator. Intended only for testing/debugging purposes.
    func TestMouseIndicator()
    {
        MouseIndicator = MakeMouseIndicator()
        EarthNode?.addChildNode(MouseIndicator!)
        let _ = Timer.scheduledTimer(timeInterval: 0.005,
                                     target: self,
                                     selector: #selector(MoveIndicator),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    /// Move the mouse indicator on a semi-circular path. Intended only for testing/debug purposes.
    @objc func MoveIndicator()
    {
        let (X, Y, Z) = ToECEF(IndicatorLatitude,
                               IndicatorLongitude,
                               Radius: Double(GlobeRadius.Primary.rawValue + 0.9))
        MainDelegate?.MouseAtLocation(Latitude: IndicatorLatitude, Longitude: IndicatorLongitude,
                                      Caller: #function)
        MouseIndicator?.position = SCNVector3(X, Y, Z)
        MouseIndicator?.eulerAngles = SCNVector3(CGFloat(IndicatorLatitude + 90.0).Radians,
                                                 CGFloat(IndicatorLongitude + 180.0).Radians,
                                                 0.0)
        IndicatorLongitude = IndicatorLongitude + LongitudeIncrement
        if IndicatorLongitude >= 360.0
        {
            IndicatorLongitude = 0.0
        }
        IndicatorLatitude = IndicatorLatitude + (LatitudeIncrement * IndicatorLatitudeDirection)
        if IndicatorLatitude > 90.0
        {
            IndicatorLatitudeDirection = -1.0
            IndicatorLatitude = 90.0 - LatitudeIncrement
            IndicatorLongitude = IndicatorLongitude + 180.0
        }
        if IndicatorLatitude < -90.0
        {
            IndicatorLatitudeDirection = 1.0
            IndicatorLatitude = -90.0 + LatitudeIncrement
            IndicatorLongitude = IndicatorLongitude + 180.0
        }
    }
    #endif
    
    /// Start the darkness clock. The handler will be called to determine if a node is in night or dark and
    /// change attributes accordingly.
    func StartDarknessClock()
    {
        DarkClock = Timer.scheduledTimer(timeInterval: 5.0,
                                         target: self,
                                         selector: #selector(UpdateNodes),
                                         userInfo: nil,
                                         repeats: true)
        UpdateNodes()
    }
    
    /// Go through all child nodes in the `EarthNode` and update those that allow it for daylight visibility.
    /// This is used to switch visual attributes to make nodes more visible in the night.
    @objc func UpdateNodes()
    {
        if EarthNode == nil
        {
            Debug.Print("No EarthNode in \(#function)")
            return
        }
        for Node in EarthNode!.childNodes
        {
            if let UpdateNode = Node as? SCNNode2
            {
                if UpdateNode.CanSwitchState
                {
                    if UpdateNode.HasLocation()
                    {
                        let NodeLocation = GeoPoint(UpdateNode.Latitude!, UpdateNode.Longitude!)
                        NodeLocation.CurrentTime = Date()
                        if let SunIsVisible = Solar.IsInDaylight(UpdateNode.Latitude!, UpdateNode.Longitude!)
                        {
                            UpdateNode.IsInDaylight = SunIsVisible
                        }
                    }
                }
            }
        }
    }
    
    /// Create the default camera. This is the camera that `allowsCameraControl` manipulates.
    func CreateCamera()
    {
        RemoveNodeWithName(GlobeNodeNames.FlatlandCameraNode.rawValue)
        Camera = SCNCamera()
        Camera.wantsHDR = Settings.GetBool(.UseHDRCamera)
        #if true
        Camera.fieldOfView = Settings.GetCGFloat(.FieldOfView, Defaults.FieldOfView)
        #else
        Camera.usesOrthographicProjection = true
        Camera.orthographicScale = Settings.GetDouble(.OrthographicScale, 14.0)
        #endif
        Camera.zFar = Settings.GetDouble(.ZFar, Defaults.ZFar)
        Camera.zNear = Settings.GetDouble(.ZNear, Defaults.ZNear)
        CameraNode = SCNNode()
        CameraNode.name = GlobeNodeNames.BuiltInCameraNode.rawValue
        CameraNode.camera = Camera
        CameraNode.position = Settings.GetVector(.InitialCameraPosition, SCNVector3(0.0, 0.0, Defaults.InitialZ.rawValue))
        self.scene?.rootNode.addChildNode(CameraNode)
    }
    
    /// Resets the default camera to its original location.
    /// - Note: In order to prevent the Earth from flying around wildly during the reset transition, a
    ///         look-at constraint is added for the duration of the transition, and removed once the rotation
    ///         transition is completed.
    func ResetCamera()
    {
        let Constraint = SCNLookAtConstraint(target: SystemNode)
        Constraint.isGimbalLockEnabled = false
        SCNTransaction.begin()
        SCNTransaction.animationDuration = Defaults.ResetCameraAnimationDuration.rawValue
        self.pointOfView?.constraints = [Constraint]
        SCNTransaction.commit()
        
        let InitialPosition = Settings.GetVector(.InitialCameraPosition, SCNVector3(0.0, 0.0, Defaults.InitialZ.rawValue))
        let PositionAction = SCNAction.move(to: InitialPosition, duration: Defaults.ResetCameraAnimationDuration.rawValue)
        PositionAction.timingMode = .easeOut
        self.pointOfView?.runAction(PositionAction)
        
        let RotationAction = SCNAction.rotateTo(x: 0.0, y: 0.0, z: 0.0, duration: Defaults.ResetCameraAnimationDuration.rawValue)
        RotationAction.timingMode = .easeOut
        self.pointOfView?.runAction(RotationAction)
        {
            self.pointOfView?.constraints = []
        }
    }
}
