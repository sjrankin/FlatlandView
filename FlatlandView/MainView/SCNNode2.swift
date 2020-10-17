//
//  File.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

/// Thin wrapper around `SCNNode` that provides a few auxiliary properties for carrying data and ID information.
class SCNNode2: SCNNode
{
    /// Default initializer.
    override init()
    {
        super.init()
    }
    
    /// Initializer.
    /// - Parameter Tag: The tag value.
    init(Tag: Any?)
    {
        super.init()
        self.Tag = Tag
    }
    
    /// Initializer.
    /// - Parameter Tag: The tag value.
    /// - Parameter NodeID: The node's ID. Assumed to be unique.
    /// - Parameter NodeClass: The node class ID. Assumed to be non-unique.
    init(Tag: Any? = nil, NodeID: UUID, NodeClass: UUID)
    {
        super.init()
        self.Tag = Tag
        self.NodeID = NodeID
        self.NodeClass = NodeClass
    }
    
    /// Initializer.
    /// - Parameter geometry: The geometry of the node.
    init(geometry: SCNGeometry?)
    {
        super.init()
        self.geometry = geometry
    }
    
    /// Initializer.
    /// - Parameter geometry: The geometry of the node.
    /// - Parameter Tag: The tag value.
    init(geometry: SCNGeometry?, Tag: Any?)
    {
        super.init()
        self.geometry = geometry
        self.Tag = Tag
    }
    
