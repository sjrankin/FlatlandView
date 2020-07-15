//
//  SCNTriangleRing.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

class SCNTriangeRing: SCNNode
{
    public static let MinimumTriangleCount: Int = 4
    public static let MaximumTriangleCount: Int = 10
    
    private var Triangles = [SCNNode]()
    
     init(Count: Int, Inner: CGFloat, Outer: CGFloat)
    {
        super.init()
        _InnerRadius = Inner
        _OuterRadius = Outer
        TriangleCount = Count
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    public var _PointsOut: Bool = true
    {
        didSet
        {
            MakeGeometry()
        }
    }
    public var PointsOut: Bool
    {
        get
        {
            return _PointsOut
        }
        set
        {
            _PointsOut = newValue
        }
    }
    
    private var _TriangleCount: Int = 5
    {
        didSet
        {
            MakeGeometry()
        }
    }
    public var TriangleCount: Int
    {
        get
        {
            return _TriangleCount
        }
        set
        {
            var FinalCount = min(newValue, SCNTriangeRing.MaximumTriangleCount)
            FinalCount = max(FinalCount, SCNTriangeRing.MinimumTriangleCount)
            _TriangleCount = FinalCount
        }
    }
    
    private var _InnerRadius: CGFloat = 1.0
    {
        didSet
        {
            MakeGeometry()
        }
    }
    public var InnerRadius: CGFloat
    {
        get
        {
            return _InnerRadius
        }
        set
        {
            if newValue >= _OuterRadius
            {
                fatalError("InnerRadius value must be less than OuterRadius value.")
            }
            _InnerRadius = newValue
        }
    }
    
    private var _OuterRadius: CGFloat = 2.0
    {
        didSet
        {
            MakeGeometry()
        }
    }
    public var OuterRadius: CGFloat
    {
        get
        {
            return _OuterRadius
        }
        set
        {
            if newValue <= _InnerRadius
            {
                fatalError("OuterRaidus value must be greater than InnerRadius value.")
            }
            _OuterRadius = newValue
        }
    }
    
    /// Holds the depth of the triangle.
    private var _Extrusion: CGFloat = 0.1
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the depth of the triangle.
    public var Extrusion: CGFloat
    {
        get
        {
            return _Extrusion
        }
        set
        {
            _Extrusion = newValue
        }
    }
    
    /// Holds the color of the diffuse surface of the triangle.
    private var _Color: NSColor = NSColor.systemYellow
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the color of the diffuse surface of the triangle.
    public var Color: NSColor
    {
        get
        {
            return _Color
        }
        set
        {
            _Color = newValue
        }
    }
    
    /// Holds the color of the specular surface of the triangle.
    private var _Specular: NSColor = NSColor.white
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the color of the specular surface of the triangle.
    public var Specular: NSColor
    {
        get
        {
            return _Specular
        }
        set
        {
            _Specular = newValue
        }
    }
    
    /// Holds the light mask value.
    private var _LightMask: Int = 0
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the category light mask value.
    public var LightMask: Int
    {
        get
        {
            return _LightMask
        }
        set
        {
            _LightMask = newValue
        }
    }
    
    private func MakeTriangle(Top: NSPoint, Base1: NSPoint, Base2: NSPoint) -> SCNNode
    {
        let Path = NSBezierPath()
        Path.move(to: Top)
        Path.line(to: Base1)
        Path.line(to: Base2)
        Path.line(to: Top)
        Path.close()
        let Geo = SCNShape(path: Path, extrusionDepth: _Extrusion)
        let GeoNode = SCNNode(geometry: Geo)
        GeoNode.categoryBitMask = _LightMask
        GeoNode.geometry?.firstMaterial?.diffuse.contents = Color
        GeoNode.geometry?.firstMaterial?.specular.contents = Specular
        return GeoNode
    }
    
    func MakeGeometry()
    {
        for Triangle in Triangles
        {
            Triangle.removeFromParentNode()
        }
        Triangles.removeAll()
        if TriangleCount < 1
        {
            return
        }
        
        var Circumference: CGFloat = 1.0
        if PointsOut
        {
        Circumference = InnerRadius * 2.0 * CGFloat.pi
        }
        else
        {
        Circumference = OuterRadius * 2.0 * CGFloat.pi
        }
        let Base = Circumference / CGFloat(TriangleCount)
        for Count in 0 ..< TriangleCount
        {
            let Triangle = MakeTriangle(Top: NSPoint(x: 0.0, y: OuterRadius - InnerRadius),
                                        Base1: NSPoint(x: -Base / 2.0, y: 0.0),
                                        Base2: NSPoint(x: Base / 2.0, y: 0.0))
            let Angle = (CGFloat(Count) / CGFloat(TriangleCount)) * 360.0
            Triangle.eulerAngles = SCNVector3(0.0, 0.0, Angle.Radians)
            self.addChildNode(Triangle)
            Triangles.append(Triangle)
        }
    }
}
