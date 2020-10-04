//
//  +FlatViewLights.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/22/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension FlatView
{
    /// Create an ambient light for the scene. Create a secondary ambient light for the sun nodes.
    func CreateAmbientLight()
    {
        let Ambient = SCNLight()
        Ambient.name = LightNames.Ambient2D.rawValue
        Ambient.categoryBitMask = LightMasks2D.Ambient.rawValue
        Ambient.type = .ambient
        Ambient.intensity = CGFloat(Defaults.AmbientLightIntensity.rawValue)
        Ambient.castsShadow = true
        Ambient.shadowColor = NSColor.black.withAlphaComponent(CGFloat(Defaults.ShadowAlpha.rawValue))
        Ambient.shadowMode = .forward
        Ambient.shadowRadius = CGFloat(Defaults.ShadowRadius.rawValue)
        Ambient.color = NSColor.white
        AmbientLightNode = SCNNode()
        AmbientLightNode?.name = LightNames.Ambient2D.rawValue
        AmbientLightNode?.light = Ambient
        AmbientLightNode?.position = SCNVector3(0.0, 0.0, Defaults.AmbientLightZ.rawValue)
        self.scene?.rootNode.addChildNode(AmbientLightNode!)
        
        let AmbientSun = SCNLight()
        AmbientSun.name = LightNames.AmbientSun2D.rawValue
        AmbientSun.categoryBitMask = LightMasks2D.AmbientSun.rawValue
        AmbientSun.intensity = CGFloat(Defaults.AmbientLightIntensity.rawValue)
        AmbientSun.castsShadow = false
        AmbientSunLightNode = SCNNode()
        AmbientSunLightNode.name = LightNames.AmbientSun2D.rawValue
        AmbientSunLightNode.light = AmbientSun
        self.scene?.rootNode.addChildNode(AmbientSunLightNode)
    }
    
    /// Set up "sun light" for the scene.
    func SetSunlight()
    {
        SunLight = SCNLight()
        SunLight.name = LightNames.Sun2D.rawValue
        SunLight.categoryBitMask = LightMasks2D.Sun.rawValue
        SunLight.type = .omni
        SunLight.intensity = CGFloat(FlatConstants.SunLightIntensity.rawValue)
        SunLight.color = NSColor.white
        LightNode = SCNNode()
        LightNode.name = LightNames.Sun2D.rawValue
        LightNode.light = SunLight
        LightNode.position = SCNVector3(0.0, 0.0, 20.0)//FlatConstants.SunLightZ.rawValue)
        self.scene?.rootNode.addChildNode(LightNode)
    }
    
    func SetHourLight()
    {
        HourLight = SCNLight()
        HourLight.name = LightNames.Hour2D.rawValue
        HourLight.categoryBitMask = LightMasks2D.Hours.rawValue
        HourLight.type = .directional
        HourLight.color = NSColor.white
        HourLightNode = SCNNode()
        HourLightNode.name = LightNames.Hour2D.rawValue
        HourLightNode.light = HourLight
        HourLightNode.position = SCNVector3(0.0, 0.0, 20.0)
        self.scene?.rootNode.addChildNode(HourLightNode)
    }
    
    /// Create the polar light.
    func SetPolarLight()
    {
        PolarLight = SCNLight()
        PolarLight.name = LightNames.Polar2D.rawValue
        PolarLight.categoryBitMask = LightMasks2D.Polar.rawValue
        PolarLight.type = .spot
        PolarLight.intensity = CGFloat(FlatConstants.PolarLightIntensity.rawValue)
        PolarLight.castsShadow = true
        PolarLight.shadowColor = NSColor.black.withAlphaComponent(CGFloat(Defaults.ShadowAlpha.rawValue))
        PolarLight.shadowMode = .forward
        PolarLight.shadowRadius = CGFloat(Defaults.ShadowRadius.rawValue)
        PolarLight.shadowSampleCount = 1
        PolarLight.shadowMapSize = CGSize(width: Int(FlatConstants.ShadowMapSide.rawValue),
                                          height: Int(FlatConstants.ShadowMapSide.rawValue))
        PolarLight.automaticallyAdjustsShadowProjection = true
        PolarLight.shadowCascadeCount = 3
        PolarLight.shadowCascadeSplittingFactor = CGFloat(FlatConstants.ShadowSplitting.rawValue)
        PolarLight.color = NSColor.white
        PolarLight.zFar = CGFloat(FlatConstants.PolarZFar.rawValue)
        PolarLight.zNear = CGFloat(FlatConstants.PolarZNear.rawValue)
        PolarLight.spotOuterAngle = CGFloat(FlatConstants.PolarLightOuterAngle.rawValue)
        PolarNode = SCNNode()
        PolarNode.name = LightNames.Polar2D.rawValue
        PolarNode.light = PolarLight
        let PolarNodeY = CGFloat(FlatConstants.FlatRadius.rawValue) + CGFloat(FlatConstants.PolarSunRimOffset.rawValue)
        PolarNode.position = SCNVector3(0.0, PolarNodeY, CGFloat(FlatConstants.PolarLightZTerminal.rawValue))
        let XOrientation = CGFloat(FlatConstants.PolarLightXOrientation.rawValue.Radians)
        PolarNode.eulerAngles = SCNVector3(-XOrientation, 0.0, 0.0)
        self.scene?.rootNode.addChildNode(PolarNode)
    }
    
    /// Create a not-ver-smooth arc of points (smoothness depends on the `Step` count) along the Y axis with
    /// varying Z values. All X values are set to 0.
    /// - Warning: A fatal error is thrown if the number of steps is less than `1`.
    /// - Parameter Start: The starting point.
    /// - Parameter MaxHeight: The maximum height at the peak of the arc. Assumed to be in the middled of
    ///                        the Y span.
    /// - Parameter Steps: Number of steps between `Start` and `End`.
    /// - Parameter End: The ending point.
    /// - Returns: Array of points that define a crude arc.
    func MakeArcPoints(Start: SCNVector3, MaxHeight: CGFloat, Steps: Int, End: SCNVector3) -> [SCNVector3]
    {
        if Steps < 1
        {
            fatalError("Steps must be 1 or greater. \(#function)")
        }
        var Points = [SCNVector3]()
        Points.append(Start)
        let YLength = abs(Start.y - End.y)
        let YStep = YLength / CGFloat(Steps + 1)
        let MiddleZ = Int(Double(Steps) / 2.0)
        let MZStep = (MaxHeight) / CGFloat(MiddleZ)
        var ZSteps = [CGFloat]()
        for z in 1 ... Steps
        {
            ZSteps.append((CGFloat(z) * MZStep) + Start.z)
        }

        if Steps.isMultiple(of: 2)
        {
            var scratch = [CGFloat]()
            while ZSteps.count > MiddleZ
            {
                ZSteps.removeLast()
            }
            scratch = ZSteps
            ZSteps.removeLast()
            for Index in stride(from: ZSteps.count - 1, to: -1, by: -1)
            {
                scratch.append(ZSteps[Index])
            }
            ZSteps = scratch
        }
        else
        {
            var scratch = [CGFloat]()
            while ZSteps.count > MiddleZ + 1
            {
                ZSteps.removeLast()
            }
            scratch = ZSteps
            ZSteps.removeLast()
            for Index in stride(from: ZSteps.count - 1, to: -1, by: -1)
            {
                scratch.append(ZSteps[Index])
            }
            ZSteps = scratch
        }
        ZSteps.insert(Start.z, at: 0)
        ZSteps.append(End.z)
        
        let YMultiplier: CGFloat = Start.y < End.y ? 1.0 : -1.0
        var PreviousY  = Start.y
        for Y in 1 ... Steps
        {
            let PointY = PreviousY + (YStep * YMultiplier)
            PreviousY = PointY
            let Point = SCNVector3(0.0, PointY, ZSteps[Y])
            Points.append(Point)
        }
        Points.append(End)
        return Points
    }
    
    func MakeSemiCirclePoints(Radius: Double, Steps: Int, ZBase: Double) -> [SCNVector3]
    {
        var Results = [SCNVector3]()
        
        for Step in 1 ... Steps
        {
            let Angle = Double(Step) / 180.0
            let Radians = Angle.Radians
            let X = Radius * cos(Radians)
            let Y = Radius * sin(Radians)
            //Since the result will be used for elevation, we "reassign" coordinates - X becomes Y and Y becomes Z.
            //X is assumed to be zero.
            let Point = SCNVector3(0.0, X, Y + ZBase)
            Results.append(Point)
        }
        
        return Results
    }
    
    /// Move the polar light to the appropriate pole to cast shadows.
    /// - Note: The 2D sun node is also moved along with the light.
    /// - Parameter ToNorth: Determines if the polar light is moved to the north or south pole.
    func MovePolarLight(ToNorth: Bool)
    {
        var LightPath = [SCNVector3]()
        if ToNorth
        {
            let EndingY = CGFloat(FlatConstants.FlatRadius.rawValue) + CGFloat(FlatConstants.PolarSunRimOffset.rawValue)
            #if false
            let PathRadius = FlatConstants.FlatRadius.rawValue + FlatConstants.PolarSunRimOffset.rawValue
            LightPath = MakeSemiCirclePoints(Radius: PathRadius, Steps: 10, ZBase: Double(PolarNode.position.z))
            #else
            LightPath = MakeArcPoints(Start: PolarNode.position,
                                      MaxHeight: CGFloat(FlatConstants.MaxArcHeight.rawValue),
                                      Steps: Int(FlatConstants.ArcStepCount.rawValue),
                                      End: SCNVector3(0.0, EndingY, PolarNode.position.z))
            #endif
        }
        else
        {
            let EndingY = -(CGFloat(FlatConstants.FlatRadius.rawValue) + CGFloat(FlatConstants.PolarSunRimOffset.rawValue))
            #if false
            let PathRadius = FlatConstants.FlatRadius.rawValue + FlatConstants.PolarSunRimOffset.rawValue
            LightPath = MakeSemiCirclePoints(Radius: PathRadius, Steps: 10, ZBase: Double(PolarNode.position.z))
            LightPath.reverse()
            #else
            LightPath = MakeArcPoints(Start: PolarNode.position,
                                      MaxHeight: CGFloat(FlatConstants.MaxArcHeight.rawValue),
                                      Steps: Int(FlatConstants.ArcStepCount.rawValue),
                                      End: SCNVector3(0.0, EndingY, PolarNode.position.z))
            #endif
        }
        
        let OverallDuration = FlatConstants.PolarAnimationDuration.rawValue
        let XOrientation = CGFloat(FlatConstants.PolarLightXOrientation.rawValue.Radians)
        var NewPitch: CGFloat = 0.0
        if ToNorth
        {
            NewPitch = -XOrientation
        }
        else
        {
            NewPitch = XOrientation
        }
        
        let SegmentDuration = OverallDuration / Double(LightPath.count - 1)
        var ArcSegments = [SCNAction]()
        for Index in 1 ..< LightPath.count
        {
            let Motion = SCNAction.move(to: SCNVector3(0.0, LightPath[Index].y, LightPath[Index].z), duration: SegmentDuration)
            ArcSegments.append(Motion)
        }
        let MotionSequence = SCNAction.sequence(ArcSegments)
        
        let IntensityAnimation = SCNAction.customAction(duration: OverallDuration)
        {
            Node, Elapsed in
            let PercentElapsed = Elapsed / CGFloat(OverallDuration)
            var Percent = PercentElapsed > 0.5 ? 1.0 - PercentElapsed : PercentElapsed
            Percent = 1.0 - Percent
            Node.light?.intensity = CGFloat(FlatConstants.PolarLightIntensity.rawValue) * Percent
        }
        
        let Pitch = SCNAction.rotateTo(x: NewPitch, y: 0.0, z: 0.0, duration: OverallDuration)
        let Batch = SCNAction.group([MotionSequence, Pitch, IntensityAnimation])
        PolarNode.runAction(Batch)
        {
            self.PolarNode.removeAllAnimations()
        }
        let SunPoleOrientation = SCNAction.rotateTo(x: CGFloat(180.0.Radians), y: 0.0, z: 0.0,
                                                    duration: OverallDuration)
        let SunBatch = SCNAction.group([MotionSequence, SunPoleOrientation])
        SunNode.runAction(SunBatch)
        {
            self.SunNode.removeAllAnimations()
        }
    }
    
    /// Set the light for the grid.
    func SetGridLight()
    {
        GridLight = SCNLight()
        GridLight.type = .omni
        GridLight.color = NSColor.white
        GridLight.categoryBitMask = LightMasks2D.Grid.rawValue
        GridLightNode = SCNNode()
        GridLightNode.castsShadow = false
        GridLightNode.light = GridLight
        GridLightNode.position = SCNVector3(0.0, 0.0, FlatConstants.GridLightZ.rawValue)
        self.scene?.rootNode.addChildNode(GridLightNode)
    }
}
