//
//  +FlatViewHours.swift
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
    func AddHourLayer()
    {
        let Flat = SCNPlane(width: CGFloat(FlatConstants.HourRadius.rawValue * 2.0),
                            height: CGFloat(FlatConstants.HourRadius.rawValue * 2.0))
        HourPlane = SCNNode(geometry: Flat)
        HourPlane.categoryBitMask = LightMasks3D.Sun.rawValue
        HourPlane.name = NodeNames2D.HourPlane.rawValue
        HourPlane.geometry?.firstMaterial?.diffuse.contents = NSColor.clear
        HourPlane.geometry?.firstMaterial?.isDoubleSided = true
        HourPlane.scale = SCNVector3(1.0, 1.0, 1.0)
        HourPlane.eulerAngles = SCNVector3(180.0.Radians, 180.0.Radians, 180.0.Radians)
        HourPlane.position = SCNVector3(0.0, 0.0, 0.0)
        self.scene?.rootNode.addChildNode(HourPlane)
    }
    
    func AddHours(HourRadius: Double)
    {
        RemoveNodeWithName(NodeNames2D.HourNodes.rawValue, FromParent: HourPlane)
        switch Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self, Default: .None)
        {
            case .None:
                //Nothing to do here since all hours have already been removed.
                break
                
            case .Solar:
                MakeSolarHours(HourRadius: HourRadius)
                
            case .RelativeToNoon:
                MakeNoonRelativeHours(HourRadius: HourRadius)
                
            case .RelativeToLocation:
                MakeRelativetoLocationHours(HourRadius: HourRadius)
        }
    }
    
    func MakeSolarHours(HourRadius: Double)
    {
        //        NodeTables.RemoveHours()
        let MapCenter = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter)
        if MapCenter == .FlatNorthCenter
        {
            //Stride never returns the `to` value (depsite the parameter name - this is by design for some
            //strange reason) so we have to set the terminal value to -1 to get the 0.
            for Hour in stride(from: 23, to: -1, by: -1)
            {
                let Angle = abs(Double(Hour - 23 - 1))
                let HourNode = MakeHour(Hour, AtAngle: Angle, Radius: HourRadius)
                //let HourID = UUID()
                //HourNode.NodeID = HourID
                //NodeTables.AddHour(ID: HourID, Name: "\(Hour)", Description: "Solar relative hour (12 is noon)")
                HourPlane.addChildNode(HourNode)
            }
        }
        else
        {
            for Hour in 0 ... 23
            {
                let HourNode = MakeHour(Hour, AtAngle: Double(Hour), Radius: HourRadius)
                //let HourID = UUID()
                //HourNode.NodeID = HourID
                //NodeTables.AddHour(ID: HourID, Name: "\(Hour)", Description: "Solar relative hour (12 is noon)")
                HourPlane.addChildNode(HourNode)
            }
        }
    }
    
    /// Draws hours relative to noon.
    func MakeNoonRelativeHours(HourRadius: Double)
    {
//        NodeTables.RemoveHours()
        for Hour in 0 ... 23
        {
            var DisplayHour = 24 - (Hour + 5) % 24 - 1
            DisplayHour = DisplayHour - 12
            let HourNode = MakeHour(DisplayHour, AtAngle: Double(DisplayHour + 12), Radius: HourRadius,
                                    AddPrefix: true)
            //let HourID = UUID()
            //HourNode.NodeID = HourID
            //NodeTables.AddHour(ID: HourID, Name: "\(Hour)", Description: "Noon relative hour (0 is noon)")
            HourPlane.addChildNode(HourNode)
        }
    }
    
    func MakeRelativetoLocationHours(HourRadius: Double)
    {
        //        NodeTables.RemoveHours()
        var HourList = [0, -1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
        HourList = HourList.Shift(By: -12)
        if let LocalLongitude = Settings.GetDoubleNil(.LocalLongitude)
        {
            let Long = Int(LocalLongitude / 15.0)
            HourList = HourList.Shift(By: Long)
            for Hour in 0 ... 23
            {
                let DisplayHour = Hour % 24
                let FinalHour = HourList[DisplayHour]
                let HourNode = MakeHour(FinalHour, AtAngle: Double(FinalHour), Radius: HourRadius,
                                        AddPrefix: true)
                //let HourID = UUID()
                //HourNode.NodeID = HourID
                //NodeTables.AddHour(ID: HourID, Name: "\(FinalHour)", Description: "Location relative hour")
                HourPlane.addChildNode(HourNode)
            }
        }
    }
    
    func UpdateHours()
    {
        RemoveNodeWithName(NodeNames2D.HourNodes.rawValue)
        AddHours(HourRadius: FlatConstants.HourRadius.rawValue)
    }
    
    func MakeHour(_ Hour: Int, AtAngle: Double, Radius: Double, Scale: Double = FlatConstants.HourScale.rawValue,
                  AddPrefix: Bool = false) -> SCNNode2
    {
        let MapCenter = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter)
        var Offset = 0.0
        if MapCenter == .FlatSouthCenter
        {
            Offset = 180.0
        }
        var Angle = (AtAngle * 15.0) + Offset
        Angle = fmod(Angle, 360.0)
        var Prefix = ""
        if AddPrefix
        {
            if Hour > 0
            {
                Prefix = "+"
            }
        }
        let HourText = "\(Prefix)\(Hour)"
        let HourShape = SCNText(string: HourText, extrusionDepth: CGFloat(FlatConstants.HourExtrusion.rawValue))
        let FontData = Settings.GetFont(.HourFontName, StoredFont("Avenir-Medium", 20.0, NSColor.yellow))
        HourShape.font = NSFont(name: FontData.PostscriptName, size: 25.0)
        HourShape.flatness = CGFloat(FlatConstants.HourFlatness.rawValue)
        if Settings.GetBool(.UseHourChamfer)
        {
            HourShape.chamferRadius = CGFloat(FlatConstants.HourChamfer.rawValue)
        }
        let Node = SCNNode2(geometry: HourShape)
        Node.NodeClass = UUID(uuidString: NodeClasses.Miscellaneous.rawValue)!
        Node.name = NodeNames2D.HourNodes.rawValue
        Node.categoryBitMask = LightMasks2D.Hours.rawValue//LightMasks2D.Sun.rawValue
        Node.geometry?.firstMaterial?.diffuse.contents = Settings.GetColor(.HourColor, NSColor.systemOrange)
        Node.geometry?.firstMaterial?.specular.contents = NSColor.white
        Node.geometry?.firstMaterial?.lightingModel = .lambert
        let FinalAngle = (Angle - 90.0) * -1
        let Radians = FinalAngle.Radians
        let X = Radius * cos(Radians)
        let Y = Radius * sin(Radians)
        var XDelta = Double(Node.boundingBox.max.x - Node.boundingBox.min.x) / 2.0
        XDelta = XDelta * Scale
        var YDelta = Double(Node.boundingBox.max.y - Node.boundingBox.min.y) / 2.0
        YDelta = YDelta * Scale
        Node.pivot = SCNMatrix4MakeTranslation(CGFloat(XDelta) * 20, 0.0, 0.0)
        Node.position = SCNVector3(X, Y, 0.0)
        let NodeRotation = (FinalAngle - 90.0).Radians
        Node.eulerAngles = SCNVector3(0.0, 0.0, NodeRotation)
        Node.scale = SCNVector3(Scale, Scale, Scale)
        
        return Node
    }
}
