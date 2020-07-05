//
//  +UserCamera.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/5/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

/// Extension methods for `GlobeView` to implement our own camera control (due to limitations of the built-in
/// camera control).
extension GlobeView
{
    /// Create the user camera.
    /// - Parameter At: The initial location of the camera. Defaults to `SCNVector3(0.0, 0.0, 16.0)`.
    func CreateUserCamera(At Position: SCNVector3 = SCNVector3(0.0, 0.0, 16.0))
    {
        UserCamera = SCNCamera()
        UserCamera?.wantsHDR = Settings.GetBool(.UseHDRCamera)
        UserCamera?.fieldOfView = CGFloat(Settings.GetDouble(.FieldOfView, 90.0))
        UserCamera?.usesOrthographicProjection = true
        UserCamera?.orthographicScale = Settings.GetDouble(.OrthographicScale, 14.0)
        UserCamera?.zFar = 500
        UserCamera?.zNear = 0.1
        UserCameraNode = SCNNode()
        UserCameraNode?.camera = UserCamera
        UserCameraNode?.position = Position
        UserCameraLocation = Position
        UserCameraNode?.name = GlobeNodeNames.UserCameraNode.rawValue
        UserCameraNode?.look(at: SCNVector3(0.0, 0.0, 0.0))
        self.scene?.rootNode.addChildNode(UserCameraNode!)
    }
    
    /// Update the user camera with presumably new user-changeable settings.
    func UpdateUserCamera()
    {
        if self.scene == nil
        {
            return
        }
        for Node in self.scene!.rootNode.childNodes
        {
            if Node.name == GlobeNodeNames.UserCameraNode.rawValue
            {
                Node.camera?.wantsHDR = Settings.GetBool(.UseHDRCamera)
                Node.camera?.fieldOfView = CGFloat(Settings.GetDouble(.FieldOfView, 90.0))
                Node.camera?.orthographicScale = Settings.GetDouble(.OrthographicScale, 14.0)
            }
        }
    }
    
    /// Move the user camera to the passed location.
    /// - Parameter To: The new position for the camera.
    /// - Parameter Duration: The duration of the animation to use to move the camera. If `0.0`, no
    ///                       animation is performed and the camera is moved immediately.
    func MoveCamera(To Position: SCNVector3, Duration: Double = 0.0)
    {
        //print("New camera position: \(Position)")
        if Duration == 0.0
        {
            UserCameraNode?.position = Position
            UserCameraLocation = Position
        }
        else
        {
            let Move = SCNAction.move(to: Position, duration: Duration)
            UserCameraNode?.runAction(Move)
            {
                self.UserCameraLocation = Position
            }
        }
    }
    
    func SpinDownDragging(LastEvent: NSEvent, PreviousEvent: NSEvent)
    {
    }
    
    // MARK: - Mouse event handling.
    
    override func scrollWheel(with event: NSEvent)
    {
        super.scrollWheel(with: event)
        //print("Mouse scrolling: Y: \(event.scrollingDeltaY), X: \(event.scrollingDeltaX)")
    }
    
    /// When the user pressed the left mouse button, clear previous mouse locations and stop any ongoing
    /// camera animation.
    override func mouseDown(with event: NSEvent)
    {
        super.mouseDown(with: event)
        UserCameraNode?.removeAllActions()
        MouseLocations.Clear()
        MouseLocations.Enqueue(event)
    }
    
    /// When the user released the left mouse button, spin down the animation of the Earth's motion unless
    /// there are not enough previous mouse locations to use.
    override func mouseUp(with event: NSEvent)
    {
        super.mouseUp(with: event)
        if MouseLocations.Count <= 1
        {
            return
        }
        //Need to spin down the motion of the Earth along its last vector.
        let Last = MouseLocations.Dequeue()
        let Previous = MouseLocations.Dequeue()
        SpinDownDragging(LastEvent: Last!, PreviousEvent: Previous!)
    }
    
    /// When the mouse is dragged, drag the camera with it. Accumulate locations to be used for when the user
    /// stops dragging the mouse.
    override func mouseDragged(with event: NSEvent)
    {
        super.mouseDragged(with: event)
        let dx = event.deltaX
        let dy = event.deltaY
        let dz = event.deltaZ
        //print("Left mouse dragged: \(dx),\(dy),\(dz)")
        MouseLocations.Enqueue(event)
        let NewPosition = SCNVector3(UserCameraLocation.x + dx,
                                     UserCameraLocation.y + dy,
                                     UserCameraLocation.z + dz)
        MoveCamera(To: NewPosition)
    }
}
