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

/// Implements a simple triangle `SCNNode2`.
class SCNTriangle: SCNNode2, ShapeAttribute
{
    /// Initializer. Creates a default triangle.
    override init()
    {
        super.init()
        self.UseProtocolToSetState = true
        MakeGeometry()
    }
    
    /// Initializer. Creates a default triangle.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        self.UseProtocolToSetState = true
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
        self.UseProtocolToSetState = true
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
    
    /// Holds the emission color.
    private var _Emission: NSColor? = nil
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the emission color.
    public var Emission: NSColor?
    {
        get
        {
            return _Emission
        }
        set
        {
            _Emission = newValue
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
    
    /// Holds the lighting model.
    private var _LightingModel: SCNMaterial.LightingModel = .phong
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the lighting model.
    public var LightingModel: SCNMaterial.LightingModel
    {
        get
        {
            return _LightingModel
        }
        set
        {
            _LightingModel = newValue
        }
    }
    
    /// Holds the metalness level.
    private var _Metalness: Double? = nil
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the metalness level.
    public var Metalness: Double?
    {
        get
        {
            return _Metalness
        }
        set
        {
            _Metalness = newValue
        }
    }
    
    /// Holds the roughness level.
    private var _Roughness: Double? = nil
    {
        didSet
        {
            MakeGeometry()
        }
    }
    /// Get or set the roughness level.
    public var Roughness: Double?
    {
        get
        {
            return _Roughness
        }
        set
        {
            _Roughness = newValue
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
        GeoNode = SCNNode2(geometry: Geo)
        GeoNode.categoryBitMask = _LightMask
        GeoNode.geometry?.firstMaterial?.diffuse.contents = Color
        GeoNode.geometry?.firstMaterial?.specular.contents = Specular
        GeoNode.geometry?.firstMaterial?.emission.contents = Emission
        GeoNode.geometry?.firstMaterial?.metalness.contents = Metalness
        GeoNode.geometry?.firstMaterial?.roughness.contents = Roughness
        self.addChildNode(GeoNode)
    }
    
    var GeoNode = SCNNode2()
    
    // MARK: - Shape attributes.
    
    func SetMaterialColor(_ Color: NSColor)
    {
        GeoNode.geometry?.firstMaterial?.diffuse.contents = Color
    }
    
    func SetEmissionColor(_ Color: NSColor?)
    {
        if let Emission = Color
        {
            GeoNode.geometry?.firstMaterial?.emission.contents = Emission
        }
        else
        {
            GeoNode.geometry?.firstMaterial?.emission.contents = nil
        }
    }
    
    func SetLightingModel(_ Model: SCNMaterial.LightingModel)
    {
        GeoNode.geometry?.firstMaterial?.lightingModel = Model
    }
    
    func SetMetalness(_ Value: Double?)
    {
        if let Metal = Value
        {
            GeoNode.geometry?.firstMaterial?.metalness.contents = Metal
        }
    }
    
    func SetRoughness(_ Value: Double?)
    {
        if let Rough = Value
        {
            GeoNode.geometry?.firstMaterial?.roughness.contents = Rough
        }
    }
}
