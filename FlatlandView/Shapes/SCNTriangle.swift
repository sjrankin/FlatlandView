//
//  SCNTriangle.swift
//  FlatlandView
//
//  Created by Stuart Rankin on 6/14/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

/// Implements a simple triangle `SCNNode`.
class SCNTriangle: SCNNode
{
    /// Initializer. Creates a default triangle.
    override init()
    {
        super.init()
        MakeGeometry()
    }
    
    /// Initializer. Creates a default triangle.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        MakeGeometry()
    }
    
    /// Initializer.
    /// - Parameters:
    ///   - Base: Lenght of the base of the triangle.
    ///   - Height: Height of the triangle.
    ///   - Extrusion: Depth of the triangle.
    ///   - Color: Color of the diffuse material.
    ///   - Specular: Color of the specular material.
    ///   - LightMask: The light mask value. Defaults to 0.
    init(Base: CGFloat, Height: CGFloat, Extrusion: CGFloat, Color: NSColor = NSColor.systemYellow,
         Specular: NSColor = NSColor.white, LightMask: Int = 0)
    {
        super.init()
        self.Base = Base
        self.Height = Height
        self.Extrusion = Extrusion
        self.Color = Color
        self.Specular = Specular
        self.LightMask = LightMask
    }
    
    /// Holds the length of the base of the triangle.
    private var _Base: CGFloat = 1.0
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the length of the base of the triangle.
    public var Base: CGFloat
    {
        get
        {
            return _Base
        }
        set
        {
            _Base = newValue
        }
    }
    
    /// Holds the height of the triangle.
    private var _Height: CGFloat = 1.0
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the height of the triangle.
    public var Height: CGFloat
    {
        get
        {
            return _Height
        }
        set
        {
            _Height = newValue
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
    
    /// Create the geometric triangle and add it to `self`. All prior shapes
    /// are removed first.
    func MakeGeometry()
    {
        for Child in self.childNodes
        {
            Child.removeFromParentNode()
        }
        let Path = NSBezierPath()
        let HCenter = _Base / 2.0
        Path.move(to: NSPoint(x: HCenter, y: _Height))
        Path.line(to: NSPoint(x: HCenter + _Base / 2.0, y: 0.0))
        Path.line(to: NSPoint(x: 0.0, y: 0.0))
        Path.line(to: NSPoint(x: HCenter, y: _Height))
        Path.close()
        let Geo = SCNShape(path: Path, extrusionDepth: _Extrusion)
        let GeoNode = SCNNode(geometry: Geo)
        GeoNode.categoryBitMask = _LightMask
        GeoNode.geometry?.firstMaterial?.diffuse.contents = Color
        GeoNode.geometry?.firstMaterial?.specular.contents = Specular
        self.addChildNode(GeoNode)
    }
}
