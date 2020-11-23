//
//  Rectangle.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/22/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

class Rectangle: MapScene, MapSceneProtocol
{
    // MARK: - MapSceneProtocol functions
    
    func SetMapImage(_ Image: NSImage)
    {
    }
    
    func PlotObject(_ Object: SCNNode2, Latitude: Double, Longitude: Double)
    {
    }
    
    func PlotObject(_ Object: SCNNode2, X: Double, Y: Double)
    {
    }
    
    func PlottedObjects() -> [SCNNode2]
    {
        return [SCNNode2]()
    }
    
    func RemoveObject(ID: UUID)
    {
    }
    
    func RemoveObjectClass(ID: UUID)
    {
        
    }
    
    func SetMapTime(_ Percent: Double)
    {
    }
    
    func Hide(_ Duration: Double)
    {
        let HideAnimation = SCNAction.fadeOut(duration: Duration)
        self.rootNode.runAction(HideAnimation)
        {
            self.rootNode.opacity = 0.0
        }
    }
    
    func Show(_ Duration: Double)
    {
        let ShowAnimation = SCNAction.fadeIn(duration: Duration)
        self.rootNode.runAction(ShowAnimation)
        {
            self.rootNode.opacity = 1.0
        }
    }
}