    /// Initializer.
    /// - Parameter geometry: The geometry of the node.
    /// - Parameter Tag: The tag value.
    /// - Parameter NodeID: The node's ID. Assumed to be unique.
    /// - Parameter NodeClass: The node class ID. Assumed to be non-unique.
    init(geometry: SCNGeometry?, Tag: Any? = nil, NodeID: UUID, NodeClass: UUID)
    {
        super.init()
        self.geometry = geometry
        self.Tag = Tag
        self.NodeID = NodeID
        self.NodeClass = NodeClass
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    /// Initializer.
    /// - Parameter From: The `SCNNode` whose data is used to initialize the `SCNNode2`
    ///                   instance.
    init(From: SCNNode)
    {
        super.init()
        self.geometry = From.geometry
        self.scale = From.scale
        self.position = From.position
        self.eulerAngles = From.eulerAngles
        self.categoryBitMask = From.categoryBitMask
    }
    
    /// Initializer.
    /// - Parameter AsChild: `SCNNode` instance that will be added as a child to the
    ///             `SCNNode2` instance.
    init(AsChild: SCNNode)
    {
        super.init()
        self.addChildNode(AsChild)
    }
    
    /// Tag value. Defaults to nil.
    var Tag: Any? = nil
    
    /// Node class ID. Defaults to nil.
    var NodeClass: UUID? = nil
    
    /// Node ID. Defaults to nil.
    var NodeID: UUID? = nil
    
    /// Propagate the parent's IDs to its children.
    func PropagateIDs()
    {
        for Child in self.childNodes
        {
            if let TheChild = Child as? SCNNode2
            {
                TheChild.NodeClass = NodeClass
                TheChild.NodeID = NodeID
            }
        }
    }
    
    // MARK: - Bounding shapes.
    
    var _CanShowBoundingShape: Bool = true
    {
        didSet
        {
            if !_CanShowBoundingShape
            {
                HideBoundingSphere()
                HideBoundingBox()
            }
        }
    }
    /// Determines whether bounding shape can be shown. If set to true, bounding shapes can be shown with a
    /// call to `ShowBoundingShape`. If set to false, bounding boxes are not shown and if a bounding shape is
    /// currently showing, it is hidden.
    var CanShowBoundingShape: Bool
    {
        get
        {
            return _CanShowBoundingShape
        }
        set
        {
            _CanShowBoundingShape = newValue
        }
    }
    
    /// Draw a bounding box around the node.
    /// - Note: Bounding boxes do not cast shadows.
    /// - Note: The caller _must_ set `RotateOnX`, `RotateOnY` and/or `RotateOnZ` before calling
    ///         this function if there are any changes to default behavior desired.
    /// - Parameter LineColor: The line color of the bounding box. Defaults to `NSColor.red`.
    /// - Parameter RotateBox: If true, the box rotates. If false, no rotation occurs. Defaults to `true`.
    /// - Parameter RotationDuration: The time in seconds to rotate the bounding box. Ignored if `RotateBox`
    ///                               is false.
    /// - Parameter LineThickness: The thickness of the lines making up the bounding box. Scaling the parent
    ///                            `SCNNode2` will affect the visual thickness of the bounding box lines.
    ///                            Defaults to `0.005`.
    private func ShowBoundingBox(LineColor: NSColor = NSColor.red,
                         RotateBox: Bool = true,
                         RotationDuration: Double = 3.0,
                         LineThickness: CGFloat = 0.005)
    {
        if !CanShowBoundingShape
        {
            return
        }
        #if true
        let Radius = self.boundingSphere.radius * 1.12
        let BoxShape = SCNBox(width: CGFloat(Radius * 2),
                              height: CGFloat(Radius * 2),
                              length: CGFloat(Radius * 2),
                              chamferRadius: 0.0)
        BoxShape.firstMaterial?.diffuse.contents = LineColor
        BoxShape.firstMaterial?.fillMode = .lines
        BoxShape.firstMaterial?.emission.contents = LineColor
        BoxNode = SCNNode(geometry: BoxShape)
        BoxNode.position = self.boundingSphere.center
        BoxNode.castsShadow = false
        if RotateBox
        {
            let XMultiplier = RotateOnX ? 1.0 : 0.0
            let YMultiplier = RotateOnY ? 1.0 : 0.0
            let ZMultiplier = RotateOnZ ? 1.0 : 0.0
            let Rotation = SCNAction.rotateBy(x: CGFloat(90.0.Radians * XMultiplier),
                                              y: CGFloat(90.0.Radians * YMultiplier),
                                              z: CGFloat(90.0.Radians * ZMultiplier),
                                              duration: RotationDuration)
            let RotateForever = SCNAction.repeatForever(Rotation)
            BoxNode.runAction(RotateForever)
        }
        self.addChildNode(BoxNode)
        #else
        let (BoxMin, BoxMax) = self.boundingBox
        _ShowingBoundingShape = true
        let Point1 = SCNVector3(BoxMin.x, BoxMin.y, BoxMin.z)
        let Point2 = SCNVector3(BoxMin.x, BoxMax.y, BoxMin.z)
        let Point3 = SCNVector3(BoxMax.x, BoxMax.y, BoxMin.z)
        let Point4 = SCNVector3(BoxMax.x, BoxMin.y, BoxMin.z)
        let Point5 = SCNVector3(BoxMin.x, BoxMin.y, BoxMax.z)
        let Point6 = SCNVector3(BoxMin.x, BoxMax.y, BoxMax.z)
        let Point7 = SCNVector3(BoxMax.x, BoxMax.y, BoxMax.z)
        let Point8 = SCNVector3(BoxMax.x, BoxMin.y, BoxMax.z)
        let Line1 = BoundingBoxLine(Start: Point1, End: Point2, Color: LineColor, LineThickness: LineThickness)
        let Line2 = BoundingBoxLine(Start: Point2, End: Point3, Color: LineColor, RotateZ: 90.0, LineThickness: LineThickness)
        let Line3 = BoundingBoxLine(Start: Point3, End: Point4, Color: LineColor, LineThickness: LineThickness)
        let Line4 = BoundingBoxLine(Start: Point4, End: Point1, Color: LineColor, RotateZ: 90.0, LineThickness: LineThickness)
        let Line5 = BoundingBoxLine(Start: Point5, End: Point6, Color: LineColor, RotateY: 90.0, LineThickness: LineThickness)
        let Line6 = BoundingBoxLine(Start: Point6, End: Point7, Color: LineColor, RotateZ: 90.0, LineThickness: LineThickness)
        let Line7 = BoundingBoxLine(Start: Point7, End: Point8, Color: LineColor, LineThickness: LineThickness)
        let Line8 = BoundingBoxLine(Start: Point8, End: Point5, Color: LineColor, RotateZ: 90.0, LineThickness: LineThickness)
        let Line9 = BoundingBoxLine(Start: Point1, End: Point5, Color: LineColor, RotateX: 90.0, LineThickness: LineThickness)
        let Line10 = BoundingBoxLine(Start: Point2, End: Point6, Color: LineColor, RotateX: 90.0, LineThickness: LineThickness)
        let Line11 = BoundingBoxLine(Start: Point3, End: Point7, Color: LineColor, RotateX: 90.0, LineThickness: LineThickness)
        let Line12 = BoundingBoxLine(Start: Point4, End: Point8, Color: LineColor, RotateX: 90.0, LineThickness: LineThickness)
        BoundingBoxLines.append(Line1)
        BoundingBoxLines.append(Line2)
        BoundingBoxLines.append(Line3)
        BoundingBoxLines.append(Line4)
        BoundingBoxLines.append(Line5)
        BoundingBoxLines.append(Line6)
        BoundingBoxLines.append(Line7)
        BoundingBoxLines.append(Line8)
        BoundingBoxLines.append(Line9)
        BoundingBoxLines.append(Line10)
        BoundingBoxLines.append(Line11)
        BoundingBoxLines.append(Line12)
        BoxNode = SCNNode()
        BoxNode.castsShadow = false
        BoxNode.addChildNode(Line1)
        BoxNode.addChildNode(Line2)
        BoxNode.addChildNode(Line3)
        BoxNode.addChildNode(Line4)
        BoxNode.addChildNode(Line5)
        BoxNode.addChildNode(Line6)
        BoxNode.addChildNode(Line7)
        BoxNode.addChildNode(Line8)
        BoxNode.addChildNode(Line9)
        BoxNode.addChildNode(Line10)
        BoxNode.addChildNode(Line11)
        BoxNode.addChildNode(Line12)
        self.addChildNode(BoxNode)
        BoundingBoxLines.append(BoxNode)
        if RotateBox
        {
            let XMultiplier = RotateOnX ? 1.0 : 0.0
            let YMultiplier = RotateOnY ? 1.0 : 0.0
            let ZMultiplier = RotateOnZ ? 1.0 : 0.0
            let Rotation = SCNAction.rotateBy(x: CGFloat(90.0.Radians * XMultiplier),
                                              y: CGFloat(90.0.Radians * YMultiplier),
                                              z: CGFloat(90.0.Radians * ZMultiplier),
                                              duration: RotationDuration)
            let RotateForever = SCNAction.repeatForever(Rotation)
            BoxNode.runAction(RotateForever)
        }
        #endif
    }
    
    private var BoxNode = SCNNode()
    
    /// Holds the rotate on X axis flag.
    private var _RotateOnX: Bool = true
    /// Get or set the rotate bounding shape on X axis flag.
    public var RotateOnX: Bool
    {
        get
        {
            return _RotateOnX
        }
        set
        {
            _RotateOnX = newValue
        }
    }
    
    /// Holds the rotate on Y axis flag.
    private var _RotateOnY: Bool = true
    /// Get or set the rotate bounding shape on Y axis flag.
    public var RotateOnY: Bool
    {
        get
        {
            return _RotateOnY
        }
        set
        {
            _RotateOnY = newValue
        }
    }
    
    /// Holds the rotate on Z axis flag.
    private var _RotateOnZ: Bool = true
    /// Get or set the rotate bounding shape on Z axis flag.
    public var RotateOnZ: Bool
    {
        get
        {
            return _RotateOnZ
        }
        set
        {
            _RotateOnZ = newValue
        }
    }
    
    private var _ShowingBoundingShape: Bool = false
    /// Gets the current state of the bounding shape.
    public var ShowingBoundingShape: Bool
    {
        get
        {
            return _ShowingBoundingShape
        }
    }
    
    /// Hide the bounding box around the node.
    private func HideBoundingBox()
    {
        for Line in BoundingBoxLines
        {
            Line.removeAllActions()
            Line.removeAllAnimations()
            Line.removeFromParentNode()
        }
        BoundingBoxLines.removeAll()
        BoxNode.removeAllActions()
        BoxNode.removeAllAnimations()
        BoxNode.removeFromParentNode()
        _ShowingBoundingShape = false
    }
    
    /// Array of bounding box lines.
    private var BoundingBoxLines = [SCNNode]()
    
    /// Return an `SCNNode` that acts looks like a line.
    /// - Parameter Start: The starting point of the line.
    /// - Parameter End: The ending point of the line.
    /// - Parameter Color: The color of the line.
    /// - Parameter RotateX: How to rotate the line on the X axis. In degrees. Defaults to 0.0.
    /// - Parameter RotateY: How to rotate the line on the Y axis. In degrees. Defaults to 0.0.
    /// - Parameter RotateZ: How to rotate the line on the Z axis. In degrees. Defaults to 0.0.
    /// - Parameter LineThickness: The thickness of the line. Defaults to 0.005.
    private func BoundingBoxLine(Start: SCNVector3, End: SCNVector3, Color: NSColor, RotateX: Double = 0.0,
                         RotateY: Double = 0.0, RotateZ: Double = 0.0,
                         LineThickness: CGFloat = 0.005) -> SCNNode
    {
        let Vector = SCNVector3(Start.x - End.x, Start.y - End.y, Start.z - End.z)
        let Distance = sqrt(Vector.x * Vector.x + Vector.y * Vector.y + Vector.z * Vector.z)
        let MidPosition = SCNVector3(x: (Start.x + End.x) / 2,
                                     y: (Start.y + End.y) / 2,
                                     z: (Start.z + End.z) / 2)
        let Line =  SCNCylinder()
        Line.radius = LineThickness
        Line.height = CGFloat(Distance)
        Line.radialSegmentCount = 4
        Line.firstMaterial?.diffuse.contents = Color
        Line.firstMaterial?.selfIllumination.contents = Color
        let LineNode = SCNNode(geometry: Line)
        LineNode.castsShadow = false
        LineNode.position = MidPosition
        LineNode.eulerAngles = SCNVector3(RotateX.Radians, RotateY.Radians, RotateZ.Radians)
        return LineNode
    }
    
    /// Create a bounding sphere shape around the parent `SCNNode2`.
    /// - Note: Bounding spheres do not cast shadows.
    /// - Note: The caller _must_ set `RotateOnX`, `RotateOnY` and/or `RotateOnZ` before calling
    ///         this function if there are any changes to default behavior desired.
    /// - Parameter LineColor: The color of the lines.
    /// - Parameter RotateSphere: Determines if the bounding sphere rotates.
    /// - Parameter RotationDuration: Number of seconds for the rotation animation.
    /// - Parameter SegmentCount: Number of segments for the sphere. More segments add processing time and
    ///             makes the parent `SCNNode2` harder to see. Defaults to 16.
    private func ShowBoundingSphere(LineColor: NSColor = NSColor.red,
                                    RotateSphere: Bool = true,
                                    RotationDuration: Double = 3.0,
                                    SegmentCount: Int = 16)
    {
        if !CanShowBoundingShape
        {
            return
        }
        let BoundingRadius = self.boundingSphere.radius * 1.25
        let BoundingSphere = SCNSphere(radius: CGFloat(BoundingRadius))
        BoundingSphere.firstMaterial?.fillMode = .lines
        BoundingSphere.firstMaterial?.diffuse.contents = LineColor
        BoundingSphere.firstMaterial?.emission.contents = LineColor
        BoundingSphere.segmentCount = SegmentCount
        BoundingSphereNode = SCNNode(geometry: BoundingSphere)
        BoundingSphereNode?.position = self.boundingSphere.center
        BoundingSphereNode?.castsShadow = false
        self.addChildNode(BoundingSphereNode!)
        
        if RotateSphere
        {
            let XMultiplier = RotateOnX ? 1.0 : 0.0
            let YMultiplier = RotateOnY ? 1.0 : 0.0
            let ZMultiplier = RotateOnZ ? 1.0 : 0.0
            let Rotation = SCNAction.rotateBy(x: CGFloat(90.0.Radians * XMultiplier),
                                              y: CGFloat(90.0.Radians * YMultiplier),
                                              z: CGFloat(90.0.Radians * ZMultiplier),
                                              duration: RotationDuration)
            let RotateForever = SCNAction.repeatForever(Rotation)
            BoundingSphereNode?.runAction(RotateForever)
        }
    }
    
    /// Remove the bounding sphere.
    private func HideBoundingSphere()
    {
        BoundingSphereNode?.removeAllActions()
        BoundingSphereNode?.removeAllAnimations()
        BoundingSphereNode?.removeFromParentNode()
        BoundingSphereNode = nil
    }
    
    /// Show a bounding shape around the node.
    /// - Parameter Shape: The shape of the bounding indicator.
    /// - Parameter LineColor: The color of the lines.
    /// - Parameter RotateSphere: Determines if the bounding sphere rotates.
    /// - Parameter RotationDuration: Number of seconds for the rotation animation.
    /// - Parameter LineThickness: Thickness of the line. Ignored if `Shape` is .Sphere.
    /// - Parameter SegmentCount: Number of segments for the sphere. More segments add processing time and
    ///             makes the parent `SCNNode2` harder to see. Defaults to 16. Ignored if `Shape` is .Box.
    public func ShowBoundingShape(_ Shape: NodeBoundingShapes,
                                  LineColor: NSColor = NSColor.red,
                                  RotateBox: Bool = true,
                                  RotationDuration: Double = 3.0,
                                  LineThickness: CGFloat = 0.005,
                                  SegmentCount: Int = 16)
    {
        CurrentBoundingShape = Shape
        HideBoundingBox()
        HideBoundingSphere()
        switch Shape
        {
            case .Box:
                ShowBoundingBox(LineColor: LineColor,
                                RotateBox: RotateBox,
                                RotationDuration: RotationDuration,
                                LineThickness: LineThickness)
                
            case .Sphere:
                ShowBoundingSphere(LineColor: LineColor,
                                   RotateSphere: RotateBox,
                                   RotationDuration: RotationDuration,
                                   SegmentCount: SegmentCount)
        }
    }
    
    /// The bounding sphere node.
    var BoundingSphereNode: SCNNode? = nil
    
    /// The current bounding shape.
    public var CurrentBoundingShape: NodeBoundingShapes = .Box
    
    /// Hide the bounding shape.
    public func HideBoundingShape()
    {
        switch CurrentBoundingShape
        {
            case .Box:
                HideBoundingBox()
                
            case .Sphere:
                HideBoundingSphere()
        }
    }
    
    // MARK: - Day/night settings.
    
    /// Propagates the current daylight state to all child nodes.
    /// - Parameter InDay: True indicates daylight, false indicates nighttime.
    private func PropagateState(InDay: Bool)
    {
        for Child in self.childNodes
        {
            if let Node = Child as? SCNNode2
            {
                Node.IsInDaylight = InDay
            }
        }
    }
    
    /// Set the visual state for the node (and all child nodes) to day or night time (based on the parameter).
    /// - Note: If either `DayState` or `NightState` is nil, no action is taken.
    /// - Parameter For: Determines which state to show.
    public func SetState(For DayTime: Bool)
    {
        if DayState == nil || NightState == nil
        {
            return
        }
        if DayTime
        {
            self.geometry?.firstMaterial?.diffuse.contents = DayState!.Color
            self.geometry?.firstMaterial?.lightingModel = DayState!.LightModel
            if DayState?.Emission != nil
            {
                self.geometry?.firstMaterial?.emission.contents = DayState!.Emission!
            }
            else
            {
                self.geometry?.firstMaterial?.emission.contents = nil
            }
            if DayState?.Metalness != nil
            {
                self.geometry?.firstMaterial?.metalness.contents = DayState!.Metalness
            }
            if DayState?.Roughness != nil
            {
                self.geometry?.firstMaterial?.roughness.contents = DayState!.Roughness!
            }
        }
        else
        {
            self.geometry?.firstMaterial?.diffuse.contents = NightState!.Color
            self.geometry?.firstMaterial?.lightingModel = NightState!.LightModel
            if NightState?.Emission != nil
            {
                self.geometry?.firstMaterial?.emission.contents = NightState!.Emission!
            }
            else
            {
                self.geometry?.firstMaterial?.emission.contents = nil
            }
            if NightState?.Metalness != nil
            {
                self.geometry?.firstMaterial?.metalness.contents = NightState!.Metalness!
            }
            if NightState?.Roughness != nil
            {
                self.geometry?.firstMaterial?.roughness.contents = NightState!.Roughness!
            }
        }
    }
    
    /// Holds the daylight state. Setting this property updates the visual state for this node and all child
    /// nodes.
    private var _IsInDaylight: Bool = true
    {
        didSet
        {
            SetState(For: _IsInDaylight)
            PropagateState(InDay: _IsInDaylight)
        }
    }
    /// Get or set the daylight state. Setting the same value two (or more) times in a row will not result
    /// in any changes.
    public var IsInDaylight: Bool
    {
        get
        {
            return _IsInDaylight
        }
        set
        {
            if PreviousDayState == nil
            {
                PreviousDayState = newValue
            }
            else
            {
                if PreviousDayState == newValue
                {
                    return
                }
                else
                {
                    PreviousDayState = newValue
                }
            }
            _IsInDaylight = newValue
        }
    }
    
    var PreviousDayState: Bool? = nil
    
    /// Holds the can switch state flag.
    private var _CanSwitchState: Bool = false
    {
        didSet
        {
            for Child in self.childNodes
            {
                if let Node = Child as? SCNNode2
                {
                    Node.CanSwitchState = _CanSwitchState
                }
            }
        }
    }
    /// Sets the can switch state flag. If false, the node does not respond to state changes. Setting this
    /// property propagates the same value to all child nodes.
    public var CanSwitchState: Bool
    {
        get
        {
            return _CanSwitchState
        }
        set
        {
            _CanSwitchState = newValue
        }
    }
    
    public var DayState: NodeState? = nil
    public var NightState: NodeState? = nil
 
    /// Convenience function to set the state attributes.
    /// - Parameter For: If true, day time attributes are set. If false, night time attributes are set.
    /// - Parameter Color: The color for the state.
    /// - Parameter Emission: The color for the emmission material (eg, glowing). Defaults to nil.
    /// - Parameter Model: The lighting model for the state. Defaults to `.phong`.
    /// - Parameter Metalness: The metalness value of the state. If nil, not used. Defaults to nil.
    /// - Parameter Roughness: The roughness value of the state. If nil, not used. Defaults to nil.
    public func SetState(For Day: Bool,
                         Color: NSColor,
                         Emission: NSColor? = nil,
                         Model: SCNMaterial.LightingModel = .phong,
                         Metalness: Double? = nil,
                         Roughness: Double? = nil)
    {
        if Day
        {
            DayState = NodeState(Color: Color, Emission: Emission, LightModel: Model,
                                 Metalness: Metalness, Roughness: Roughness)
        }
        else
        {
            NightState = NodeState(Color: Color, Emission: Emission, LightModel: Model,
                                   Metalness: Metalness, Roughness: Roughness)
        }
    }
    
    // MARK: - Map location data.
    
    /// Sets the geographic location of the node in terms of latitude, longitude. All child nodes
    /// are also set with the same values.
    /// - Parameter Latitude: The latitude of the node.
    /// - Parameter Longitude: The longitude of the node.
    public func SetLocation(_ Latitude: Double, _ Longitude: Double)
    {
        self.Latitude = Latitude
        self.Longitude = Longitude
        for Child in self.childNodes
        {
            if let Node = Child as? SCNNode2
            {
                Node.SetLocation(Latitude, Longitude)
            }
        }
    }
    
    /// Clears the geographic location of the node. All child nodes are also cleared.
    public func ClearLocation()
    {
        self.Latitude = nil
        self.Longitude = nil
        for Child in self.childNodes
        {
            if let Node = Child as? SCNNode2
            {
                Node.ClearLocation()
            }
        }
    }
    
    /// Determines if the node has a geographic location.
    /// - Returns: True if the node has both latitude and longitude set, false if not.
    func HasLocation() -> Bool
    {
        return Latitude != nil && Longitude != nil
    }
    
    /// If provided, the latitude of the node.
    public var Latitude: Double? = nil
    /// If provided, the longitude of the node.
    public var Longitude: Double? = nil
}

// MARK: - Bounding shapes.

/// Set of shapes for indicators for `SCNNode2` objects.
enum NodeBoundingShapes: String, CaseIterable
{
    /// Indicator is a box.
    case Box = "Box"
    /// Indicator is a sphere.
    case Sphere = "Sphere"
}

/// Visual state for the node.
struct NodeState
{
    /// Diffuse color.
    let Color: NSColor
    /// Emission color.
    let Emission: NSColor?
    /// Lighting model.
    let LightModel: SCNMaterial.LightingModel
    /// Metalness value. If nil, not used.
    let Metalness: Double?
    /// Roughness value. If nil, not used.
    let Roughness: Double?
}


