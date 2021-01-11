//
//  +Regions.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/10/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension GlobeView
{
    func RemoveRegions()
    {
        NodeTables.RemoveRegion()
        RemoveNodeWithName(GlobeNodeNames.RegionNode.rawValue)
    }
    
    func PlotRegions()
    {
        #if false
        RemoveRegions()
        let QuakeRegions = Settings.GetEarthquakeRegions()
        for Region in QuakeRegions
        {
            if Region.IsFallback
            {
                continue
            }
            PlotRegion(Region)
        }
        #endif
    }
    
    func PlotRegion(_ Region: UserRegion)
    {
        var RegionNode = SCNNode2()
        RegionNode.name = GlobeNodeNames.RegionNode.rawValue
        RegionNode.NodeID = Region.ID
        RegionNode.EditID = UUID(uuidString: "a70f71ca-1fa6-43eb-8fa1-dcae38011ed2")!
        RegionNode.NodeClass = UUID(uuidString: NodeClasses.Region.rawValue)!
        if Region.IsRectangular
        {
            var ActualWidth = Geometry.HaversineDistance(Latitude1: Region.UpperLeft.Latitude,
                                                         Longitude1: Region.UpperLeft.Longitude,
                                                         Latitude2: Region.UpperLeft.Latitude,
                                                         Longitude2: Region.LowerRight.Longitude)
            ActualWidth = (ActualWidth / 1000.0).RoundedTo(2)
            var ActualHeight = Geometry.HaversineDistance(Latitude1: Region.UpperLeft.Latitude,
                                                          Longitude1: Region.LowerRight.Longitude,
                                                          Latitude2: Region.LowerRight.Latitude,
                                                          Longitude2: Region.LowerRight.Longitude)
            ActualHeight = (ActualHeight / 1000.0).RoundedTo(2)
            let Ratio = Double(GlobeRadius.Primary.rawValue) / PhysicalConstants.EarthRadius.rawValue
            let MapWidth = ActualWidth * Ratio
            let MapHeight = ActualHeight * Ratio
            let Plane = SCNBox(width: CGFloat(MapWidth), height: 0.1, length: CGFloat(MapHeight), chamferRadius: 0.0)
            Plane.firstMaterial?.diffuse.contents = Region.RegionColor.withAlphaComponent(0.5)
            RegionNode.geometry = Plane
            #if true
            let HalfLat = (Region.UpperLeft.Latitude + Region.LowerRight.Latitude) / 2.0
            let HalfLon = (Region.UpperLeft.Longitude + Region.LowerRight.Longitude) / 2.0
            RegionNode.SetLocation(HalfLat, HalfLon)
            let (X, Y, Z) = ToECEF(HalfLat, HalfLon, Radius: Double(GlobeRadius.Primary.rawValue))
            #else
            let (X, Y, Z) = ToECEF(Region.UpperLeft.Latitude, Region.UpperLeft.Longitude,
                                   Radius: Double(GlobeRadius.Primary.rawValue))
            #endif
            RegionNode.position = SCNVector3(X, Y, Z)
            RegionNode.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
            let XRotation = (HalfLat - 180.0).Radians
            let YRotation = HalfLon.Radians
            let ZRotation = 0.0.Radians
            RegionNode.eulerAngles = SCNVector3(XRotation, YRotation, ZRotation)
            EarthNode?.addChildNode(RegionNode)
        }
        else
        {
            
        }
    }
}
