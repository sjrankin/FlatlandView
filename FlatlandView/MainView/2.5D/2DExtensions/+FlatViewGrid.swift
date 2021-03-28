//
//  +FlatViewGrid.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/25/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension FlatView
{
    // MARK: Grid handling.
    
    /// Removes the grid layer from the 2D view.
    func RemoveGridLayer()
    {
        for Child in self.scene!.rootNode.childNodes
        {
            if Child.name == NodeNames2D.GridLayer.rawValue
            {
                Child.removeAllActions()
                Child.removeAllAnimations()
                Child.removeFromParentNode()
                Child.geometry = nil
                return
            }
        }
    }
    
    /// Add the grid layer. Grid "lines" are all 3D shapes generated on the fly.
    func AddGridLayer()
    {
        RemoveGridLayer()
        var Stencil = StencilGrid()
        Stencil = StencilCities(On: Stencil)
        let Flat = SCNCylinder(radius: CGFloat(FlatConstants.FlatRadius.rawValue),
                               height: CGFloat(FlatConstants.GridLayerThickness.rawValue))
        Flat.radialSegmentCount = Int(FlatConstants.FlatSegments.rawValue)
        GridNode = SCNNode2(geometry: Flat)
        GridNode.castsShadow = false
        GridNode.name = NodeNames2D.GridLayer.rawValue
        GridNode.categoryBitMask = LightMasks2D.Grid.rawValue
        GridNode.geometry?.firstMaterial?.diffuse.contents = Stencil
        GridNode.geometry?.firstMaterial?.emission.contents = Stencil
        GridNode.position = SCNVector3(0.0, 0.0, 0.0)
        GridNode.eulerAngles = SCNVector3(90.0.Radians, 180.0.Radians, 90.0.Radians)
        self.scene?.rootNode.addChildNode(GridNode)
    }
}
