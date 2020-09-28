//
//  +FlatViewWorldHeritageSites.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/28/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension FlatView
{
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
            print("UNESCO TypeFilter\(TypeFilter)")
            MainView.InitializeWorldHeritageSites()
            let Sites = MainView.GetAllSites()
            var FinalList = [WorldHeritageSite]()
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
                let (X, Y, _) = Utility.ToECEF(Site.Latitude, Site.Longitude, Radius: FlatConstants.FlatRadius.rawValue)
                var DepthOffset: CGFloat = 0.0
                switch Site.Category
                {
                    case "Mixed":
                        DepthOffset = -0.05
                        
                    case "Cultural":
                        DepthOffset = 0.0
                        
                    case "Natural":
                        DepthOffset = 0.05
                        
                    default:
                        DepthOffset = -0.08
                }
                let SiteShape = SCNRegular.Geometry(VertexCount: 3, Radius: 0.2, Depth: 0.1 + DepthOffset)
                let SiteNode = SCNNode2(geometry: SiteShape)
                SiteNode.NodeClass = UUID(uuidString: NodeClasses.WorldHeritageSite.rawValue)!
                SiteNode.NodeID = Site.InternalID
                SiteNode.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                SiteNode.scale = SCNVector3(NodeScales3D.UnescoScale.rawValue,
                                            NodeScales3D.UnescoScale.rawValue,
                                            NodeScales3D.UnescoScale.rawValue)
                WHSNodeList.append(SiteNode)
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
                SiteNode.geometry?.firstMaterial?.diffuse.contents = NodeColor
                SiteNode.geometry?.firstMaterial?.specular.contents = NSColor.white
                SiteNode.castsShadow = true
                SiteNode.position = SCNVector3(X, Y, 0.0)
                let YRotation = Site.Latitude
                let XRotation = Site.Longitude + 180.0
                SiteNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, 0.0)
                UNESCOPlane.addChildNode(SiteNode)
            }
        }
    }
    
    func HideWorldHeritageSites()
    {
        RemoveNodeWithName(NodeNames2D.WorldHeritageSite.rawValue, FromParent: UNESCOPlane)
    }
}
