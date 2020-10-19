//
//  ShapeManager.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/19/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

/// Creates shapes for use on maps.
/// - Note: Shapes are not rotated unless explicitly told to do so.
class ShapeManager
{
    public static func RegularPolygon(VertexCount: Int, Radius: Double, Depth: Double,
                                      Attributes: ShapeAttributes) -> SCNNode2
    {
        let PShape = SCNRegular.Geometry(VertexCount: VertexCount, Radius: CGFloat(Radius), Depth: CGFloat(Depth))
        let PShapeNode = SCNNode2(geometry: PShape)
        PShapeNode.NodeClass = Attributes.Class
        PShapeNode.NodeID = Attributes.ID
        PShapeNode.CanShowBoundingShape = Attributes.ShowBoundingShapes
        if let Latitude = Attributes.Latitude, let Longitudes = Attributes.Longitude
        {
            PShapeNode.SetLocation(Latitude, Longitudes)
        }
        if Attributes.AttributesChange && Attributes.DayState != nil && Attributes.NightState != nil
        {
            PShapeNode.CanSwitchState = true
            PShapeNode.NightState = Attributes.NightState!.EmitNodeState()
            PShapeNode.DayState = Attributes.DayState!.EmitNodeState()
            let IsDay = Solar.IsInDaylight(PShapeNode.Latitude!, PShapeNode.Longitude!)!
            PShapeNode.IsInDaylight = IsDay
            if IsDay
            {
                PShapeNode.geometry?.firstMaterial?.diffuse.contents = Attributes.DayState!.Color
            }
            else
            {
                PShapeNode.geometry?.firstMaterial?.diffuse.contents = Attributes.NightState!.Color
            }
        }
        else
        {
            PShapeNode.CanSwitchState = false
            PShapeNode.geometry?.firstMaterial?.lightingModel = Attributes.LightingMode
            PShapeNode.geometry?.firstMaterial?.diffuse.contents = Attributes.DiffuseColor
            PShapeNode.geometry?.firstMaterial?.specular.contents = Attributes.SpecularColor
            if let Emission = Attributes.EmissionColor
            {
                PShapeNode.geometry?.firstMaterial?.emission.contents = Emission
            }
        }
        if let Mask = Attributes.LightMask
        {
            PShapeNode.categoryBitMask = Mask
        }
        PShapeNode.scale = SCNVector3(Attributes.Scale, Attributes.Scale, Attributes.Scale)
        PShapeNode.eulerAngles = SCNVector3(Attributes.EulerX, Attributes.EulerY, Attributes.EulerZ)
        if let Position = Attributes.Position
        {
            PShapeNode.position = Position
        }
        return PShapeNode
    }
    
    public static func ConeShape(TopRadius: Double, BottomRadius: Double, Height: Double,
                                 Attributes: ShapeAttributes) -> SCNNode2
    {
        let PShape = SCNCone(topRadius: CGFloat(Float(TopRadius)), bottomRadius: CGFloat(BottomRadius),
                             height: CGFloat(Height))
        let PShapeNode = SCNNode2(geometry: PShape)
        PShapeNode.NodeClass = Attributes.Class
        PShapeNode.NodeID = Attributes.ID
        PShapeNode.CanShowBoundingShape = Attributes.ShowBoundingShapes
        if let Latitude = Attributes.Latitude, let Longitudes = Attributes.Longitude
        {
            PShapeNode.SetLocation(Latitude, Longitudes)
        }
        if Attributes.AttributesChange && Attributes.DayState != nil && Attributes.NightState != nil
        {
            PShapeNode.CanSwitchState = true
            PShapeNode.NightState = Attributes.NightState!.EmitNodeState()
            PShapeNode.DayState = Attributes.DayState!.EmitNodeState()
            let IsDay = Solar.IsInDaylight(PShapeNode.Latitude!, PShapeNode.Longitude!)!
            PShapeNode.IsInDaylight = IsDay
            if IsDay
            {
                PShapeNode.geometry?.firstMaterial?.diffuse.contents = Attributes.DayState!.Color
            }
            else
            {
                PShapeNode.geometry?.firstMaterial?.diffuse.contents = Attributes.NightState!.Color
            }
        }
        else
        {
            PShapeNode.CanSwitchState = false
            PShapeNode.geometry?.firstMaterial?.lightingModel = Attributes.LightingMode
            PShapeNode.geometry?.firstMaterial?.diffuse.contents = Attributes.DiffuseColor
            PShapeNode.geometry?.firstMaterial?.specular.contents = Attributes.SpecularColor
            if let Emission = Attributes.EmissionColor
            {
                PShapeNode.geometry?.firstMaterial?.emission.contents = Emission
            }
        }
        if let Mask = Attributes.LightMask
        {
            PShapeNode.categoryBitMask = Mask
        }
        PShapeNode.scale = SCNVector3(Attributes.Scale, Attributes.Scale, Attributes.Scale)
        PShapeNode.eulerAngles = SCNVector3(Attributes.EulerX, Attributes.EulerY, Attributes.EulerZ)
        if let Position = Attributes.Position
        {
            PShapeNode.position = Position
        }
        return PShapeNode
    }
    
