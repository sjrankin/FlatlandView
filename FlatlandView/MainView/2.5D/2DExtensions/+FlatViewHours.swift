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
    /// Add the hour layer. Hours are "drawn" on this plane.
    func AddHourLayer()
    {
        let Flat = SCNPlane(width: CGFloat(FlatConstants.HourRadius.rawValue * 2.0),
                            height: CGFloat(FlatConstants.HourRadius.rawValue * 2.0))
        HourPlane = SCNNode2(geometry: Flat)
        HourPlane.categoryBitMask = LightMasks3D.Sun.rawValue
        HourPlane.name = NodeNames2D.HourPlane.rawValue
        HourPlane.geometry?.firstMaterial?.diffuse.contents = NSColor.clear
        HourPlane.geometry?.firstMaterial?.isDoubleSided = true
        HourPlane.scale = SCNVector3(1.0, 1.0, 1.0)
        HourPlane.eulerAngles = SCNVector3(180.0.Radians, 180.0.Radians, 180.0.Radians)
        HourPlane.position = SCNVector3(0.0, 0.0, 0.0)
        self.scene?.rootNode.addChildNode(HourPlane)
    }
    
    /// Add the hours to the hour layer.
    /// - Parameter HourRadius: Distance from the center of the map to where the hours are drawn.
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
                
            case .WallClock:
                MakeWallClockHours(HourRadius: HourRadius)
        }
    }
    
    /// Update wall clock hours.
    /// - Note: Called periodically when the time changes to keep the various wall clocks in sync with the display.
    /// - Parameter NewTime: The time to use to display wall clocks.
    @objc func UpdateWallClockHours(NewTime: Date)
    {
        let NewWallClockTime = NewTime.PrettyTime(IncludeSeconds: false)
        if LastWallClockTime == nil
        {
            LastWallClockTime = NewWallClockTime
        }
        else
        {
            if LastWallClockTime! == NewWallClockTime
            {
                return
            }
            LastWallClockTime = NewWallClockTime
        }
        
        for Hour in HourPlane.childNodes
        {
            if let Node = Hour as? SCNNode2
            {
                if Node.IsTextNode
                {
                    (Hour as? SCNNode2)?.Clear()
                }
            }
        }

        let MapCenter = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter)
        switch MapCenter
        {
            case .FlatNorthCenter:
                for Hour in 0 ..< 24
                {
                    let LabelAngle: Double = Double(Hour) * 15.0
                    var WorkingAngle = LabelAngle
                    var FHour = Int(WorkingAngle / 15.0)
                    if FHour > 12
                    {
                        FHour = 12 - (FHour - 12)
                        FHour = FHour * -1
                    }
                    FHour = 24 - FHour
                    let UTC = Date().ToUTC()
                    let Cal = Calendar.current
                    let FinalDate = Cal.date(byAdding: .hour, value: FHour, to: UTC)
                    let PrettyTime = Date.PrettyTime(From: FinalDate!, IncludeSeconds: false)
                    WorkingAngle = WorkingAngle - 270.0
                    let HourTextNode = MakeWallHour(WorkingAngle,
                                                    ScaleMultiplier: FlatConstants.HourScale.rawValue * 0.65,
                                                    Value: PrettyTime,
                                                    LetterColor: Settings.GetColor(.HourColor, NSColor.orange),
                                                    NodeTime: FinalDate!,
                                                    Radius: FlatConstants.HourRadius.rawValue)
                    HourPlane.addChildNode(HourTextNode)
                }
                
            case .FlatSouthCenter:
                for Hour in stride(from: 24, to: 0, by: -1)
                {
                    let LabelAngle: Double = Double(Hour) * 15.0
                    var WorkingAngle = LabelAngle
                    var FHour = Int(WorkingAngle / 15.0)
                    if FHour > 12
                    {
                        FHour = 12 - (FHour - 12)
                        FHour = FHour * -1
                    }
                    let UTC = Date().ToUTC()
                    let Cal = Calendar.current
                    let FinalDate = Cal.date(byAdding: .hour, value: FHour, to: UTC)
                    let PrettyTime = Date.PrettyTime(From: FinalDate!, IncludeSeconds: false)
                    WorkingAngle = WorkingAngle - 270.0
                    let HourTextNode = MakeWallHour(WorkingAngle,
                                                    ScaleMultiplier: FlatConstants.HourScale.rawValue * 0.65,
                                                    Value: PrettyTime,
                                                    LetterColor: Settings.GetColor(.HourColor, NSColor.orange),
                                                    NodeTime: FinalDate!,
                                                    Radius: FlatConstants.HourRadius.rawValue)
                    HourPlane.addChildNode(HourTextNode)
                }
                
            default:
                break
        }
    }
    
    /// Draw wall clock hours around the perimeter of the map.
    /// - Parameter HourRadius: Distance from the center of the map to where hours are drawn.
    func MakeWallClockHours(HourRadius: Double)
    {
        UpdateWallClockHours(NewTime: Date())
    }
    
    /// Draw solar hours around the perimeter of the map.
    /// - Parameter HourRadius: Distance from the center of the map to where hours are drawn.
    func MakeSolarHours(HourRadius: Double)
    {
        let MapCenter = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter)
        if MapCenter == .FlatNorthCenter
        {
            //Stride never returns the `to` value so we have to set the terminal value to -1 to get the 0.
            for Hour in stride(from: 23, to: -1, by: -1)
            {
                let Angle = abs(Double(Hour - 23 - 1))
                let HourNode = MakeHour(Hour, AtAngle: Angle, Radius: HourRadius)
                HourPlane.addChildNode(HourNode)
            }
        }
        else
        {
            for Hour in 0 ... 23
            {
                let HourNode = MakeHour(Hour, AtAngle: Double(Hour), Radius: HourRadius)
                HourPlane.addChildNode(HourNode)
            }
        }
    }
    
    /// Draws hours relative to noon.
    /// - Parameter HourRadius: Distance from the center of the map to where hours are drawn.
    func MakeNoonRelativeHours(HourRadius: Double)
    {
        for Hour in 0 ... 23
        {
            var DisplayHour = 24 - (Hour + 5) % 24 - 1
            DisplayHour = DisplayHour - 12
            let HourNode = MakeHour(DisplayHour, AtAngle: Double(DisplayHour + 12), Radius: HourRadius,
                                    AddPrefix: true)
            HourPlane.addChildNode(HourNode)
        }
    }
    
    /// Draw relative hours from home around the perimeter of the map.
    /// - Parameter HourRadius: Distance from the center of the map to where hours are drawn.
    func MakeRelativetoLocationHours(HourRadius: Double)
    {
        var HourList = [0, -1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
        HourList = HourList.Shift(By: -12)
        if let LocalLongitude = Settings.GetDoubleNil(.UserHomeLongitude)
        {
            let Long = Int(LocalLongitude / 15.0)
            HourList = HourList.Shift(By: Long)
            for Hour in 0 ... 23
            {
                let DisplayHour = Hour % 24
                let FinalHour = HourList[DisplayHour]
                let HourNode = MakeHour(FinalHour, AtAngle: Double(FinalHour), Radius: HourRadius,
                                        AddPrefix: true)
                HourPlane.addChildNode(HourNode)
            }
        }
    }
    
    /// Update the displayed hours.
    func UpdateHours()
    {
        RemoveNodeWithName(NodeNames2D.HourNodes.rawValue)
        AddHours(HourRadius: FlatConstants.HourRadius.rawValue)
    }
    
    /// Use the law of cosines to calculate the length of a third segment of a triangle.
    /// - Parameter Side1: Length of first side.
    /// - Parameter Side2: Length of second side.
    /// - Parameter Angle: Angle at point of intersection of first two sides. **Units are degrees.**
    /// - Returns: Length of third side of triangle.
    func LawOfCosines(Side1: Double, Side2: Double, Angle: Double) -> Double
    {
        let FirstTerm = pow(Side1, 2) + pow(Side2, 2)
        let SecondTerm = 2.0 * Side1 * Side2 * cos(Angle.Radians)
        let Side3 = sqrt(FirstTerm - SecondTerm)
        return Side3
    }
    
    func MakeWallClockLine(Angle: Double, HighPoint: SCNVector3, Color: NSColor)
    {
        let LowPoint = SCNVector3(0.0, 0.0, 0.0)
        let V = SCNVector3(HighPoint.x - LowPoint.x, HighPoint.y - LowPoint.y, HighPoint.z - LowPoint.z)
        let Distance = sqrt(V.x * V.x + V.y * V.y + V.z * V.z)
        let Middle = SCNVector3((HighPoint.x + LowPoint.x) / 2,
                                (HighPoint.y + LowPoint.y) / 2,
                                (HighPoint.z + LowPoint.z) / 2)
        let Line = SCNCylinder()
        Line.radius = 0.05
        Line.radius = Distance
        Line.radialSegmentCount = 5
        Line.firstMaterial?.diffuse.contents = NSColor.systemYellow
        let LineNode = SCNNode2(geometry: Line)
        LineNode.categoryBitMask = LightMasks2D.Hours.rawValue
        LineNode.name = "WallClockSeparator"
        LineNode.position = Middle
        LineNode.scale = SCNVector3(0.1)
        LineNode.look(at: LowPoint, up: self.scene!.rootNode.worldUp, localFront: LineNode.worldUp)
        HourPlane.addChildNode(LineNode)
    }
    
    func MakeWallClockSeparator(Angle: Double, HighPoint: NSPoint, Color: NSColor)
    {
        #if false
        let HighVector = SCNVector3(HighPoint.x, 0.0, HighPoint.y)
        MakeWallClockLine(Angle: Angle, HighPoint: HighVector, Color: Color)
        #else
        let Point2 = NSPoint(x: HighPoint.x, y: 0)
        let Point3 = NSPoint.zero
        let Triangle = SCNTriangle(Vertex1: HighPoint,
                                   Vertex2: Point2,
                                   Vertex3: Point3,
                                   Extrusion: 0.01,
                                   Color: Color,
                                   LightMask: LightMasks2D.Hours.rawValue,
                                   UseState: false)
        Triangle.CastsShadow = false
        Triangle.name = "WallClockSeparator"
        Triangle.pivot = SCNMatrix4Identity
        Triangle.eulerAngles = SCNVector3(90.0.Radians, 0.0.Radians, Angle.Radians)
        Triangle.position = SCNVector3(0.0, 0.0, 0.0)
        HourPlane.addChildNode(Triangle)
        #endif
    }
    
    /// Remove wall clock separators from the parent node.
    func RemoveWallClockSeparators()
    {
        for Child in HourPlane.childNodes
        {
            if Child.name == "WallClockSeparator"
            {
                Child.removeAllActions()
                Child.removeAllAnimations()
                Child.removeFromParentNode()
                Child.geometry = nil
            }
        }
    }
    
    /// Create an hour node for wall clock mode.
    /// - Parameter WorkingAngle: The angle to use that determines where the node will be displayed. Units
    ///                           are degrees.
    /// - Parameter ScaleMultiplier: Multiplier for the scale of the text nodes.
    /// - Parameter Value: The string to display as the hour value.
    /// - Parameter LetterColor: The color to use to render the text.
    /// - Parameter NodeTime: The time for the node.
    /// - Parameter Radius: The radial value of the polar coordinate of the location of the text.
    func MakeWallHour(_ WorkingAngle: Double, ScaleMultiplier: Double, Value: String,
                      LetterColor: NSColor = NSColor.systemYellow,
                      NodeTime: Date, Radius: Double) -> SCNNode2
    {
        let HourHeight = 1.0
        let ActualAngle = WorkingAngle + 2.0

        let HourText = MakeWallClockNodeText(With: Value, LetterColor: LetterColor)
        let HourTextNode = SCNNode2(geometry: HourText)
        HourTextNode.name = NodeNames2D.HourNodes.rawValue
        #if false
        var XDelta = Double(HourTextNode.boundingBox.max.x - HourTextNode.boundingBox.min.x) / 2.0
        XDelta = XDelta * ScaleMultiplier
        var YDelta = Double(HourTextNode.boundingBox.max.y - HourTextNode.boundingBox.min.y) / 2.0
        YDelta = YDelta * ScaleMultiplier
        HourTextNode.pivot = SCNMatrix4MakeTranslation(CGFloat(XDelta), 0.0, 0.0)
        #endif
        HourTextNode.HourAngle = ActualAngle
        HourTextNode.IsTextNode = true
        HourTextNode.categoryBitMask = LightMasks2D.Hours.rawValue
        HourTextNode.scale = SCNVector3(ScaleMultiplier)
        let FinalAngle = (ActualAngle - 90.0) * -1
        let Radians = FinalAngle.Radians
        let FinalRadius = Radius * 1.02
        let X = FinalRadius * cos(Radians)
        let Y = FinalRadius * sin(Radians)
        HourTextNode.position = SCNVector3(X, Y, HourHeight)
        #if true
        let NodeRotation = FinalAngle.Radians
        #else
        var NodeRotation = FinalAngle.Radians
        if WorkingAngle > 180.0
        {
            NodeRotation = (FinalAngle + 180.0).Radians
        }
        #endif
        HourTextNode.eulerAngles = SCNVector3(0.0, 0.0, NodeRotation)
        /*
        if Settings.GetBool(.ShowWallClockSeparators)
        {
            MakeWallClockSeparator(Angle: WorkingAngle - 7.5,
                                   HighPoint: NSPoint(x: Radius + 1.0, y: HourHeight),
                                   Color: NSColor.yellow.withAlphaComponent(0.5))
        }
 */
        return HourTextNode
    }
    
    /// Create text for a wall clock node.
    /// - Parameter With: The text to use for the returned `SCNText` shape.
    /// - Parameter LetterColor: The color of the diffuse surface.
    /// - Returns: `SCNText` with the shape as controlled by the value of `With`.
    func MakeWallClockNodeText(With Text: String, LetterColor: NSColor = NSColor.yellow) -> SCNText
    {
        let FlatnessValue: CGFloat = CGFloat(HourConstants.NormalFlatness.rawValue)
        let HourText = SCNText(string: Text, extrusionDepth: CGFloat(HourConstants.HourExtrusion.rawValue * 2.0))
        let Font = NSFont.GetFont(InOrder: ["Avenir-Bold", "HelveticaNeue-Bold", "ArialMT"], Size: 25.0)
        HourText.font = Font
        HourText.firstMaterial?.diffuse.contents = LetterColor
        HourText.firstMaterial?.specular.contents = NSColor.systemPink
        HourText.flatness = FlatnessValue
        return HourText
    }
    
    /// Create a node with an hour value.
    /// - Parameter Hour: The house value to display.
    /// - Parameter HourLabel: If present, the string to use for the hour label. If `nil`, `Hour` is used.
    ///                        Defaults to `nil`.
    /// - Parameter Angle: The angle at which the hour is displayed.
    /// - Parameter Radius: The radius away from the center of the map.
    /// - Parameter Scale: The scale to use for the labels. Defaults to `FlatConstants.HourScale`.
    /// - Parameter AddPrefix: If true, a sign prefix is used for the `Hour` value. Ignored if `HourLabel` is
    ///                        not nil. Defaults to `false`.
    /// - Parameter RadiateLabel: If true, the label radiates away from the center of the map. Otherwise, it
    ///                           is tangent to the edge of the map.
    func MakeHour(_ Hour: Int, _ HourLabel: String? = nil, AtAngle: Double, Radius: Double,
                  Scale: Double = FlatConstants.HourScale.rawValue, AddPrefix: Bool = false,
                  RadiateLabel: Bool = false) -> SCNNode2
    {
        let MapCenter = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter)
        var Offset = 0.0
        if MapCenter == .FlatSouthCenter
        {
            Offset = 180.0
        }
        var Angle = (AtAngle * 15.0) + Offset
        Angle = fmod(Angle, 360.0)
        var HourText = ""
        if let Label = HourLabel
        {
            HourText = Label
        }
        else
        {
            var Prefix = ""
            if AddPrefix
            {
                if Hour > 0
                {
                    Prefix = "+"
                }
            }
            HourText = "\(Prefix)\(Hour)"
        }
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
        Node.categoryBitMask = LightMasks2D.Hours.rawValue
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
        var NodeRotation: Double = 0.0
        if RadiateLabel
        {
            NodeRotation = FinalAngle.Radians
        }
        else
        {
            NodeRotation = (FinalAngle - 90.0).Radians
        }
        Node.eulerAngles = SCNVector3(0.0, 0.0, NodeRotation)
        Node.scale = SCNVector3(Scale)
        
        return Node
    }
    
    /// Highlight the hours in sequence.
    /// - Parameter Count: Number of cycles to flash the hours.
    func FlashHoursInSequence(Count: Int)
    {
        if Count < 1
        {
            return
        }
        let ExecutionCount = Count < 1 ? 1 : Count
        DoFlashHours(InSequence: true, RepeatCount: ExecutionCount)
    }
    
    /// Flash all of the hours the specified number of times.
    /// - Parameter Count: The number of times to flash the hours.
    func FlashAllHours(Count: Int)
    {
        if Count < 1
        {
            return
        }
        let ExecutionCount = Count < 1 ? 1 : Count
        DoFlashHours(InSequence: false, RepeatCount: ExecutionCount)
    }
    
    /// Highlight the hours in sequence.
    func DoFlashHours(InSequence: Bool, RepeatCount: Int = 0)
    {
        var Index = 0
        let DelayMultiplier: Double = InSequence ? 1.0 : 0.0
        for Node in HourPlane.childNodes
        {
            if let HourLabel = Node as? SCNNode2
            {
                if HourLabel.IsTextNode
                {
                    var FirstColor = NSColor.green
                    if HourLabel.IsInDaylight
                    {
                        FirstColor = NSColor(RGB: Colors3D.HourColor.rawValue)
                    }
                    else
                    {
                        FirstColor = NSColor(RGB: Colors3D.GlowingHourColor.rawValue)
                    }
                    let Action = SCNAction.customAction(duration: HourConstants.FlashHourDuration.rawValue)
                    {
                        (Node, Time) in
                        let Percent = Time / CGFloat(HourConstants.FlashHourDuration.rawValue)
                        let NewColor = NSColor.yellow.Interpolate2(FirstColor, Percent)
                        if let ActualNode = Node as? SCNNode2
                        {
                            if ActualNode.IsInDaylight
                            {
                                ActualNode.geometry?.firstMaterial?.diffuse.contents = NewColor
                            }
                            else
                            {
                                ActualNode.geometry?.firstMaterial?.emission.contents = NewColor
                            }
                        }
                    }
                    let DelayDuration = HourConstants.FlashHourDelay.rawValue * Double(Index) * DelayMultiplier
                    let Delay = SCNAction.wait(duration: DelayDuration)
                    let Group = SCNAction.sequence([Delay, Action])
                    let Repeat = SCNAction.repeat(Group, count: RepeatCount)
                    HourLabel.runAction(Repeat)
                    Index = Index + 1
                }
            }
        }
    }
}
