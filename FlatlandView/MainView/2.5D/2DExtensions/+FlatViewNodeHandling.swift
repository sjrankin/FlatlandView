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
        FlatEarthNode = SCNNode2(geometry: Flat)
        FlatEarthNode.categoryBitMask = LightMasks2D.Sun.rawValue | LightMasks2D.Polar.rawValue
        var Image: NSImage!
        var IntensityMultiplier = 1.0
        let MapType = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
        let MapViewType = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatNorthCenter)
        if let SavedImage = MapManager.ImageFor(MapType: MapType, ViewType: MapViewType)
        {
            IntensityMultiplier = MapManager.GetLightMulitplier(MapType: MapType)
            Image = SavedImage
        }
        else
        {
            IntensityMultiplier = MapManager.GetLightMulitplier(MapType: .SimplePoliticalMap1)
            Image = NSImage(named: "SimplePoliticalWorldMapSouthCenter")
        }
        SetEarthMap(Image!)
        PrimaryLightMultiplier = IntensityMultiplier
        UpdatePolarLight(With: PrimaryLightMultiplier)
        FlatEarthNode.geometry?.firstMaterial?.lightingModel = .lambert
        FlatEarthNode.position = SCNVector3(0.0, 0.0, 0.0)
        FlatEarthNode.eulerAngles = SCNVector3(90.0.Radians, 180.0.Radians, 0.0)
        FlatEarthNode.name = "Flat Earth"
        self.scene?.rootNode.addChildNode(FlatEarthNode)
    }
    
    /// Creates a shape to be used to hold the night mask.
    func AddNightMaskLayer()
    {
        let Flat = SCNCylinder(radius: CGFloat(FlatConstants.FlatRadius.rawValue),
                               height: CGFloat(FlatConstants.NightMaskThickness.rawValue))
        Flat.radialSegmentCount = Int(FlatConstants.FlatSegments.rawValue)
        NightMaskNode = SCNNode2(geometry: Flat)
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
                    Node.geometry = nil
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
                    Node.geometry = nil
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
    
    /// Create the World Heritage Layer.
    func AddHeritageLayer()
    {
        let Flat = SCNPlane(width: CGFloat(FlatConstants.FlatRadius.rawValue * 2.0),
                            height: CGFloat(FlatConstants.FlatRadius.rawValue * 2.0))
        UNESCOPlane = SCNNode2(geometry: Flat)
        UNESCOPlane.categoryBitMask = LightMasks3D.Sun.rawValue
        UNESCOPlane.name = NodeNames2D.WorldHeritageSite.rawValue
        UNESCOPlane.geometry?.firstMaterial?.diffuse.contents = NSColor.clear
        UNESCOPlane.geometry?.firstMaterial?.isDoubleSided = true
        UNESCOPlane.scale = SCNVector3(1.0, 1.0, 1.0)
        UNESCOPlane.eulerAngles = SCNVector3(180.0.Radians, 180.0.Radians, 180.0.Radians)
        UNESCOPlane.position = SCNVector3(0.0, 0.0, 0.0)
        self.scene?.rootNode.addChildNode(UNESCOPlane)
    }
    
    func AddFollowPlane()
    {
        let Flat = SCNCylinder(radius: CGFloat(FlatConstants.FlatRadius.rawValue),
                               height: CGFloat(FlatConstants.FlatThickness.rawValue))
        Flat.radialSegmentCount = Int(FlatConstants.FlatSegments.rawValue)
        FollowPlane = SCNNode2(geometry: Flat)
        FollowPlane?.categoryBitMask = LightMasks2D.Sun.rawValue | LightMasks2D.Polar.rawValue
        FollowPlane?.position = SCNVector3(0.0, 0.0, 0.01)
        FollowPlane?.eulerAngles = SCNVector3(90.0.Radians, 180.0.Radians, 0.0)
        FollowPlane?.name = NodeNames2D.FollowPlane.rawValue
        FollowPlane?.geometry?.firstMaterial?.diffuse.contents = NSColor.clear
        self.scene?.rootNode.addChildNode(FollowPlane!)
    }
}