    public static func SphereShape(Radius: Double, Attributes: ShapeAttributes) -> SCNNode2
    {
        let PShape = SCNSphere(radius: CGFloat(Radius))
        let PShapeNode = SCNNode2(geometry: PShape)
        PShapeNode.NodeClass = Attributes.Class
        PShapeNode.NodeID = Attributes.ID
        PShapeNode.CanShowBoundingShape = Attributes.ShowBoundingShapes
        if let Latitude = Attributes.Latitude, let Longitudes = Attributes.Longitude
        {
            PShapeNode.SetLocation(Latitude, Longitudes)
        }
        if Attributes.AttributesChange && Attributes.DayState != nil && Attributes.NightState != nil
        {
            PShapeNode.CanSwitchState = true
            PShapeNode.NightState = Attributes.NightState!.EmitNodeState()
            PShapeNode.DayState = Attributes.DayState!.EmitNodeState()
            let IsDay = Solar.IsInDaylight(PShapeNode.Latitude!, PShapeNode.Longitude!)!
            PShapeNode.IsInDaylight = IsDay
            if IsDay
            {
                PShapeNode.geometry?.firstMaterial?.diffuse.contents = Attributes.DayState!.Color
            }
            else
            {
                PShapeNode.geometry?.firstMaterial?.diffuse.contents = Attributes.NightState!.Color
            }
        }
        else
        {
            PShapeNode.CanSwitchState = false
            PShapeNode.geometry?.firstMaterial?.lightingModel = Attributes.LightingMode
            PShapeNode.geometry?.firstMaterial?.diffuse.contents = Attributes.DiffuseColor
            PShapeNode.geometry?.firstMaterial?.specular.contents = Attributes.SpecularColor
            if let Emission = Attributes.EmissionColor
            {
                PShapeNode.geometry?.firstMaterial?.emission.contents = Emission
            }
        }
        if let Mask = Attributes.LightMask
        {
            PShapeNode.categoryBitMask = Mask
        }
        PShapeNode.scale = SCNVector3(Attributes.Scale, Attributes.Scale, Attributes.Scale)
        PShapeNode.eulerAngles = SCNVector3(Attributes.EulerX, Attributes.EulerY, Attributes.EulerZ)
        if let Position = Attributes.Position
        {
            PShapeNode.position = Position
        }
        return PShapeNode
    }
    
    public static func PyramidShape(Width: Double, Height: Double, Length: Double, Attributes: ShapeAttributes) -> SCNNode2
    {
        let PShape = SCNPyramid(width: CGFloat(Width), height: CGFloat(Height), length: CGFloat(Length))
        let PShapeNode = SCNNode2(geometry: PShape)
        PShapeNode.NodeClass = Attributes.Class
        PShapeNode.NodeID = Attributes.ID
        PShapeNode.CanShowBoundingShape = Attributes.ShowBoundingShapes
        if let Latitude = Attributes.Latitude, let Longitudes = Attributes.Longitude
        {
            PShapeNode.SetLocation(Latitude, Longitudes)
        }
        if Attributes.AttributesChange && Attributes.DayState != nil && Attributes.NightState != nil
        {
            PShapeNode.CanSwitchState = true
            PShapeNode.NightState = Attributes.NightState!.EmitNodeState()
            PShapeNode.DayState = Attributes.DayState!.EmitNodeState()
            let IsDay = Solar.IsInDaylight(PShapeNode.Latitude!, PShapeNode.Longitude!)!
            PShapeNode.IsInDaylight = IsDay
            if IsDay
            {
                PShapeNode.geometry?.firstMaterial?.diffuse.contents = Attributes.DayState!.Color
            }
            else
            {
                PShapeNode.geometry?.firstMaterial?.diffuse.contents = Attributes.NightState!.Color
            }
        }
        else
        {
            PShapeNode.CanSwitchState = false
            PShapeNode.geometry?.firstMaterial?.lightingModel = Attributes.LightingMode
            PShapeNode.geometry?.firstMaterial?.diffuse.contents = Attributes.DiffuseColor
            PShapeNode.geometry?.firstMaterial?.specular.contents = Attributes.SpecularColor
            if let Emission = Attributes.EmissionColor
            {
                PShapeNode.geometry?.firstMaterial?.emission.contents = Emission
            }
        }
        if let Mask = Attributes.LightMask
        {
            PShapeNode.categoryBitMask = Mask
        }
        PShapeNode.scale = SCNVector3(Attributes.Scale, Attributes.Scale, Attributes.Scale)
        PShapeNode.eulerAngles = SCNVector3(Attributes.EulerX, Attributes.EulerY, Attributes.EulerZ)
        if let Position = Attributes.Position
        {
            PShapeNode.position = Position
        }
        return PShapeNode
    }
    
