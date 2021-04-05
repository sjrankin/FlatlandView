//
//  +NewCamera.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/5/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension GlobeView
{
    func CreateGlobeCamera()
    {
        self.allowsCameraControl = false
        AnchorNode = SCNNode2()
        AnchorNode?.position = SCNVector3(0.0, 0.0, 0.0)
        AnchorNode?.name = "Camera Anchor Node"
        self.scene?.rootNode.addChildNode(AnchorNode!)
        let YRotate: CGFloat = 0.0//CGFloat(90.0 + Sun.Declination(For: Date()))
        AnchorNode?.eulerAngles = SCNVector3(0.0, YRotate.Radians, 0.0)
        
        GlobeCamera = SCNCamera()
        GlobeCamera?.fieldOfView = 10.0//Settings.GetCGFloat(.CameraFieldOfView, Defaults.FieldOfView)
        GlobeCamera?.zFar = Settings.GetDouble(.ZFar, Defaults.ZFar)
        GlobeCamera?.zNear = Settings.GetDouble(.ZNear, Defaults.ZNear)
        GlobeCamera?.wantsHDR = Settings.GetBool(.UseHDRCamera)
        
        GlobeCameraNode = SCNNode()
        GlobeCameraNode?.name = "Globe Camera Node"
        GlobeCameraNode?.camera = GlobeCamera
        let InitialLocation = Settings.GetVector(.InitialCameraPosition, SCNVector3(0.0, 0.0, 175.0))
        GlobeCameraNode?.position = InitialLocation
        AnchorNode?.addChildNode(GlobeCameraNode!)
        /*
        AnchorNode?.eulerAngles = SCNVector3(0.0, 0.0, CGFloat(90.0.Radians))
        
        let XRotate = CGFloat(0.0)// CGFloat(Double.random(in: 1.0 ... 15.0).Radians)
        let YRotate =  CGFloat(Double.random(in: 7.0 ... 29.0).Radians)
        let ZRotate = CGFloat(0.0)// CGFloat(Double.random(in: 5.0 ... 30.0).Radians)
        let Rotate = SCNAction.rotateBy(x: XRotate, y: YRotate, z: ZRotate, duration: 1.0)
        let RotateForever = SCNAction.repeatForever(Rotate)
        AnchorNode?.runAction(RotateForever)
 */
    }
}
