//
//  +FlatViewNodeHandling.swift
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
    // MARK: - Primary object creation.
    
    /// Add the node for the Earth. In this case, the visible part of the node is the top of a cylinder
    /// since textures map well to "flat" circles there.
    func AddEarth()
    {
        let Flat = SCNCylinder(radius: CGFloat(FlatConstants.FlatRadius.rawValue),
                               height: CGFloat(FlatConstants.FlatThickness.rawValue))
        Flat.radialSegmentCount = Int(FlatConstants.FlatSegments.rawValue)
        FlatEarthNode = SCNNode(geometry: Flat)
        FlatEarthNode.categoryBitMask = LightMasks2D.Sun.rawValue
        let Image = NSImage(named: "SimplePoliticalWorldMapSouthCenter")
        SetEarthMap(Image!)
        FlatEarthNode.geometry?.firstMaterial?.lightingModel = .lambert
        FlatEarthNode.position = SCNVector3(0.0, 0.0, 0.0)
        FlatEarthNode.eulerAngles = SCNVector3(90.0.Radians, 180.0.Radians, 0.0)
        self.scene?.rootNode.addChildNode(FlatEarthNode)
    }
    
    /// Add the grid layer. Grid "lines" are all 3D shapes generated on the fly.
    func AddGridLayer()
    {
        let Flat = SCNCylinder(radius: CGFloat(FlatConstants.FlatRadius.rawValue),
                               height: CGFloat(FlatConstants.GridLayerThickness.rawValue))
        Flat.radialSegmentCount = Int(FlatConstants.FlatSegments.rawValue)
        GridNode = SCNNode(geometry: Flat)
        GridNode.castsShadow = false
        GridNode.categoryBitMask = LightMasks2D.Grid.rawValue
        GridNode.geometry?.firstMaterial?.diffuse.contents = NSColor.clear
        GridNode.position = SCNVector3(0.0, 0.0, 0.0)
        GridNode.eulerAngles = SCNVector3(90.0.Radians, 180.0.Radians, 90.0.Radians)
        self.scene?.rootNode.addChildNode(GridNode)
        PopulateGrid()
    }
    
    /// Add grid "lines" to the grid layer.
    func PopulateGrid()
    {
        for Node in GridNode.childNodes
        {
            Node.removeFromParentNode()
        }
        let EquatorLocation = CGFloat(FlatConstants.FlatRadius.rawValue) / 2.0
        let CancerLocation = (CGFloat(FlatConstants.FlatRadius.rawValue) * (90.0 + 23.4366) / 180.0)
        let CapricornLocation = (CGFloat(FlatConstants.FlatRadius.rawValue) * (90.0 - 23.4366) / 180.0)
        let ArcticLocation = CGFloat(FlatConstants.FlatRadius.rawValue * (90.0 + 66.56) / 180.0)
        let AntarcticLocation = CGFloat(FlatConstants.FlatRadius.rawValue * (90.0 - 66.56) / 180.0)
        let Equator = MakeRing(Radius: EquatorLocation)
        let CancerRing = MakeRing(Radius: CancerLocation)
        let CapricornRing = MakeRing(Radius: CapricornLocation)
        let ArcticRing = MakeRing(Radius: ArcticLocation)
        let AntarcticRing = MakeRing(Radius: AntarcticLocation)
        GridNode.addChildNode(Equator)
        GridNode.addChildNode(CancerRing)
        GridNode.addChildNode(CapricornRing)
        GridNode.addChildNode(ArcticRing)
        GridNode.addChildNode(AntarcticRing)
        let Center = CGFloat(FlatConstants.FlatRadius.rawValue / 2.0)
        let VLine = MakeVerticalLine(At: Center, Height: CGFloat(FlatConstants.FlatRadius.rawValue * 2.0))
        let HLine = MakeHorizontalLine(At: Center, Width: CGFloat(FlatConstants.FlatRadius.rawValue * 2.0))
        GridNode.addChildNode(VLine)
        GridNode.addChildNode(HLine)
    }
    
    /// Create a vertical line at the specified horizontal position.
    /// - Parameter At: The horizontal position where the vertical line will be drawn.
    /// - Parameter Height: The height of the vertical line.
    /// - Returns: A long and skinny box that functions as a line.
    func MakeVerticalLine(At: CGFloat, Height: CGFloat) -> SCNNode
    {
        let LineShape = SCNBox(width: Height, height: 0.1, length: 0.1, chamferRadius: 0.0)
        let LineNode = SCNNode(geometry: LineShape)
        LineNode.categoryBitMask = LightMasks2D.Grid.rawValue
        LineNode.castsShadow = false
        LineNode.name = NodeNames2D.GridNodes.rawValue
        LineNode.geometry?.firstMaterial?.diffuse.contents = Settings.GetColor(.GridLineColor, NSColor.black)
        LineNode.position = SCNVector3(0.0, 0.0, 0.0)
        return LineNode
    }
    
    /// Create a horizontal line at the specified vertical position.
    /// - Parameter At: The vertical position where the horizontal line will be drawn.
    /// - Parameter Height: The width of the horizontal line.
    /// - Returns: A long and skinny box that functions as a line.
    func MakeHorizontalLine(At: CGFloat, Width: CGFloat) -> SCNNode
    {
        let LineShape = SCNBox(width: 0.1, height: 0.1, length: Width, chamferRadius: 0.0)
        let LineNode = SCNNode(geometry: LineShape)
        LineNode.categoryBitMask = LightMasks2D.Grid.rawValue
        LineNode.name = NodeNames2D.GridNodes.rawValue
        LineNode.castsShadow = false
        LineNode.geometry?.firstMaterial?.diffuse.contents = Settings.GetColor(.GridLineColor, NSColor.black)
        LineNode.position = SCNVector3(0.0, 0.0, 0.0)
        return LineNode
    }
    
    /// Create a circle (ring) that is used as a latitude line.
    /// - Parameter Radius: The radius of the ring.
    /// - Returns: A thin ring.
    func MakeRing(Radius: CGFloat) -> SCNNode
    {
        let RingShape = SCNTorus(ringRadius: Radius, pipeRadius: 0.06)
        let RingNode = SCNNode(geometry: RingShape)
        RingNode.categoryBitMask = LightMasks2D.Grid.rawValue
        RingShape.ringSegmentCount = Int(FlatConstants.FlatSegments.rawValue)
        RingShape.pipeSegmentCount = Int(FlatConstants.FlatSegments.rawValue)
        RingNode.name = NodeNames2D.GridNodes.rawValue
        RingNode.castsShadow = false
        RingNode.geometry?.firstMaterial?.diffuse.contents = Settings.GetColor(.GridLineColor, NSColor.black)
        RingNode.position = SCNVector3(0.0, 0.0, 0.0)
        return RingNode
    }
    
    /// Creates a shape to be used to hold the night mask.
    func AddNightMaskLayer()
    {
        let Flat = SCNCylinder(radius: CGFloat(FlatConstants.FlatRadius.rawValue),
                               height: CGFloat(FlatConstants.NightMaskThickness.rawValue))
        Flat.radialSegmentCount = Int(FlatConstants.FlatSegments.rawValue)
        NightMaskNode = SCNNode(geometry: Flat)
        NightMaskNode.categoryBitMask = LightMasks2D.Sun.rawValue
        NightMaskNode.castsShadow = false
        NightMaskNode.geometry?.firstMaterial?.diffuse.contents = nil
        NightMaskNode.position = SCNVector3(0.0, 0.0, 0.0)
        NightMaskNode.eulerAngles = SCNVector3(90.0.Radians, 180.0.Radians, 90.0.Radians)
        self.scene?.rootNode.addChildNode(NightMaskNode)
    }
    
    /// Remove all nodes with the specified name from the scene's root node.
    /// - Parameter Name: The name of the node to remove. *Must match exactly.*
    /// - Parameter FromParent: If not nil, the parent node from which nodes are removed. If nil,
    ///                         nodes are removed from the scene's root node.
    func RemoveNodeWithName(_ Name: String, FromParent: SCNNode? = nil)
    {
        if let Parent = FromParent
        {
            for Node in Parent.childNodes
            {
                if Node.name == Name
                {
                    Node.removeAllActions()
                    Node.removeAllAnimations()
                    Node.removeFromParentNode()
                }
            }
            return
        }
        if let Nodes = self.scene?.rootNode.childNodes
        {
            for Node in Nodes
            {
                if Node.name == Name
                {
                    Node.removeAllActions()
                    Node.removeAllAnimations()
                    Node.removeFromParentNode()
                }
            }
        }
    }
    
    /// Remove the ambient light from the scene.
    func RemoveAmbientLight()
    {
        AmbientLightNode?.removeAllActions()
        AmbientLightNode?.removeFromParentNode()
        AmbientLightNode = nil
    }
    
    /// Adds a night mask to the view. The current date will be used.
    func AddNightMask()
    {
        if let Mask = Utility.GetNightMask(ForDate: Date())
        {
            AddNightMask(Mask)
        }
    }
    
    /// Add the night mask image to the night mask node.
    /// - Parameter Image: The night mask image to add.
    func AddNightMask(_ Image: NSImage)
    {
        let ImageTiff = Image.tiffRepresentation
        var CImage = CIImage(data: ImageTiff!)
        let Transform = CGAffineTransform(scaleX: -1, y: 1)
        CImage = CImage?.transformed(by: Transform)
        let CImageRep = NSCIImageRep(ciImage: CImage!)
        let Final = NSImage(size: CImageRep.size)
        Final.addRepresentation(CImageRep)
        NightMaskNode.geometry?.firstMaterial?.diffuse.contents = Final
    }
    
    /// Hide the night mask.
    func HideNightMask()
    {
        NightMaskNode.geometry?.firstMaterial?.diffuse.contents = nil
    }
    
    func AddHeritageLayer()
    {
    }
}