    public static func BoxShape(Width: Double, Height: Double, Length: Double, Chamfer: Double,
                                Attributes: ShapeAttributes) -> SCNNode2
    {
        let PShape = SCNBox(width: CGFloat(Width), height: CGFloat(Height), length: CGFloat(Length),
                            chamferRadius: CGFloat(Chamfer))
        let PShapeNode = SCNNode2(geometry: PShape)
        PShapeNode.NodeClass = Attributes.Class
        PShapeNode.NodeID = Attributes.ID
        PShapeNode.CanShowBoundingShape = Attributes.ShowBoundingShapes
        if let Latitude = Attributes.Latitude, let Longitudes = Attributes.Longitude
        {
            PShapeNode.SetLocation(Latitude, Longitudes)
        }
        if Attributes.AttributesChange && Attributes.DayState != nil && Attributes.NightState != nil
        {
            PShapeNode.CanSwitchState = true
            PShapeNode.NightState = Attributes.NightState!.EmitNodeState()
            PShapeNode.DayState = Attributes.DayState!.EmitNodeState()
            let IsDay = Solar.IsInDaylight(PShapeNode.Latitude!, PShapeNode.Longitude!)!
            PShapeNode.IsInDaylight = IsDay
            if IsDay
            {
                PShapeNode.geometry?.firstMaterial?.diffuse.contents = Attributes.DayState!.Color
            }
            else
            {
                PShapeNode.geometry?.firstMaterial?.diffuse.contents = Attributes.NightState!.Color
            }
        }
        else
        {
            PShapeNode.CanSwitchState = false
            PShapeNode.geometry?.firstMaterial?.lightingModel = Attributes.LightingMode
            PShapeNode.geometry?.firstMaterial?.diffuse.contents = Attributes.DiffuseColor
            PShapeNode.geometry?.firstMaterial?.specular.contents = Attributes.SpecularColor
            if let Emission = Attributes.EmissionColor
            {
                PShapeNode.geometry?.firstMaterial?.emission.contents = Emission
            }
        }
        if let Mask = Attributes.LightMask
        {
            PShapeNode.categoryBitMask = Mask
        }
        PShapeNode.scale = SCNVector3(Attributes.Scale, Attributes.Scale, Attributes.Scale)
        PShapeNode.eulerAngles = SCNVector3(Attributes.EulerX, Attributes.EulerY, Attributes.EulerZ)
        if let Position = Attributes.Position
        {
            PShapeNode.position = Position
        }
        return PShapeNode
    }
    
