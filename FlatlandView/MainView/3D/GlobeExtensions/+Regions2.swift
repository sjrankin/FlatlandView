//
//  +Regions2.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/17/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit
import CoreGraphics

extension GlobeView
{
    // MARK: - Region plotting functions.
    
    /// Remove all regions from the region layer.
    func RemoveRegions2()
    {
        if let Node = RegionNode
        {
            RegionLayer = nil
            InitializeRegionNode(Node)
        }
    }
    
    /// Initialize the region node. This is the spherical node on which earthquake regions (or
    /// any other region) are rendered.
    /// - Important: The `blendMode` **must** be set to `.alpha` (and the `blendMode` of the EarthNode
    ///              set to `.replace`) in order for the blending to work correctly.
    /// - Parameter Node: The node to initialize.
    func InitializeRegionNode(_ Node: SCNNode2)
    {
        RegionLayer = CAShapeLayer()
        RegionLayer?.name = GlobeNodeNames.RegionNode.rawValue
        RegionLayer?.isGeometryFlipped = true
        RegionLayer?.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 3600, height: 1800))
        RegionLayer?.backgroundColor = NSColor.clear.cgColor
        Node.geometry?.firstMaterial?.diffuse.contents = RegionLayer
        Node.geometry?.firstMaterial?.blendMode = .alpha
    }
    
    /// Plot all regions on the region layer.
    /// - Note: For now, only earthquake regions are displayed.
    func PlotRegions2()
    {
        if RegionNode == nil
        {
            let RegionNodeShape = SCNSphere(radius: GlobeRadius.RegionLayer.rawValue)
            RegionNodeShape.segmentCount = 500
            RegionNode = SCNNode2(geometry: RegionNodeShape)
            RegionNode?.name = GlobeNodeNames.RegionNode.rawValue
            RegionNode?.position = SCNVector3(0.0, 0.0, 0.0)
            RegionNode?.castsShadow = false
            InitializeRegionNode(RegionNode!)
            EarthNode?.addChildNode(RegionNode!)
        }
        else
        {
            RemoveRegions2()
        }
        let QuakeRegions = Settings.GetEarthquakeRegions()
        for Region in QuakeRegions
        {
            if Region.IsFallback
            {
                continue
            }
            PlotRegion2(Region)
        }
    }
    
    /// Convert the passed point to a coordinate in a rectangle whose dimensions are passed.
    /// - Parameter Point: The point to convert.
    /// - Parameter Width: The width of the target rectangle. Defaults to `3600`.
    /// - Parameter Height: The height of the target rectangle. Defaults to `1800`.
    /// - Returns: Point with the equivalent location in the virtual passed rectangle for the
    ///            geographical point in `Point`.
    func ConvertRegionPoint(_ Point: GeoPoint, Width: Int = 3600, Height: Int = 1800) -> NSPoint
    {
        var WLat = Point.Latitude
        if WLat >= 0.0
        {
            WLat = 90.0 - WLat
        }
        else
        {
            WLat = 90.0 + abs(WLat)
        }
        let LatPercent = WLat / 180.0
        let FinalY = LatPercent * Double(Height)
        
        var WLon = Point.Longitude
        WLon = WLon + 180.0
        let LonPercent = WLon / 360.0
        let FinalX = LonPercent * Double(Width)
        
        return NSPoint(x: FinalX, y: FinalY)
    }
    
    /// Plot a region on the region layer.
    /// - Parameter Region: The region to plot.
    func PlotRegion2(_ Region: UserRegion)
    {
        let RegionBox = CAShapeLayer()
        RegionBox.borderWidth = 1.0
        RegionBox.borderColor = NSColor.black.withAlphaComponent(0.5).cgColor
        RegionBox.backgroundColor = Region.RegionColor.withAlphaComponent(0.5).cgColor
        let UpperLeft = ConvertRegionPoint(Region.UpperLeft)
        let LowerRight = ConvertRegionPoint(Region.LowerRight)
        let Size = CGSize(width: abs(LowerRight.x - UpperLeft.x), height: abs(LowerRight.y - UpperLeft.y))
        RegionBox.frame = CGRect(origin: UpperLeft, size: Size)
        RegionLayer?.addSublayer(RegionBox)
    }
}
