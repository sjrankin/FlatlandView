//
//  StarField.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import CoreGraphics
import CoreImage
import SceneKit

/// Implements a field of "stars" that appears to move.
class Starfield: SCNView
{
    /// Initializer.
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        Initialize()
    }
    
    /// Initializer.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        Initialize()
    }
    
    /// Initialize the scene.
    func Initialize()
    {
        self.scene = SCNScene()
        self.antialiasingMode = .none
        
        let Camera = SCNCamera()
        Camera.fieldOfView = 60.0
        Camera.zFar = 1000
        Camera.zNear = 0.1
        CameraNode = SCNNode()
        CameraNode?.camera = Camera
        CameraNode?.position = SCNVector3(0.0, 0.0, 0.0)
        self.scene?.rootNode.addChildNode(CameraNode!)
        
        let Light = SCNLight()
        Light.type = .ambient
        Light.color = NSColor.white
        LightNode = SCNNode()
        LightNode?.light = Light
        LightNode?.position = SCNVector3(0.0, 0.0, 0.0)
        self.scene?.rootNode.addChildNode(LightNode!)
        
        self.backgroundColor = NSColor.black
        self.autoenablesDefaultLighting = false
    }
    
    var CameraNode: SCNNode? = nil
    var LightNode: SCNNode? = nil
    
    /// Hide the stars in the field. Also hides the `SCNView` control.
    func Hide()
    {
        self.isHidden = true
        RemoveStars()
    }
    
    /// Show the stars in the field. Also shows the `SCNView` control.
    /// - Parameter StarCount: The number of stars in the star field. Defaults to 1000.
    /// - Parameter StarColor: The color of the stars. Can be overriden if
    ///                        `UseNaturalStarColors` is true.
    /// - Parameter UseNaturalStarColors: If true, star colors follows a rough distribution
    ///                                   of actual star colors.
    /// - Parameter MaxStarSize: The maximum random star size.
    /// - Parameter SpeedMultiplier: Determines the rate of "travel" through the star field.
    func Show(StarCount: Int = 1000, StarColor: NSColor = NSColor.white,
              UseNaturalStarColors: Bool = false, MaxStarSize: Double = 0.08,
              SpeedMultiplier: Double = 1.0)
    {
        self.isHidden = false
        FillStars(To: 1000, MaxSize: MaxStarSize, StarColor: StarColor, UseNaturalStarColors: UseNaturalStarColors,
                  SpeedMultiplier: SpeedMultiplier)
    }
    
    /// Remove all stars from the star field.
    func RemoveStars()
    {
        if self.scene?.rootNode.childNodes == nil
        {
            return
        }
        if (self.scene?.rootNode.childNodes.count)! > 0
        {
            for StarNode in self.scene!.rootNode.childNodes
            {
                StarNode.removeAllActions()
                StarNode.removeFromParentNode()
            }
        }
    }
    
    /// Add stars to the star field.
    /// - Parameter Count: The number of stars to add.
    /// - Parameter MaxSize: The maximum random star size. Defaults to 0.08.
    /// - Parameter StarColor: The color of the stars. Can be overriden if
    ///                        `UseNaturalStarColors` is true. Defaults to NSColor.white.
    /// - Parameter UseNaturalStarColors: If true, star colors follows a rough distribution
    ///                                   of actual star colors. Defaults to true.
    /// - Parameter SpeedMultiplier: Determines the rate of "travel" through the star field.
    ///                              Defaults to 1.0.
    func FillStars(To Count: Int, MaxSize: Double = 0.08, StarColor: NSColor = NSColor.white,
                   UseNaturalStarColors: Bool = true, SpeedMultiplier: Double = 1.0)
    {
        for _ in 0 ..< Count
        {
            MakeStar(StarColor: StarColor, SpeedMultiplier: SpeedMultiplier,
                     MaxStarSize: MaxSize, UseNaturalStarColors: UseNaturalStarColors)
        }
    }
    
    /// Create a star to add to the star field.
    /// - Warning: A fatal error will be generated if `SpeedMultiplier` is 0.0 or less.
    /// - Parameter StarColor: The color of the star. If `UseNaturalStarColors` is true, this
    ///                        parameter is ignored.
    /// - Parameter SpeedMultiplier: Velocity of "travel" through the star field. Defaults to 1.0.
    /// - Parameter MaxStarSize: Maximum random star size. Defaults to 0.08.
    /// - Parameter UseNaturalStarColors: If true, stars are colored randomly in a distribution of
    ///                                   actual star colors.
    func MakeStar(StarColor: NSColor, SpeedMultiplier: Double = 1.0, MaxStarSize: Double = 0.08,
                  UseNaturalStarColors: Bool = false)
    {
        if SpeedMultiplier <= 0.0
        {
            fatalError("SpeedMultipler must be greater than 0.0 - was \(SpeedMultiplier).")
        }
        let P = PointInSphere(Radius: 100.0)
        let StarSize = Double.random(in: 0.025 ... MaxStarSize)
        let Node = SCNNode(geometry: SCNSphere(radius: CGFloat(StarSize)))
        Node.position = P
        if UseNaturalStarColors
        {
            Node.geometry?.firstMaterial?.diffuse.contents = RandomStarColor()
        }
        else
        {
            Node.geometry?.firstMaterial?.diffuse.contents = StarColor
        }
        Node.geometry?.firstMaterial?.selfIllumination.contents = NSColor.yellow
//        Node.geometry?.firstMaterial?.emission.contents = NSColor.yellow
        self.scene?.rootNode.addChildNode(Node)
        let ZGone = 1.0
        let Destination = SCNVector3(P.x, P.y, CGFloat(ZGone))
        let Duration = (ZGone - Double(P.z)) / SpeedMultiplier
        let Motion = SCNAction.move(to: Destination, duration: Duration)
        Node.opacity = 0.0
        let FadeIn = SCNAction.fadeIn(duration: 1.0)
        let Group = SCNAction.group([FadeIn, Motion])
        Node.runAction(Group)
        {
            Node.removeAllActions()
            Node.removeFromParentNode()
            self.MakeStar(StarColor: NSColor.white, SpeedMultiplier: SpeedMultiplier,
                          MaxStarSize: MaxStarSize, UseNaturalStarColors: UseNaturalStarColors)
        }
    }
    
    /// Returns a randomly selected star color from the `StarColors` table of actual star colors.
    /// - Returns: Randomly selected color from the `StarColors` table.
    func RandomStarColor() -> NSColor
    {
        let Percent = Double.random(in: 0.0 ... 1.0)
        for (StarPercent, Color) in StarColors
        {
            if Percent <= StarPercent
            {
                return Color
            }
        }
        return NSColor.white
    }
    
    /// Rough distribution of actual star colors.
    let StarColors: [(Double, NSColor)] =
        [
            (0.7645, NSColor(red: 1.0, green: 202 / 255, blue: 122 / 255, alpha: 1.0)),
            (0.8855, NSColor(red: 1.0, green: 209 / 255, blue: 166 / 255, alpha: 1.0)),
            (0.9615, NSColor(red: 1.0, green: 244 / 255, blue: 235 / 255, alpha: 1.0)),
            (0.9915, NSColor(red: 248 / 255, green: 247 / 255, blue: 1.0, alpha: 1.0)),
            (0.9975, NSColor(red: 202 / 255, green: 217 / 255, blue: 253 / 255, alpha: 1.0)),
            (0.9988, NSColor(red: 169 / 255, green: 194 / 255, blue: 252 / 255, alpha: 1.0)),
    ]
    
    /// Returns a random point in the sphere centered at the origin and with a radius of `Radius`.
    /// - Note: See [Point in sphere](http://datagenetics.com/blog/january32020/index.html)
    /// - Parameter Radius: Radius of the sphere.
    /// - Returns: Random point in the sphere defined by `Radius` centered on the origin.
    func PointInSphere(Radius: Double) -> SCNVector3
    {
        while true
        {
            let X = Double.random(in: -1.0 ... 1.0)
            let Y = Double.random(in: -1.0 ... 1.0)
            let Z = Double.random(in: -1.0 ... 0.0)
            if sqrt((X * X) + (Y * Y) + (Z * Z)) < 1.0
            {
                return SCNVector3(X * Radius, Y * Radius, Z * Radius)
            }
        }
    }
}
