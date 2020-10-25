//
//  +RectangleWorldHeritageSizes.swift
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
    /// Plot World Heritage Sites.
    func PlotWorldHeritageSites()
    {
        for Node in WHSNodeList
        {
            Node.removeFromParentNode()
        }
        WHSNodeList.removeAll()
        if Settings.GetBool(.ShowWorldHeritageSites)
        {
            let TypeFilter = Settings.GetEnum(ForKey: .WorldHeritageSiteType, EnumType: SiteTypeFilters.self,
                                              Default: .Either)
            let Sites = MainController.GetAllSites()
            var FinalList = [WorldHeritageSite2]()
            for Site in Sites
            {
                switch TypeFilter
                {
                    case .Either:
                        FinalList.append(Site)
                        
                    case .Both:
                        if Site.Category == "Mixed"
                        {
                            FinalList.append(Site)
                        }
                        
                    case .Natural:
                        if Site.Category == "Natural"
                        {
                            FinalList.append(Site)
                        }
                        
                    case .Cultural:
                        if Site.Category == "Cultural"
                        {
                            FinalList.append(Site)
                        }
                }
            }
            for Site in FinalList
            {
                var DepthOffset: CGFloat = 0.0
                switch Site.Category
                {
                    case "Mixed":
                        DepthOffset = 0.0
                        
                    case "Cultural":
                        DepthOffset = 0.025
                        
                    case "Natural":
                        DepthOffset = 0.05
                        
                    default:
                        DepthOffset = 0.0
                }
                var NodeColor = NSColor.black
                switch Site.Category
                {
                    case "Mixed":
                        NodeColor = NSColor.magenta
                        
                    case "Natural":
                        NodeColor = NSColor.green
                        
                    case "Cultural":
                        NodeColor = NSColor.red
                        
                    default:
                        NodeColor = NSColor.white
                }
                let SiteNode = PlotSiteAsTriangle(Latitude: Site.Latitude,
                                                  Longitude: Site.Longitude,
                                                  Radius: FlatConstants.FlatRadius.rawValue,
                                                  DepthOffset: DepthOffset,
                                                  WithColor: NodeColor)
                SiteNode.NodeID = Site.RuntimeID
                SiteNode.name = NodeNames2D.WorldHeritageSite.rawValue
                SiteNode.NodeClass = UUID(uuidString: NodeClasses.WorldHeritageSite.rawValue)!
                UNESCOPlane.addChildNode(SiteNode)
            }
        }
    }
    
    /// Plot a World Heritage Site as a triangle.
    /// - Parameter Latitude: Latitude of the site.
    /// - Parameter Longitude: Longitude of the site.
    /// - Parameter Radius: Radius of the 2D map.
    /// - Parameter DepthOffset: Value to add to the depth.
    /// - Parameter WithColor: The color to use as the material for the node.
    /// - Returns: Node to use for plotting World Heritage Sites.
    func PlotSiteAsTriangle(Latitude: Double, Longitude: Double, Radius: Double, DepthOffset: CGFloat, WithColor: NSColor) -> SCNNode2
    {
        let SiteShape = SCNRegular.Geometry(VertexCount: 3,
                                            Radius: CGFloat(FlatConstants.WHSRadius.rawValue),
                                            Depth: CGFloat(FlatConstants.WHSDepth.rawValue) + DepthOffset)
        let SiteNode = SCNNode2(geometry: SiteShape)
        SiteNode.categoryBitMask = LightMasks2D.Sun.rawValue | LightMasks2D.Polar.rawValue
        WHSNodeList.append(SiteNode)
        SiteNode.geometry?.firstMaterial?.diffuse.contents = WithColor
        SiteNode.geometry?.firstMaterial?.specular.contents = NSColor.white
        SiteNode.castsShadow = true
        
        let BearingOffset = FlatConstants.InitialBearingOffset.rawValue
        var LongitudeAdjustment = -1.0
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .FlatSouthCenter
        {
            LongitudeAdjustment = 1.0
        }
        var Distance = Utility.DistanceFromContextPole(To: GeoPoint(Latitude, Longitude))
        let Ratio = Radius / PhysicalConstants.HalfEarthCircumference.rawValue
        Distance = Distance * Ratio
        var LocationBearing = Utility.Bearing(Start: GeoPoint(90.0, 0.0), End: GeoPoint(Latitude, Longitude * LongitudeAdjustment))
        LocationBearing = (LocationBearing + 90.0 + BearingOffset).ToRadians()
        let PointX = Distance * cos(LocationBearing)
        let PointY = Distance * sin(LocationBearing)
        let PointZ = Double(NodeScales2D.WorldHeritageSiteScale.rawValue * 1.0 * 0.5)
        SiteNode.position = SCNVector3(PointX, PointY, PointZ)//Double(DepthOffset))
        SiteNode.eulerAngles = SCNVector3(180.0.Radians, 0.0, 0.0)
        return SiteNode
    }
    
    /// Remove World Heritage Sites.
    func HideWorldHeritageSites()
    {
        RemoveNodeWithName(NodeNames2D.WorldHeritageSite.rawValue, FromParent: UNESCOPlane)
    }
}