//
//  +RectangleNodeHandling.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension RectangleView
{
    // MARK: - Primary object creation.
    
    func AddEarth()
    {
        let Flat = SCNBox(width: CGFloat(RectMode.MapWidth.rawValue), height: CGFloat(RectMode.MapDepth.rawValue),
                          length: CGFloat(RectMode.MapHeight.rawValue), chamferRadius: 0.0)
        FlatEarthNode = SCNNode2(geometry: Flat)
        FlatEarthNode.categoryBitMask = LightMasks2D.Sun.rawValue | LightMasks2D.Polar.rawValue
        var Image: NSImage!
        var IntensityMultiplier = 1.0
        let MapType = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
        let MapViewType = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Rectangular)
        if let SavedImage = MapManager.ImageFor(MapType: MapType, ViewType: MapViewType)
        {
            IntensityMultiplier = MapManager.GetLightMulitplier(MapType: MapType)
            Image = SavedImage
        }
        else
        {
            IntensityMultiplier = MapManager.GetLightMulitplier(MapType: .SimplePoliticalMap1)
            Image = NSImage(named: "SimplePoliticalWorldMap")
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
    
    /// Add the grid layer. Grid "lines" are all 3D shapes generated on the fly.
    func AddGridLayer()
    {
        let Flat = SCNBox(width: CGFloat(RectMode.MapWidth.rawValue), height: CGFloat(RectMode.MapHeight.rawValue),
         length: CGFloat(RectMode.MapDepth.rawValue), chamferRadius: 0.0)
        GridNode = SCNNode2(geometry: Flat)
        GridNode.castsShadow = false
        GridNode.categoryBitMask = LightMasks2D.Grid.rawValue
        GridNode.geometry?.firstMaterial?.diffuse.contents = NSColor.clear
        GridNode.position = SCNVector3(0.0, 0.0, 0.0)
        self.scene?.rootNode.addChildNode(GridNode)
        PopulateGrid()
    }
    
    /// Add grid "lines" to the grid layer.
    func PopulateGrid()
    {
        for Node in GridNode.childNodes
        {
            Node.removeFromParentNode()
            Node.geometry = nil
        }
        let HalfHeight: CGFloat = CGFloat(RectMode.MapHeight.rawValue / 2.0)
        let EquatorLocation = HalfHeight - CGFloat(RectMode.MapHeight.rawValue / 2.0)
        let CancerLocation = HalfHeight - CGFloat(RectMode.MapHeight.rawValue) * ((90.0 + 23.4366) / 180.0)
        let CapricornLocation = HalfHeight - CGFloat(RectMode.MapHeight.rawValue) * ((90.0 - 23.4366) / 180.0)
        let ArcticLocation = HalfHeight - CGFloat(RectMode.MapHeight.rawValue * (90.0 + 66.56) / 180.0)
        let AntarcticLocation = HalfHeight - CGFloat(RectMode.MapHeight.rawValue * (90.0 - 66.56) / 180.0)
        let EqLine = MakeHorizontalLine(At: EquatorLocation, Width: CGFloat(RectMode.MapWidth.rawValue))
        let CanLine = MakeHorizontalLine(At: CancerLocation, Width: CGFloat(RectMode.MapWidth.rawValue))
        let CapLine = MakeHorizontalLine(At: CapricornLocation, Width: CGFloat(RectMode.MapWidth.rawValue))
        let ArLine = MakeHorizontalLine(At: ArcticLocation, Width: CGFloat(RectMode.MapWidth.rawValue))
        let AnLine = MakeHorizontalLine(At: AntarcticLocation, Width: CGFloat(RectMode.MapWidth.rawValue))
        GridNode.addChildNode(EqLine)
        GridNode.addChildNode(CanLine)
        GridNode.addChildNode(CapLine)
        GridNode.addChildNode(ArLine)
        GridNode.addChildNode(AnLine)
        let HalfWidth = CGFloat(RectMode.MapWidth.rawValue / 2.0)
        let PrimeMeridian = MakeVerticalLine(At: HalfWidth - CGFloat(RectMode.MapWidth.rawValue / 2.0),
                                             Height: CGFloat(RectMode.MapHeight.rawValue))
        GridNode.addChildNode(PrimeMeridian)
        let AntiPrimeMeridian0 = MakeVerticalLine(At: -HalfWidth, Height: CGFloat(RectMode.MapHeight.rawValue))
        let AntiPrimeMeridian1 = MakeVerticalLine(At: CGFloat(RectMode.MapWidth.rawValue) - HalfWidth,
                                                  Height: CGFloat(RectMode.MapHeight.rawValue))
        GridNode.addChildNode(AntiPrimeMeridian0)
        GridNode.addChildNode(AntiPrimeMeridian1)
    }
    
    /// Create a vertical line at the specified horizontal position.
    /// - Parameter At: The horizontal position where the vertical line will be drawn.
    /// - Parameter Height: The height of the vertical line.
    /// - Returns: A long and skinny box that functions as a line.
    func MakeVerticalLine(At: CGFloat, Height: CGFloat) -> SCNNode
    {
        let LineShape = SCNBox(width: CGFloat(RectMode.LineWidth.rawValue),
                               height: Height,
                               length: CGFloat(RectMode.LineWidth.rawValue),
                               chamferRadius: 0.0)
        let LineNode = SCNNode2(geometry: LineShape)
        LineNode.categoryBitMask = LightMasks2D.Grid.rawValue
        LineNode.castsShadow = false
        LineNode.name = NodeNames2D.GridNodes.rawValue
        LineNode.geometry?.firstMaterial?.diffuse.contents = NSColor.systemTeal//Settings.GetColor(.GridLineColor, NSColor.black)
        var FinalX = At
        if At < CGFloat(-RectMode.MapWidth.rawValue / 2.0)
        {
            FinalX = CGFloat(-RectMode.MapWidth.rawValue / 2.0)
        }
        if At > CGFloat(RectMode.MapWidth.rawValue / 2.0)
        {
            FinalX = CGFloat(RectMode.MapWidth.rawValue / 2.0) - At
        }
        LineNode.position = SCNVector3(FinalX, 0.0, 0.0)
        return LineNode
    }
    
    /// Create a horizontal line at the specified vertical position.
    /// - Parameter At: The vertical position where the horizontal line will be drawn.
    /// - Parameter Height: The width of the horizontal line.
    /// - Returns: A long and skinny box that functions as a line.
    func MakeHorizontalLine(At: CGFloat, Width: CGFloat) -> SCNNode
    {
        let LineShape = SCNBox(width: Width,
                               height: CGFloat(RectMode.LineWidth.rawValue),
                               length: CGFloat(RectMode.LineWidth.rawValue),
                               chamferRadius: 0.0)
        let LineNode = SCNNode2(geometry: LineShape)
        LineNode.categoryBitMask = LightMasks2D.Grid.rawValue
        LineNode.name = NodeNames2D.GridNodes.rawValue
        LineNode.castsShadow = false
        LineNode.geometry?.firstMaterial?.diffuse.contents = Settings.GetColor(.GridLineColor, NSColor.black)
        LineNode.position = SCNVector3(0.0, At, 0.0)
        return LineNode
    }
    
    /// Creates a shape to be used to hold the night mask.
    func AddNightMaskLayer()
    {
        let light = SCNLight()
        light.intensity = 1000
        light.color = NSColor.white
        light.categoryBitMask = LightMasks2D.NightMask.rawValue
        let ln = SCNNode2()
        ln.light = light
        ln.position = SCNVector3(0.0,0.0,30.0)
        self.scene?.rootNode.addChildNode(ln)
        #if true
        let Flat = SCNPlane(width: CGFloat(RectMode.MapWidth.rawValue), height: CGFloat(RectMode.MapHeight.rawValue))
        #else
        let Flat = SCNBox(width: CGFloat(RectMode.MapWidth.rawValue), height: CGFloat(RectMode.MapHeight.rawValue),
                          length: CGFloat(RectMode.MapDepth.rawValue), chamferRadius: 0.0)
        #endif
        RectNightMaskNode = SCNNode2(geometry: Flat)
        RectNightMaskNode.categoryBitMask = LightMasks2D.NightMask.rawValue
        RectNightMaskNode.castsShadow = false
        RectNightMaskNode.name = "NIGHT MASK PLANE"
        RectNightMaskNode.geometry?.firstMaterial?.diffuse.contents = nil
        RectNightMaskNode.position = SCNVector3(0.0, 0.0, 0.03)
        self.scene?.rootNode.addChildNode(RectNightMaskNode)
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
        if let Mask = Utility.GetRectangularNightMask(ForDate: Date())
        {
            let ImageTiff = Mask.tiffRepresentation
            var CImage = CIImage(data: ImageTiff!)
            let Transform = CGAffineTransform(scaleX: -1, y: 1)
            CImage = CImage?.transformed(by: Transform)
            let CImageRep = NSCIImageRep(ciImage: CImage!)
            let Final = NSImage(size: CImageRep.size)
            Final.addRepresentation(CImageRep)
            NightMaskImage = Final
            AdjustNightMask(With: GetPercentTimeUTC())
        }
    }
    
    /// Adjusts the night mask to the passed percent.
    /// - Note: If the passed percent is the same as the previously passed percent, no action is taken.
    /// - Parameter With: The time percent for solar noon.
    func AdjustNightMask(With Percent: Double)
    {
        if Settings.GetBool(.ShowNight)
        {
            if let SourceImage = NightMaskImage
            {
                if let Previous = PreviousNightMaskValue
                {
                    if Previous == Percent
                    {
                        return
                    }
                }
                PreviousNightMaskValue = Percent
                let Width = Double(SourceImage.size.width)
                let ShiftAmount = Width * Percent
                print("ShiftAmount=\(ShiftAmount)")
                let ShiftedImage = SourceImage.HorizontalShift(By: Int(ShiftAmount))
                RectNightMaskNode.geometry?.firstMaterial?.diffuse.contents = ShiftedImage
            }
        }
    }
    
    #if false
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
        NightMaskImage = Final
        AdjustNightMask(With: GetPercentTimeUTC())
        //RectNightMaskNode.geometry?.firstMaterial?.diffuse.contents = Final
    }
    #endif
    
    /// Hide the night mask.
    func HideNightMask()
    {
        RectNightMaskNode.geometry?.firstMaterial?.diffuse.contents = nil
    }
    
    /// Create the World Heritage Layer.
    func AddHeritageLayer()
    {
        let Flat = SCNBox(width: CGFloat(RectMode.MapWidth.rawValue), height: CGFloat(RectMode.MapDepth.rawValue),
                          length: CGFloat(RectMode.MapHeight.rawValue), chamferRadius: 0.0)
        UNESCOPlane = SCNNode2(geometry: Flat)
        UNESCOPlane.categoryBitMask = LightMasks3D.Sun.rawValue
        UNESCOPlane.name = NodeNames2D.WorldHeritageSite.rawValue
        UNESCOPlane.geometry?.firstMaterial?.diffuse.contents = NSColor.clear
        UNESCOPlane.geometry?.firstMaterial?.isDoubleSided = true
        UNESCOPlane.scale = SCNVector3(1.0, 1.0, 1.0)
        UNESCOPlane.eulerAngles = SCNVector3(90.0.Radians, 180.0.Radians, 0.0.Radians)
        UNESCOPlane.position = SCNVector3(0.0, 0.0, 0.0)
        self.scene?.rootNode.addChildNode(UNESCOPlane)
    }
}
