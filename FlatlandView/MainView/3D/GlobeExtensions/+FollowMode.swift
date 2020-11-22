//
//  +FollowMode.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/5/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension GlobeView
{
    // MARK: - Mouse follow mode
    
    /// Sets the follow mode flag.
    /// - Parameter DoEnable: The value to set the view's mouse follow mode flag.
    func EnableFollowMode(_ DoEnable: Bool)
    {
        InFollowMode = DoEnable
        if InFollowMode
        {
            FollowModeNode = MakeFollowNode()
        }
        else
        {
            FollowModeNode?.removeAllAnimations()
            FollowModeNode?.removeAllActions()
            FollowModeNode?.removeFromParentNode()
        }
    }
    
    /// Create the shape to indicate the mouse location when in mouse follow mode.
    /// - Returns: A shape that indicates the mouse location over the main displayed node.
    func MakeFollowNode() -> SCNNode2
    {
        let Top = SCNCone(topRadius: 0.0, bottomRadius: 0.5, height: 1.5)
        let TopNode = SCNNode2(geometry: Top)
        TopNode.geometry?.firstMaterial?.diffuse.contents = NSColor.yellow
        TopNode.position = SCNVector3(0.0, 0.0, 1.5)
        let Bottom = SCNCone(topRadius: 0.5, bottomRadius: 0.0, height: 1.5)
        let BottomNode = SCNNode2(geometry: Bottom)
        BottomNode.geometry?.firstMaterial?.diffuse.contents = NSColor.orange
        let Follow = SCNNode2()
        Follow.addChildNode(TopNode)
        Follow.addChildNode(BottomNode)
        return Follow
    }
}