    public static func CylinderShape(Radius: Double, Height: Double, Attributes: ShapeAttributes) -> SCNNode2
    {
        let PShape = SCNCylinder(radius: CGFloat(Radius), height: CGFloat(Height))
        let PShapeNode = SCNNode2(geometry: PShape)
        PShapeNode.NodeClass = Attributes.Class
        PShapeNode.NodeID = Attributes.ID
        PShapeNode.CanShowBoundingShape = Attributes.ShowBoundingShapes
        if let Latitude = Attributes.Latitude, let Longitudes = Attributes.Longitude
        {
            PShapeNode.SetLocation(Latitude, Longitudes)
        }
        if Attributes.AttributesChange && Attributes.DayState != nil && Attributes.NightState != nil
        {
            PShapeNode.CanSwitchState = true
            PShapeNode.NightState = Attributes.NightState!.EmitNodeState()
            PShapeNode.DayState = Attributes.DayState!.EmitNodeState()
            let IsDay = Solar.IsInDaylight(PShapeNode.Latitude!, PShapeNode.Longitude!)!
            PShapeNode.IsInDaylight = IsDay
            if IsDay
            {
                PShapeNode.geometry?.firstMaterial?.diffuse.contents = Attributes.DayState!.Color
            }
            else
            {
                PShapeNode.geometry?.firstMaterial?.diffuse.contents = Attributes.NightState!.Color
            }
        }
        else
        {
            PShapeNode.CanSwitchState = false
            PShapeNode.geometry?.firstMaterial?.lightingModel = Attributes.LightingMode
            PShapeNode.geometry?.firstMaterial?.diffuse.contents = Attributes.DiffuseColor
            PShapeNode.geometry?.firstMaterial?.specular.contents = Attributes.SpecularColor
            if let Emission = Attributes.EmissionColor
            {
                PShapeNode.geometry?.firstMaterial?.emission.contents = Emission
            }
        }
        if let Mask = Attributes.LightMask
        {
            PShapeNode.categoryBitMask = Mask
        }
        PShapeNode.scale = SCNVector3(Attributes.Scale, Attributes.Scale, Attributes.Scale)
        PShapeNode.eulerAngles = SCNVector3(Attributes.EulerX, Attributes.EulerY, Attributes.EulerZ)
        if let Position = Attributes.Position
        {
            PShapeNode.position = Position
        }
        return PShapeNode
    }
    
    public static func StarShape(VertexCount: Int, Height: Double, Base: Double, ZHeight: Double,
                                 Attributes: ShapeAttributes) -> SCNNode2
    {
        let PShapeNode = SCNNode2(geometry: SCNStar.Geometry(VertexCount: VertexCount, Height: Height, Base: Base, ZHeight: ZHeight))
        PShapeNode.NodeClass = Attributes.Class
        PShapeNode.NodeID = Attributes.ID
        PShapeNode.CanShowBoundingShape = Attributes.ShowBoundingShapes
        if let Latitude = Attributes.Latitude, let Longitudes = Attributes.Longitude
        {
            PShapeNode.SetLocation(Latitude, Longitudes)
        }
        if Attributes.AttributesChange && Attributes.DayState != nil && Attributes.NightState != nil
        {
            PShapeNode.CanSwitchState = true
            PShapeNode.NightState = Attributes.NightState!.EmitNodeState()
            PShapeNode.DayState = Attributes.DayState!.EmitNodeState()
            let IsDay = Solar.IsInDaylight(PShapeNode.Latitude!, PShapeNode.Longitude!)!
            PShapeNode.IsInDaylight = IsDay
            if IsDay
            {
                PShapeNode.geometry?.firstMaterial?.diffuse.contents = Attributes.DayState!.Color
            }
            else
            {
                PShapeNode.geometry?.firstMaterial?.diffuse.contents = Attributes.NightState!.Color
            }
        }
        else
        {
            PShapeNode.CanSwitchState = false
            PShapeNode.geometry?.firstMaterial?.lightingModel = Attributes.LightingMode
            PShapeNode.geometry?.firstMaterial?.diffuse.contents = Attributes.DiffuseColor
            PShapeNode.geometry?.firstMaterial?.specular.contents = Attributes.SpecularColor
            if let Emission = Attributes.EmissionColor
            {
                PShapeNode.geometry?.firstMaterial?.emission.contents = Emission
            }
        }
        if let Mask = Attributes.LightMask
        {
            PShapeNode.categoryBitMask = Mask
        }
        PShapeNode.scale = SCNVector3(Attributes.Scale, Attributes.Scale, Attributes.Scale)
        PShapeNode.eulerAngles = SCNVector3(Attributes.EulerX, Attributes.EulerY, Attributes.EulerZ)
        if let Position = Attributes.Position
        {
            PShapeNode.position = Position
        }
        return PShapeNode
    }
}

enum ShapeParts: String, CaseIterable
{
    case Sphere = "c9a05ed9-2dbb-49e6-8e8e-32dd9feaae20"
    case Box = "e3e084ae-f2ac-413f-99d9-39665b05bf58"
    case Combined = "c8e74e77-8e05-434c-a0c9-ef75657f4c39"
    case ArrowHead = "119a3145-4a90-4644-a762-118d9f10abca"
    case ArrowTail = "d700fabd-521d-423c-9275-fe169a4beb49"
    case Cone = "17f4b413-3a49-450b-adf4-24fc0916d417"
    case Capsule = "ed6ba889-b9e0-498b-beee-fd71ecd3d8d6"
    
