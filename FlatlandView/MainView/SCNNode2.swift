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
    
    override var scale: SCNVector3
    {
        get
        {
            return super.scale
        }
        set
        {
            super.scale = newValue
        }
    }
    
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
    
    var _CanShowBoundingBox: Bool = true
    {
        didSet
        {
            if !_CanShowBoundingBox
            {
                HideBoundingBox()
            }
        }
    }
    /// Determines whether bounding boxes can be shown. If set to true, bounding boxes can be shown with a
    /// call to `ShowBoundingBox`. If set to false, bounding boxes are not shown and if a bounding box is
    /// currently showing, it is hidden.
    var CanShowBoundingBox: Bool
    {
        get
        {
            return _CanShowBoundingBox
        }
        set
        {
            _CanShowBoundingBox = newValue
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
    func ShowBoundingBox(LineColor: NSColor = NSColor.red,
                         RotateBox: Bool = true,
                         RotationDuration: Double = 3.0,
                         LineThickness: CGFloat = 0.005)
    {
        if !CanShowBoundingBox
        {
            return
        }
        HideBoundingBox()
        if ShowingBoundingBox
        {
            return
        }
        let (BoxMin, BoxMax) = self.boundingBox
        _ShowingBoundingBox = true
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
        let BoxNode = SCNNode()
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
    }
    
    /// Holds the rotate on X axis flag.
    private var _RotateOnX: Bool = true
    /// Get or set the rotate bounding box on X axis flag.
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
    /// Get or set the rotate bounding box on Y axis flag.
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
    /// Get or set the rotate bounding box on Z axis flag.
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
    
    private var _ShowingBoundingBox: Bool = false
    /// Gets the current state of the bounding box. The state is changed by calls to `ShowBoundingBox` and
    /// `HideBoundingBox`.
    public var ShowingBoundingBox: Bool
    {
        get
        {
            return _ShowingBoundingBox
        }
    }
    
    /// Hide the bounding box around the node.
    func HideBoundingBox()
    {
        for Line in BoundingBoxLines
        {
            Line.removeAllActions()
            Line.removeAllAnimations()
            Line.removeFromParentNode()
        }
        BoundingBoxLines.removeAll()
        _ShowingBoundingBox = false
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
}



