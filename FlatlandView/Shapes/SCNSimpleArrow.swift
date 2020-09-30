//
//  SCNSimpleArrow.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/14/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

/// Implements/creates a simple arrow shape in an `SCNNode2`.
class SCNSimpleArrow: SCNNode2
{
    /// Initializer. Creates a default shape.
    override init()
    {
        super.init()
        MakeGeometry()
    }
    
    /// Initializer
    /// - Parameters:
    ///   - Length: Overall length of the arrow.
    ///   - Width: Width of the arrow (the arrowhead's width).
    ///   - Extrusion: Depth of the arrow.
    ///   - Color: Color of the diffuse surface of the arrow.
    ///   - Specular: Color of the specular surface of the arrow.
    ///   - LightMask: The light mask to apply to each sub-node of the simple arrow. Defaults to 0.
    init(Length: CGFloat, Width: CGFloat, Extrusion: CGFloat, Color: NSColor = NSColor.systemYellow,
         Specular: NSColor = NSColor.white, LightMask: Int = 0)
    {
        super.init()
        self.Length = Length
        self.Width = Width
        self.Extrusion = Extrusion
        self.Color = Color
        self.Specular = Specular
        self.LightMask = LightMask
    }
    
    /// Initializers. Creates a default shape.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        MakeGeometry()
    }
    
    /// Holds the light mask value.
    private var _LightMask: Int = 0
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the category light mask.
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
    
    /// Holds the length of the arrow.
    private var _Length: CGFloat = 2.0
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the length of the arrow.
    public var Length: CGFloat
    {
        get
        {
            return _Length
        }
        set
        {
            _Length = newValue
        }
    }
    
    /// Holds the width of the arrow.
    private var _Width: CGFloat = 0.8
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the width of the arrow.
    public var Width: CGFloat
    {
        get
        {
            return _Width
        }
        set
        {
            _Width = newValue
        }
    }
    
    /// Holds the depth of the arrow.
    private var _Extrusion: CGFloat = 0.2
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the depth of the arrow.
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
    
    /// Holds the diffuse color.
    private var _Color: NSColor = NSColor.systemYellow
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the color for the diffuse surface.
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
    
    /// Holds the specular color.
    private var _Specular: NSColor = NSColor.white
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the color for the specular surface.
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
    
    /// Create the arrow geometry and add it to `self`.
    func MakeGeometry()
    {
        for Child in self.childNodes
        {
            Child.removeFromParentNode()
        }
        let Triangle = SCNTriangle(Base: _Width, Height: _Length / 3.0, Extrusion: _Extrusion)
        Triangle.Color = _Color
        Triangle.geometry?.firstMaterial?.specular.contents = _Specular
        Triangle.LightMask = _LightMask
        let Box = SCNBox(width: _Width * 0.25, height: _Length * 0.5, length: _Extrusion, chamferRadius: 0.0)
        Box.firstMaterial?.diffuse.contents = _Color
        Box.firstMaterial?.specular.contents = _Specular
        let Stem = SCNNode(geometry: Box)
        Stem.categoryBitMask = _LightMask
        let HCenter = _Width / 2.0
        Stem.position = SCNVector3(HCenter , -0.5, 0.0)
        let Arrow = SCNNode()
        Arrow.position = SCNVector3(-_Width / 2.0, -_Extrusion / 2.0, 0.0)
        Arrow.addChildNode(Triangle)
        Arrow.addChildNode(Stem)
        self.addChildNode(Arrow)
    }
}