    /// Returns the UUID value of the passed `ShapePart`. `UUID.Empty` is returned if the shape part
    /// value cannot be property converted.
    func Value(_ Part: ShapeParts) -> UUID
    {
        if let Actual = UUID(uuidString: Part.rawValue)
        {
            return Actual
        }
        else
        {
            return UUID.Empty
        }
    }
}

/// Attributes for shapes.
class ShapeAttributes
{
    /// If present, the ID of the sub-node of the overall shape. Attributes here are applied to only those
    /// sub-nodes with this ID.
    var SubComponentID: UUID? = nil
    
    /// If present, the ID of the node to enable it to participate in the user-interaction system. Defaults to
    /// nil.
    var ID: UUID? = nil
    
    /// If present, the class ID of the node to enable it to participate in the user-interaction system.
    /// Defaults to `nil`.
    var Class: UUID? = nil
    
    /// The scale of the node. Defaults to `1.0`.
    var Scale: Double = 1.0
    
    /// If present, the category bit mask for the node. If not present, nothing is assigned.
    /// Defaults to `nil`.
    var LightMask: Int? = nil
    
    /// Show bounding shapes. Defaults to `false`.
    var ShowBoundingShapes: Bool = false
    
    /// The bounding shape to indicate a node in the user interaction system. If nil, no shapes are shown.
    /// Defaults to `nil`.
    var ShowBoundingShape: NodeBoundingShapes? = nil
    
    /// Flag that tells the Dark Clock that a given node can change depending on the local daylight.
    /// Defaults to `false`.
    var AttributesChange: Bool = false
    
    /// If present, the visual attributes for the day state. Defaults to `nil`.
    var DayState: TimeState? = nil
    
    /// If present, the visual attributes for the night state. Defaults to `nil`.
    var NightState: TimeState? = nil
    
    /// Cast shadow flag. Defaults to `true`.
    var CastsShadow: Bool = true
    
    /// The node's diffuse material color for non-time changing nodes.
    var DiffuseColor: NSColor = NSColor.red
    
    /// The node's specular material color for non-time changing nodes.
    var SpecularColor: NSColor = NSColor.white
    
    /// If present, the emission color (eg, glow color) of the node. If not present, the node will not glow.
    /// This is used only when the node does not change attributes depending on the time of day.
    var EmissionColor: NSColor? = nil
    
    /// If present, the latitude of the real-world position of the shape. Defaults to `nil`.
    var Latitude: Double? = nil
    
    /// If present, the longitude of the real-world position of the shape. Defaults to `nil`.
    var Longitude: Double? = nil
    
    /// The lighting model.
    var LightingMode: SCNMaterial.LightingModel = .phong
    
    /// Euler X axis value for orientation. *Must be in radians*.
    var EulerX: Double = 0.0
    
    /// Euler Y axis value for orientation. *Must be in radians*.
    var EulerY: Double = 0.0
    
    /// Euler Z axis value for orientation. *Must be in radians*.
    var EulerZ: Double = 0.0
    
    /// If present, the location assigned to the node before being returned. If not present, no location/position
    /// is assigned.
    var Position: SCNVector3? = nil
}

class TimeState
{
    var IsDayState: Bool = true
    var Color: NSColor = NSColor.white
    var Emission: NSColor? = nil
    var Specular: NSColor = NSColor.white
    var LightingModel: SCNMaterial.LightingModel = .phong
    var Metalness: Double? = nil
    var Roughness: Double? = nil
    
    func EmitNodeState() -> NodeState
    {
        let EmitMe = NodeState(Color: Color, Emission: Emission, Specular: Specular,
                               LightModel: LightingModel, Metalness: Metalness, Roughness: Roughness)
        return EmitMe
    }
}

enum ShapeManagerShapes: String, CaseIterable
{
    case RegularPolygon = "Regular Polygon"
    case Triangle = "Triangle"
    case Circle = "Circle"
    case Square = "Square"
    case Cone = "Cone"
    case InvertedCone = "Inverted Cone"
    case SpikyCone = "Spiky Cone"
    case Pyramid = "Pyramid"
    case Cylinder = "Cylinder"
    case Box = "Box"
    case FloatingBox = "Floating Box"
    case Sphere = "Sphere"
    case FloatingSphere = "Floating Sphere"
    case PulsatingSphere = "Pulsating Sphere"
    case Pole = "Pole"
    case Flag = "Flag"
    case Gnomon = "Gnomon"
    case Pin = "Pin"
    case Arrow3D = "Arrow3D"
    case Arrow = "Arrow"
    case BouncingArrow = "Bouncing Arrow"
    case Star = "Star"
    case EmbeddedStar = "Star in Star"
}
