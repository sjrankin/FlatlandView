//
//  +Camera.swift
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
    // MARK: - Code to move the camera around.
    
    /// Spin the camera 1° for every `Duration` seconds
    func SpinCamera(Duration: Double = 0.05)
    {
        let Spinning = SCNAction.rotateBy(x: 0.0,
                                          y: 0.0,
                                          z: CGFloat(1.0.Radians),
                                          duration: Duration)
        let SpinForever = SCNAction.repeatForever(Spinning)
        self.pointOfView?.runAction(SpinForever)
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
            self.UpdateFlatnessForCamera(Distance: CGFloat(Defaults.InitialZ.rawValue))
            self.UpdateCityFlatnessForCamera(Distance: CGFloat(Defaults.InitialZ.rawValue))
        }
    }
    
    /// Rotate the camera to the specified location over the globe.
    /// - Parameter Latitude: The latitude of the location.
    /// - Parameter Longitude: The longitude of the location.
    func RotateCameraTo(Latitude: Double, Longitude: Double)
    {
    }
    
    /// Rotate the camera in place without move it.
    /// - Parameter Pitch: The pitch (X axis) value.
    /// - Parameter Yaw: The yaw (Y axis) value.
    /// - Parameter Roll: The roll (Z axis) value.
    /// - Parameter ValuesAreRadians: If true, the passed values are radians. If false, the passed values
    ///                               are degrees and will be converted to radians.
    /// - Parameter Duration: Duration of the animation in seconds.
    func RotateCameraInPlace(Pitch X: Double, Yaw Y: Double, Roll Z: Double, ValuesAreRadians: Bool,
                             Duration: Double)
    {
        let XRotate = CGFloat(ValuesAreRadians ? X : X.Radians)
        let YRotate = CGFloat(ValuesAreRadians ? Y : Y.Radians)
        let ZRotate = CGFloat(ValuesAreRadians ? Z : Z.Radians)
//        self.pointOfView?.eulerAngles = SCNVector3(XRotate, YRotate, ZRotate)
        let OrientCamera = SCNAction.rotateTo(x: XRotate, y: YRotate, z: ZRotate, duration: Duration)
        self.pointOfView?.runAction(OrientCamera)
    }
    
    // MARK: - Camera manipulation functions.
    
    /// Move the camera such that it is pointing at the passed point.
    /// - Parameter At: The geographic coordinates to point the camera at.
    /// - Paraemter Duration: Duration of the animation in seconds.
    func PointCamera(At Point: GeoPoint, Duration: Double)
    {
        #if false
        Debug.Print("Pointing camera to \(Point)")
        let (X, Y, Z) = ToECEF(Point.Latitude, Point.Longitude, Radius: Double(Defaults.InitialZ.rawValue))
        let MoveCamera = SCNAction.move(to: SCNVector3(X, Y, Z), duration: 2.0)
        self.pointOfView?.runAction(MoveCamera)
        let XRotate = CGFloat(90.0.Radians)
        let YRotate = CGFloat(90.0.Radians)
        let ZRotate = CGFloat(-Point.Longitude.Radians)
        let OrientCamera = SCNAction.rotateTo(x: XRotate, y: YRotate, z: ZRotate, duration: Duration)
        self.pointOfView?.runAction(OrientCamera)
        #else
        Debug.Print("Pointing camera to \(Point)")
        let (X, Y, Z) = ToECEF(Point.Latitude, Point.Longitude, Radius: Double(Defaults.InitialZ.rawValue))
        let Constraint = SCNLookAtConstraint(target: EarthNode!)
        Constraint.isGimbalLockEnabled = true
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 2.0
        self.pointOfView?.constraints = [Constraint]
        SCNTransaction.commit()
        let MoveCamera = SCNAction.move(to: SCNVector3(X, Y, Z), duration: Duration)
        self.pointOfView?.runAction(MoveCamera)
        {
            Constraint.isGimbalLockEnabled = false
            self.pointOfView?.constraints = []
        }
        #if false
        let XRotate = CGFloat(0.0.Radians)
        let YRotate = CGFloat(0.0.Radians)
        let ZRotate = CGFloat(-Point.Longitude.Radians)
        let OrientCamera = SCNAction.rotateTo(x: XRotate, y: YRotate, z: ZRotate, duration: Duration)
        self.pointOfView?.runAction(OrientCamera)
            {
            self.pointOfView?.constraints = []
        }
        #endif
        #endif
    }
    
    /// Reset the camera to its standard position based on the time.
    func ResetCameraPosition()
    {
        ResetCamera()
    }
    
    /// Set the camera orientation.
    /// - Parameter Pitch: The pitch (X) value.
    /// - Parameter Yaw: The yaw (Y) value.
    /// - Parameter Roll: The roll (Z) value.
    /// - Parameter ValuesAreRadians: If true, the values in `Pitch`, `Yaw`, and `Roll` are radians. If
    ///                               false, the values are degrees.
    /// - Parameter Duration: Duration of the animation in seconds.
    func SetCameraOrientation(Pitch: Double, Yaw: Double, Roll: Double, ValuesAreRadians: Bool, Duration: Double)
    {
        let FinalX = CGFloat(ValuesAreRadians ? Pitch : Pitch.Radians)
        let FinalY = CGFloat(ValuesAreRadians ? Yaw : Yaw.Radians)
        let FinalZ = CGFloat(ValuesAreRadians ? Roll : Roll.Radians)
        let RotateCamera = SCNAction.rotateBy(x: FinalX, y: FinalY, z: FinalZ, duration: Duration)
        pointOfView?.runAction(RotateCamera)
    }
    
    // MARK: - Code to implement camera control.
    
    /// Update the current camera based on the contents of the user settings.
    /// - Warning: Not currently available.
    func UpdateFlatlandCamera()
    {
        #if false
        if Settings.GetBool(.UseSystemCameraControl)
        {
            return
        }
        if FlatlandCamera == nil
        {
            print("FlatlandCamera is nil")
        }
        let NewFOV = Settings.GetCGFloat(.CameraFieldOfView)
        let NewOrthoScale = Settings.GetDouble(.CameraOrthographicScale)
        let NewProjection = Settings.GetEnum(ForKey: .CameraProjection, EnumType: CameraProjections.self, Default: .Perspective)
        if NewProjection == .Orthographic
        {
            FlatlandCamera?.usesOrthographicProjection = true
            FlatlandCamera?.orthographicScale = NewOrthoScale
            FlatlandCamera?.fieldOfView = NewFOV
        }
        else
        {
            FlatlandCamera?.usesOrthographicProjection = false
            FlatlandCamera?.fieldOfView = NewFOV
        }
        #endif
    }
    
    /// Reset the camera to its default settings.
    /// - Warning: Not currently available.
    /// - Parameter Completed: Closure called once the camera is reset.
    func ResetFlatlandCamera(_ Completed: ((Bool) -> ())? = nil)
    {
        #if false
        if Settings.GetBool(.UseSystemCameraControl)
        {
            Completed?(false)
            return
        }
        let ResetAngles = SCNAction.rotateTo(x: 0.0, y: 0.0, z: 0.0,
                                             duration: 1.5, usesShortestUnitArc: true)
        let ResetPosition = SCNAction.move(to: SCNVector3(0.0, 0.0, 15.0),
                                           duration: 1.5)
        SystemNode?.runAction(ResetAngles)
        FlatlandCameraNode?.runAction(ResetPosition)
        {
            Completed?(true)
        }
        #endif
    }
    
    /// Initialize the camera.
    /// - Warning: Not currently available.
    /// - Parameter UseFlatland: If true, the Flatland camera is used. If false, the built-in camera is used.
    func InitializeSceneCamera(_ UseFlatland: Bool)
    {
        #if false
        print("UseFlatlandCamera(\(UseFlatland))")
        if UseFlatland
        {
            self.allowsCameraControl = false
            RemoveNodeWithName(GlobeNodeNames.BuiltInCameraNode.rawValue)
            FlatlandCamera = SCNCamera()
            FlatlandCamera?.fieldOfView = Settings.GetCGFloat(.CameraFieldOfView, 90.0)
            FlatlandCamera?.zFar = Settings.GetDouble(.ZFar, 1000.0)
            FlatlandCamera?.zNear = Settings.GetDouble(.ZNear, 0.1)
            FlatlandCameraNode = SCNNode()
            FlatlandCameraNode?.camera = FlatlandCamera
            FlatlandCameraNode?.position = Settings.GetVector(.InitialCameraPosition, SCNVector3(0.0, 0.0, 175.0))
            self.scene?.rootNode.addChildNode(FlatlandCameraNode!)
        }
        else
        {
            CreateCamera()
            self.allowsCameraControl = true
        }
        #endif
    }
    
    /// Handle mouse scroll wheel change events.
    /// - Warning: Not currently available.
    /// - Parameter DeltaX: The horizontal delta of the scroll wheel.
    /// - Parameter DeltaY: The vertical delta of the scroll wheel.
    /// - Parameter Option: If true, the user held the option key when scrolling.
    func HandleMouseScrollWheelChanged(DeltaX: Int, DeltaY: Int, Option: Bool)
    {
        #if false
        let CameraX = FlatlandCameraNode?.position.x
        let CameraY = FlatlandCameraNode?.position.y
        let CameraZ = FlatlandCameraNode?.position.z
        if Option
        {
            if Settings.GetBool(.EnableZooming)
            {
                let NewZ = CameraZ! + CGFloat(DeltaY)
                FlatlandCameraNode?.position = SCNVector3(CameraX!, CameraY!, NewZ)
            }
        }
        else
        {
            if Settings.GetBool(.EnableMoving)
            {
                FlatlandCameraNode?.position = SCNVector3(CameraX! + CGFloat(-DeltaX),
                                                          CameraY! + CGFloat(DeltaY),
                                                          CameraZ!)
            }
        }
        #endif
    }
    
    /// Handle mouse dragging events.
    /// - Warning: Not currently available.
    /// - Parameter DeltaX: The change in the mouse's horizontal position.
    /// - Parameter DeltaY: The change in the mouse's vertical position.
    func HandleMouseDragged(DeltaX: Int, DeltaY: Int)
    {
        #if false
        if Settings.GetBool(.EnableDragging)
        {
            if let Euler = SystemNode?.eulerAngles
            {
                if DeltaX != 0
                {
                    let Yaw = Euler.y + (CGFloat(DeltaX) * CGFloat.pi / 180.0)
                    SystemNode?.eulerAngles = SCNVector3(Euler.x, Yaw, Euler.z)
                }
                if DeltaY != 0
                {
                    let Pitch = Euler.x + (CGFloat(DeltaY) * CGFloat.pi / 180.0)
                    SystemNode?.eulerAngles = SCNVector3(Pitch, Euler.y, Euler.z)
                }
            }
        }
        #endif
    }
}
