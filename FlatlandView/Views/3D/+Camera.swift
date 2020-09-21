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
