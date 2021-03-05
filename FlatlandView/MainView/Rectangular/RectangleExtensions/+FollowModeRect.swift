//
//  +FollowModeRect.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/5/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension RectangleView
{
    func EnableFollowMode(_ DoEnable: Bool)
    {
        InFollowMode = DoEnable
        if InFollowMode
        {
            FollowModeNode = MakeFollowNode()
            MainDelegate?.ShowMouseLocationView(true)
        }
        else
        {
            FollowModeNode?.removeAllAnimations()
            FollowModeNode?.removeAllActions()
            FollowModeNode?.removeFromParentNode()
            FollowModeNode?.geometry = nil
            MainDelegate?.ShowMouseLocationView(false)
        }
    }
    
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
