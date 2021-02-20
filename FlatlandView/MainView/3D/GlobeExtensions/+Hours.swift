//
//  +Hours.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/29/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension GlobeView
{
    // MARK: - Hour plotting and handling
    
    /// Convenience function to update the hours by those callers who do not want to worry about
    /// the internals of doing so.
    func UpdateHours()
    {
        UpdateHourLabels(With: Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self, Default: .None))
    }
    
    /// Remove the hour container node.
    private func RemoveHours()
    {
        HourNode?.removeAllActions()
        HourNode?.removeFromParentNode()
        HourNode = nil
    }
    
    /// Update the globe display with the specified hour types.
    /// - Parameter With: The hour type to display.
    func UpdateHourLabels(With: HourValueTypes)
    {
        switch With
        {
            case .None:
                if let Container = HourNode
                {
                    let Shrink = SCNAction.scale(to: 0.001, duration: HourConstants.RemoveDuration.rawValue)
                    let NodeCount = Container.childNodes.count
                    var Count = 0
                    for HourChild in Container.childNodes
                    {
                        if let Child = HourChild as? SCNNode2
                        {
                            if Count < NodeCount - 1
                            {
                                Child.runAction(Shrink)
                            }
                            else
                            {
                                //Remove the hour container node after the last action has run.
                                Child.runAction(Shrink)
                                {
                                    self.RemoveHours()
                                }
                            }
                        }
                        Count = Count + 1
                    }
                }
                
            case .Solar:
                WallClockTimer?.invalidate()
                WallClockTimer = nil
                RemoveHours()
                HourNode = DrawHourLabels(Radius: Double(GlobeRadius.HourSphere.rawValue))
                let Declination = Sun.Declination(For: Date())
                HourNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
                self.scene?.rootNode.addChildNode(HourNode!)
                
            case .RelativeToNoon:
                WallClockTimer?.invalidate()
                WallClockTimer = nil
                RemoveHours()
                HourNode = DrawHourLabels(Radius: Double(GlobeRadius.HourSphere.rawValue))
                let Declination = Sun.Declination(For: Date())
                HourNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
                self.scene?.rootNode.addChildNode(HourNode!)
                
            case .RelativeToLocation:
                WallClockTimer?.invalidate()
                WallClockTimer = nil
                RemoveHours()
                HourNode = DrawHourLabels(Radius: Double(GlobeRadius.HourSphere.rawValue))
                SystemNode?.addChildNode(HourNode!)
                
            case .WallClock:
                RemoveHours()
                HourNode = DrawHourLabels(Radius: Double(GlobeRadius.WallClockSphere.rawValue))
                let Declination = Sun.Declination(For: Date())
                HourNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
                SystemNode?.addChildNode(HourNode!)
        }
        PreviousHourType = With
    }
    
    /// Update the flatness (smoothness) of the hours in the set of displayed hours.
    /// - Parameter To: New flatness level. Smaller values draw smoother text.
    func ChangeHourFlatness(To NewFlatness: CGFloat)
    {
        if let Hours = HourNode
        {
            for Phrase in Hours.childNodes
            {
                for LabelNode in Phrase.childNodes
                {
                    if let Label = LabelNode.geometry as? SCNText
                    {
                        Label.flatness = NewFlatness
                    }
                }
            }
        }
    }
    
    /// Intended to be called when the user moves the camera closer or farther away from the Earth node to
    /// update the flatness level of the hours. When the camera is closer, the flatness level will result in
    /// smoother numerals.
    /// - Note: Distances that result in the same flatness level as the previous call will take no action -
    ///         control will return as soon as that condition is detected.
    /// - Parameter Distance: Distance from the camera to the center of the Earth node.
    func UpdateFlatnessForCamera(Distance: CGFloat)
    {
        var FinalFlat: CGFloat? = nil
        let IDist = Int(Distance)
        for (Final, Min, Max) in FlatnessDistanceMap
        {
            if IDist >= Min && IDist <= Max
            {
                FinalFlat = Final
                break
            }
        }
        if FinalFlat == nil
        {
            FinalFlat = FlatnessDistanceMap.last!.FlatLevel
        }
        if PreviousHourFlatnessLevel == nil
        {
            PreviousHourFlatnessLevel = FinalFlat
        }
        else
        {
            if PreviousHourFlatnessLevel! == FinalFlat!
            {
                return
            }
            PreviousHourFlatnessLevel = FinalFlat
        }
        ChangeHourFlatness(To: FinalFlat!)
    }
    
    /// Create an hour node with labels.
    /// - Note: `.RelativeToLocation` is not available if the user has not entered his location.
    ///         If no local information is available, nil is returned.
    /// - Parameter Radius: Radial value for where to place hour labels.
    /// - Returns: The node with the hour labels. Nil if the user does not want to display hours or if
    ///            `.RelativeToLocation` is selected but no local information is available.
    func DrawHourLabels(Radius: Double) -> SCNNode2?
    {
        switch Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self, Default: .None)
        {
            case .None:
                return nil
                
            case .Solar:
                return MakeNoonHours(Radius: Radius)
                
            case .RelativeToNoon:
                return MakeNoonDeltaHours(Radius: Radius)
                
            case .WallClock:
                return MakeWallClockHours(Radius: Radius)
                
            case .RelativeToLocation:
                if Settings.GetDoubleNil(.UserHomeLatitude) == nil ||
                    Settings.GetDoubleNil(.UserHomeLongitude) == nil
                {
                    return nil
                }
                return MakeRelativeHours(Radius: Radius)
        }
    }
    
    /// Returns a string in the user-set script for the hours.
    /// - Parameter Raw: The raw value returned if there is no script equivalent for the native value.
    /// - Parameter Actual: The actual numerical value.
    /// - Returns: The string value to use to display hours.
    func GetScriptHours(_ Raw: String, Actual: Int) -> String
    {
        switch Settings.GetEnum(ForKey: .Script, EnumType: Scripts.self, Default: .English)
        {
            case .English:
                return Raw
                
            case .Japanese:
                let JValue = JapaneseHours[abs(Actual)]!
                return JValue
        }
    }
    
    /// Make the hour node such that `12` is always under the noon longitude and `0` under midnight.
    /// - Parameter Radius: The radius of the hour label.
    /// - Returns: Node with labels set up for noontime.
    func MakeNoonHours(Radius: Double) -> SCNNode2
    {
        let NodeShape = SCNSphere(radius: CGFloat(Radius))
        let Node = SCNNode2(geometry: NodeShape)
        Node.position = SCNVector3(0.0, 0.0, 0.0)
        Node.geometry?.firstMaterial?.diffuse.contents = NSColor.clear
        Node.geometry?.firstMaterial?.specular.contents = NSColor.clear
        Node.name = GlobeNodeNames.HourNode.rawValue
        var HourLabelList = [(String, Int)]()
        
        for Hour in 0 ... 23
        {
            let SolarHours = [23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0]
            let DisplayHour = SolarHours[(Hour + 6) % 24]
            let DisplayString = GetScriptHours("\(DisplayHour)", Actual: DisplayHour)
            HourLabelList.append((DisplayString, DisplayHour))
        }
        let Color = Settings.GetColor(.HourColor, NSColor.systemOrange)
        return PlotHourLabels(Radius: Radius, Labels: HourLabelList, LetterColor: Color, RadialOffset: 3.0,
                              StartAngle: 360.0 / 24.0)
    }
    
    /// Make the hour node such that each label shows number of hours away from noon.
    /// - Parameter Radius: The radius of the hour label.
    /// - Returns: Node with labels set up for noon delta.
    func MakeNoonDeltaHours(Radius: Double) -> SCNNode2
    {
        let NodeShape = SCNSphere(radius: CGFloat(Radius))
        let Node = SCNNode2(geometry: NodeShape)
        Node.position = SCNVector3(0.0, 0.0, 0.0)
        Node.geometry?.firstMaterial?.diffuse.contents = NSColor.clear
        Node.geometry?.firstMaterial?.specular.contents = NSColor.clear
        Node.name = GlobeNodeNames.HourNode.rawValue
        var HourLabelList = [(String, Int)]()
        
        for Hour in 0 ... 23
        {
            //Calculate the display hour.
            var DisplayHour = 24 - (Hour + 5) % 24 - 1
            DisplayHour = DisplayHour - 12
            var Prefix = ""
            if DisplayHour > 0
            {
                Prefix = "+"
            }
            let DisplayString = GetScriptHours("\(DisplayHour)", Actual: DisplayHour)
            if Settings.GetEnum(ForKey: .Script, EnumType: Scripts.self, Default: .English) != .English
            {
                Prefix = ""
            }
            HourLabelList.append(("\(Prefix)\(DisplayString)", DisplayHour))
        }
        let Color = Settings.GetColor(.HourColor, NSColor.systemOrange)
        return PlotHourLabels(Radius: Radius, Labels: HourLabelList, LetterColor: Color, RadialOffset: 3.0, StartAngle: 0.0)
    }
    
    /// Make wall-clock hours over each major longitude line.
    /// - Parameter Radius: The radius of the sphere that holds the hours.
    /// - Returns: Node that holds the wall clock hours.
    func MakeWallClockHours(Radius: Double) -> SCNNode2
    {
        let Color = Settings.GetColor(.HourColor, NSColor.systemOrange)
        return PlotWallClockLabels(Radius: Radius, LetterColor: Color, RadialOffset: 3.0,
                              StartAngle: 360.0 / 24.0)
    }
    
    /// Make the hour node such that `0` is always under the user's location (if set) with offsets
    /// for the other hour labels.
    /// - Parameter Radius: The radius of the hour label.
    /// - Returns: Node with labels set up for current location.
    func MakeRelativeHours(Radius: Double) -> SCNNode2
    {
        let NodeShape = SCNSphere(radius: CGFloat(Radius))
        let Node = SCNNode2(geometry: NodeShape)
        Node.position = SCNVector3(0.0, 0.0, 0.0)
        Node.geometry?.firstMaterial?.diffuse.contents = NSColor.clear
        Node.geometry?.firstMaterial?.specular.contents = NSColor.clear
        Node.name = GlobeNodeNames.HourNode.rawValue
        
        var HourList = [0, -1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
        HourList = HourList.Shift(By: -6)
        let LocalLongitude = Settings.GetDoubleNil(.UserHomeLongitude)!
        let Long = Int(LocalLongitude / 15.0)
        HourList = HourList.Shift(By: Long)
        var HourLabelList = [(String, Int)]()
        for Hour in 0 ... 23
        {
            let Hour = Hour % 24
            var Prefix = ""
            let DisplayHour = HourList[Hour]
            if DisplayHour > 0
            {
                Prefix = "+"
            }
            let DisplayString = GetScriptHours("\(DisplayHour)", Actual: DisplayHour)
            if Settings.GetEnum(ForKey: .Script, EnumType: Scripts.self, Default: .English) != .English
            {
                Prefix = ""
            }
            HourLabelList.append(("\(Prefix)\(DisplayString)", DisplayHour))
        }
        let Color = Settings.GetColor(.HourColor, NSColor.systemOrange)
        return PlotHourLabels(Radius: Radius, Labels: HourLabelList, LetterColor: Color, StartAngle: 0.0)
    }
    
    /// Plot wall-clock hours.
    /// - Parameter Radius: The radius of the sphere on which the time will be plotted.
    /// - Parameter LetterColor: The color of the labels.
    /// - Parameter RadialOffset: Optional radial offset. Defaults to `0.0`.
    /// - Parameter StartAngle: Starting angle of the hours.
    /// - Returns: Node that holds the wall clock hours.
    func PlotWallClockLabels(Radius: Double, LetterColor: NSColor = NSColor.systemYellow,
                             RadialOffset: CGFloat = 0.0, StartAngle: Double) -> SCNNode2
    {
        let NodeShape = SCNSphere(radius: CGFloat(Radius))
        let PhraseNode = SCNNode2(geometry: NodeShape)
        PhraseNode.castsShadow = Settings.GetBool(.HoursCastShadows)
        PhraseNode.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        PhraseNode.position = SCNVector3(0.0, 0.0, 0.0)
        PhraseNode.geometry?.firstMaterial?.diffuse.contents = NSColor.clear
        PhraseNode.geometry?.firstMaterial?.specular.contents = NSColor.clear
        PhraseNode.name = GlobeNodeNames.HourNode.rawValue

        
        let VisualScript = Settings.GetEnum(ForKey: .Script, EnumType: Scripts.self, Default: .English)
        let HourScale = Settings.GetEnum(ForKey: .HourScale, EnumType: MapNodeScales.self, Default: .Normal)
        var ScaleMultiplier = HourConstants.NormalScaleMultiplier.rawValue
        var VerticalOffset: CGFloat = CGFloat(HourConstants.NormalVerticalOffset.rawValue)
        var BigCharWidth: CGFloat = CGFloat(HourConstants.NormalBigCharWidth.rawValue)
        var SmallCharWidth: CGFloat = CGFloat(HourConstants.NormalSmallCharWidth.rawValue)
        switch HourScale
        {
            case .Small:
                ScaleMultiplier = HourConstants.SmallScaleMultiplier.rawValue
                VerticalOffset = CGFloat(HourConstants.SmallVerticalOffset.rawValue)
                BigCharWidth = CGFloat(HourConstants.SmallBigCharWidth.rawValue)
                SmallCharWidth = CGFloat(HourConstants.SmallSmallCharWidth.rawValue)
                
            case .Normal:
                ScaleMultiplier = HourConstants.NormalScaleMultiplier.rawValue
                VerticalOffset = CGFloat(HourConstants.NormalVerticalOffset.rawValue)
                BigCharWidth = CGFloat(HourConstants.NormalBigCharWidth.rawValue)
                SmallCharWidth = CGFloat(HourConstants.NormalSmallCharWidth.rawValue)
                
            case .Large:
                ScaleMultiplier = HourConstants.BigScaleMultiplier.rawValue
                VerticalOffset = CGFloat(HourConstants.BigVerticalOffset.rawValue)
                BigCharWidth = CGFloat(HourConstants.BigBigCharWidth.rawValue)
                SmallCharWidth = CGFloat(HourConstants.BigSmallCharWidth.rawValue)
        }
        
        for LabelAngle in stride(from: 0.0, to: 359.0, by: 15.0)
        {
            var WorkingAngle = StartAngle + LabelAngle - 15.0
            if WorkingAngle < 0.0
            {
                WorkingAngle = 360.0 + WorkingAngle
            }
            var Hour = Int(WorkingAngle / 15.0)
            if Hour > 12
            {
                Hour = 12 - (Hour - 12)
                Hour = Hour * -1
            }
            let UTC = Date().ToUTC()
            let Cal = Calendar.current
            let FinalDate = Cal.date(byAdding: .hour, value: Hour, to: UTC)
            let PrettyTime = Date.PrettyTime(From: FinalDate!, IncludeSeconds: false)
            let HourTextNode = MakeWallClockNode(WorkingAngle, ScaleMultiplier: ScaleMultiplier,
                                                 Value: PrettyTime, LetterColor: LetterColor)
            PhraseNode.addChildNode(HourTextNode)
        }

        WallStartAngle = StartAngle
        WallScaleMultiplier = ScaleMultiplier
        WallLetterColor = LetterColor
        let Now = Date()
        let Cal = Calendar.current
        let Seconds = Cal.component(.second, from: Now)
        let After = Double(60 - Seconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + After)
        {
            self.UpdateWallClockHours()
            self.WallClockTimer = Timer.scheduledTimer(timeInterval: 60.0,
                                                       target: self,
                                                       selector: #selector(self.UpdateWallClockHours),
                                                       userInfo: nil,
                                                       repeats: true)
        }
        return PhraseNode
    }
    
    /// Called once a minute to update the time for wall clock nodes.
    @objc func UpdateWallClockHours()
    {
        for Hour in HourNode!.childNodes
        {
            if let Node = Hour as? SCNNode2
            {
                if Node.IsTextNode
                {
                    Node.removeAllActions()
                    Node.removeAllAnimations()
                    Node.removeFromParentNode()
                }
            }
        }
        for LabelAngle in stride(from: 0.0, to: 359.0, by: 15.0)
        {
            var WorkingAngle = WallStartAngle + LabelAngle - 15.0
            if WorkingAngle < 0.0
            {
                WorkingAngle = 360.0 + WorkingAngle
            }
            var Hour = Int(WorkingAngle / 15.0)
            if Hour > 12
            {
                Hour = 12 - (Hour - 12)
                Hour = Hour * -1
            }
            let UTC = Date().ToUTC()
            let Cal = Calendar.current
            let FinalDate = Cal.date(byAdding: .hour, value: Hour, to: UTC)
            let PrettyTime = Date.PrettyTime(From: FinalDate!, IncludeSeconds: false)
            let HourTextNode = MakeWallClockNode(WorkingAngle, ScaleMultiplier: WallScaleMultiplier,
                                                 Value: PrettyTime, LetterColor: WallLetterColor)
            HourNode?.addChildNode(HourTextNode)
        }
    }
    
    /// Create an extruded time node to use as wall clock time.
    /// - Parameter WorkingAngle: Determines the location and the time to display.
    /// - Parameter ScaleMultiplier: How to scale the 3D node.
    /// - Parameter Value: The string to display.
    /// - Parameter LetterColor: The color of the node.
    /// - Returns: Node with extruded text oriented and located appropriately.
    func MakeWallClockNode(_ WorkingAngle: Double, ScaleMultiplier: Double, Value: String,
                           LetterColor: NSColor = NSColor.systemYellow) -> SCNNode2
    {
        let FlatnessValue: CGFloat = CGFloat(HourConstants.NormalFlatness.rawValue)
        let HourText = SCNText(string: Value, extrusionDepth: CGFloat(HourConstants.HourExtrusion.rawValue))
        let FontData = Settings.GetFont(.HourFontName, StoredFont("Avenir-Medium",
                                                                  CGFloat(HourConstants.EnglishFontSize.rawValue),
                                                                  NSColor.yellow))
        let FontSize: CGFloat = 12.0
        HourText.font = NSFont(name: FontData.PostscriptName, size: FontSize)
        HourText.firstMaterial?.diffuse.contents = LetterColor
        HourText.firstMaterial?.specular.contents = NSColor.white
        HourText.flatness = FlatnessValue
        let HourTextNode = SCNNode2(geometry: HourText)
        HourTextNode.IsTextNode = true
        HourTextNode.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        let FinalScale = CGFloat(ScaleMultiplier) * NodeScales3D.HourText.rawValue
        HourTextNode.scale = SCNVector3(FinalScale)
        let (X, Y, Z) = ToECEF(0.0, WorkingAngle, Radius: Double(GlobeRadius.HourSphere.rawValue))
        let HourHeight = HourTextNode.boundingBox.max.x - HourTextNode.boundingBox.min.x
        let YOffset = Double(HourHeight / 2.0 * FinalScale)
        HourTextNode.position = SCNVector3(X, Y + YOffset, Z)
        let XAngle = (180.0 - WorkingAngle - 180.0).Radians
        let YAngle = 0.0.Radians
        let ZAngle = -90.0.Radians
        HourTextNode.eulerAngles = SCNVector3(XAngle, YAngle, ZAngle)
        return HourTextNode
    }
    
    /// Given an array of words, place a set of words in the hour ring over the Earth.
    /// - Warning: A fatal error is generated if the hour type is `.None`. This should be caught before
    ///            calling this function.
    /// - Note: Pay attention to the word order - it must be reversed in `Words` in order for
    ///         words to appear correctly as people would expect.
    /// - Parameter Radius: The radius of the word.
    /// - Parameter Labels: Array of hour values (if order is significant, the first word in the order
    ///                    must be the last entry in the array) to display as expected. Also contains
    ///                    corresponding actual value.
    /// - Parameter LetterColor: The color to use for the diffuse surface.
    /// - Parameter RadialOffset: Offset value for adjusting the final location of the letter in orbit.
    /// - Parameter StartAngle: The angle at which to start plotting hours.
    /// - Returns: Node for words in the hour ring.
    func PlotHourLabels(Radius: Double, Labels: [(HourLabel: String, HourValue: Int)],
                        LetterColor: NSColor = NSColor.systemYellow,
                        RadialOffset: CGFloat = 0.0, StartAngle: Double) -> SCNNode2
    {
        let NodeShape = SCNSphere(radius: CGFloat(Radius))
        let PhraseNode = SCNNode2(geometry: NodeShape)
        PhraseNode.castsShadow = Settings.GetBool(.HoursCastShadows)
        PhraseNode.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        PhraseNode.position = SCNVector3(0.0, 0.0, 0.0)
        PhraseNode.geometry?.firstMaterial?.diffuse.contents = NSColor.clear
        PhraseNode.geometry?.firstMaterial?.specular.contents = NSColor.clear
        PhraseNode.name = GlobeNodeNames.HourNode.rawValue
        
        let VisualScript = Settings.GetEnum(ForKey: .Script, EnumType: Scripts.self, Default: .English)
        let HourScale = Settings.GetEnum(ForKey: .HourScale, EnumType: MapNodeScales.self, Default: .Normal)
        var ScaleMultiplier = HourConstants.NormalScaleMultiplier.rawValue
        var VerticalOffset: CGFloat = CGFloat(HourConstants.NormalVerticalOffset.rawValue)
        var BigCharWidth: CGFloat = CGFloat(HourConstants.NormalBigCharWidth.rawValue)
        var SmallCharWidth: CGFloat = CGFloat(HourConstants.NormalSmallCharWidth.rawValue)
        switch HourScale
        {
            case .Small:
                ScaleMultiplier = HourConstants.SmallScaleMultiplier.rawValue
                VerticalOffset = CGFloat(HourConstants.SmallVerticalOffset.rawValue)
                BigCharWidth = CGFloat(HourConstants.SmallBigCharWidth.rawValue)
                SmallCharWidth = CGFloat(HourConstants.SmallSmallCharWidth.rawValue)
                
            case .Normal:
                ScaleMultiplier = HourConstants.NormalScaleMultiplier.rawValue
                VerticalOffset = CGFloat(HourConstants.NormalVerticalOffset.rawValue)
                BigCharWidth = CGFloat(HourConstants.NormalBigCharWidth.rawValue)
                SmallCharWidth = CGFloat(HourConstants.NormalSmallCharWidth.rawValue)
                
            case .Large:
                ScaleMultiplier = HourConstants.BigScaleMultiplier.rawValue
                VerticalOffset = CGFloat(HourConstants.BigVerticalOffset.rawValue)
                BigCharWidth = CGFloat(HourConstants.BigBigCharWidth.rawValue)
                SmallCharWidth = CGFloat(HourConstants.BigSmallCharWidth.rawValue)
        }
        let IFStyle = Settings.GetEnum(ForKey: .InterfaceStyle, EnumType: InterfaceStyles.self,
                                       Default: .Normal)
        var FlatnessValue: CGFloat = CGFloat(HourConstants.NormalFlatness.rawValue)
        switch IFStyle
        {
            case .Maximum:
                FlatnessValue = CGFloat(HourConstants.HighPerformanceFlatness.rawValue)
                
            case .Minimal:
                FlatnessValue = CGFloat(HourConstants.LowPerformanceFlatness.rawValue)
                
            case .Normal:
                FlatnessValue = CGFloat(HourConstants.NormalFlatness.rawValue)
        }
        
        var Angle = StartAngle
        for Label in Labels
        {
            let Actual = Label.HourValue
            var WorkingAngle: CGFloat = CGFloat(Angle) + RadialOffset
            var PreviousEnding: CGFloat = 0.0
            var TotalLabelWidth: CGFloat = 0.0
            var LabelHeight: CGFloat = 0.0
            let LabelNode = SCNNode2()
            for (_, Letter) in Label.HourLabel.enumerated()
            {
                let Radians = WorkingAngle.Radians
                let HourText = SCNText(string: String(Letter), extrusionDepth: CGFloat(HourConstants.HourExtrusion.rawValue))
                var FontSize: CGFloat = VisualScript == .English ? CGFloat(HourConstants.EnglishFontSize.rawValue) :
                    CGFloat(HourConstants.OtherFontSize.rawValue)
                if Settings.GetBool(.UseHourChamfer)
                {
                    HourText.chamferRadius = CGFloat(HourConstants.HourChamfer.rawValue)
                }
                let FontData = Settings.GetFont(.HourFontName, StoredFont("Avenir-Medium", CGFloat(HourConstants.EnglishFontSize.rawValue), NSColor.yellow))
                HourText.font = NSFont(name: FontData.PostscriptName, size: FontSize)
                var CharWidth: Float = 0
                if Letter == " "
                {
                    CharWidth = 3.5
                }
                else
                {
                    CharWidth = Float(abs(HourText.boundingBox.max.x - HourText.boundingBox.min.x))
                }
                PreviousEnding = CGFloat(CharWidth)
                if ["0", "2", "3", "4", "5", "6", "7", "8", "9"].contains(Letter)
                {
                    PreviousEnding = BigCharWidth
                }
                if Letter == "1"
                {
                    PreviousEnding = SmallCharWidth
                }
                let DeltaHeight = abs(HourText.boundingBox.max.y - HourText.boundingBox.min.y)
                if CGFloat(DeltaHeight) > LabelHeight
                {
                    LabelHeight = CGFloat(DeltaHeight)
                }
                WorkingAngle = WorkingAngle - (PreviousEnding * 0.5)
                HourText.firstMaterial?.diffuse.contents =  NSColor(RGB: Colors3D.HourColor.rawValue)
                HourText.firstMaterial?.specular.contents = NSColor(RGB: Colors3D.HourSpecular.rawValue)
                HourText.flatness = FlatnessValue
                let X = CGFloat(Radius) * cos(Radians)
                let Z = CGFloat(Radius) * sin(Radians)
                let HourTextNode = SCNNode2(geometry: HourText)

                switch Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self, Default: .None)
                {
                    case .Solar:
                        if Label.HourValue <= 6 || Label.HourValue >= 18
                        {
                            HourTextNode.IsInDaylight = false
                            HourTextNode.geometry?.firstMaterial?.diffuse.contents = NSColor(RGB: Colors3D.HourColor.rawValue)
                            HourTextNode.geometry?.firstMaterial?.specular.contents = NSColor(RGB: Colors3D.HourSpecular.rawValue)
                            HourTextNode.geometry?.firstMaterial?.emission.contents = NSColor(RGB: Colors3D.GlowingHourColor.rawValue)
                        }
                        else
                        {
                            HourTextNode.IsInDaylight = true
                            HourTextNode.geometry?.firstMaterial?.diffuse.contents = NSColor(RGB: Colors3D.HourColor.rawValue)
                            HourTextNode.geometry?.firstMaterial?.specular.contents = NSColor(RGB: Colors3D.HourSpecular.rawValue)
                            HourTextNode.geometry?.firstMaterial?.emission.contents = NSColor.clear
                        }
                        
                    case .RelativeToNoon:
                        if [6, 7, 8, 9, 10, 11, -12, -11, -10, -9, -8, -7, -6].contains(Label.HourValue)
                        {
                            HourTextNode.IsInDaylight = false
                            HourTextNode.geometry?.firstMaterial?.diffuse.contents = NSColor(RGB: Colors3D.HourColor.rawValue)
                            HourTextNode.geometry?.firstMaterial?.specular.contents = NSColor(RGB: Colors3D.HourSpecular.rawValue)
                            HourTextNode.geometry?.firstMaterial?.emission.contents = NSColor(RGB: Colors3D.GlowingHourColor.rawValue)
                        }
                        else
                        {
                            HourTextNode.IsInDaylight = true
                            HourTextNode.geometry?.firstMaterial?.diffuse.contents = NSColor(RGB: Colors3D.HourColor.rawValue)
                            HourTextNode.geometry?.firstMaterial?.specular.contents = NSColor(RGB: Colors3D.HourSpecular.rawValue)
                            HourTextNode.geometry?.firstMaterial?.emission.contents = NSColor.clear
                        }
                        
                    case .RelativeToLocation:
                        let Day: EventAttributes =
                            {
                                let D = EventAttributes()
                                D.ForEvent = .SwitchToDay
                                D.Diffuse = NSColor(RGB: Colors3D.HourColor.rawValue)
                                D.Specular = NSColor(RGB: Colors3D.HourSpecular.rawValue)
                                D.Emission = nil
                                return D
                            }()
                        HourTextNode.AddEventAttributes(Event: .SwitchToDay, Attributes: Day)
                        let Night: EventAttributes =
                            {
                                let N = EventAttributes()
                                N.ForEvent = .SwitchToNight
                                N.Diffuse = NSColor(RGB: Colors3D.HourColor.rawValue)
                                N.Specular = NSColor(RGB: Colors3D.HourSpecular.rawValue)
                                N.Emission = NSColor(RGB: Colors3D.GlowingHourColor.rawValue)
                                return N
                            }()
                        HourTextNode.AddEventAttributes(Event: .SwitchToNight, Attributes: Night)
                        LabelNode.DoTestDaylight(#function)
                        
                    case .WallClock:
                        Debug.FatalError("WallClock found in function that does not handle WallClock.")
                        
                    default:
                        //We shouldn't get here, but just in case...
                        let Trace = Debug.PrettyStackTrace(Debug.StackFrameContents(8))
                        Debug.Print("Trace: \(Trace)")
                        Debug.FatalError("Dropped to end of case unexpectedly.")
                }
                
                HourTextNode.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                let FinalScale = CGFloat(ScaleMultiplier) * NodeScales3D.HourText.rawValue
                HourTextNode.scale = SCNVector3(FinalScale)
                HourTextNode.position = SCNVector3(X, -VerticalOffset, Z)
                let HourRotation = (90.0 - Double(WorkingAngle)).Radians
                HourTextNode.eulerAngles = SCNVector3(0.0, HourRotation, 0.0)
                HourTextNode.castsShadow = Settings.GetBool(.HoursCastShadows)
                LabelNode.addChildNode(HourTextNode)
                LabelNode.CanSwitchState = true

                TotalLabelWidth = TotalLabelWidth + (CGFloat(CharWidth) + PreviousEnding)
            }
            let LastAngle = CGFloat(Angle).Radians
            #if false
            let YOffset = -(LabelHeight * CGFloat(HourConstants.LabelHeightMultiplier.rawValue)) / CGFloat(HourConstants.LabelHeightDivisor.rawValue)
            LabelNode.position = SCNVector3(0.0, YOffset, 0.0)
            #else
            let FinalX = CGFloat(0) * cos(LastAngle)
            let FinalZ = CGFloat(0) * sin(LastAngle)
            let YOffset = -(LabelHeight * CGFloat(HourConstants.LabelHeightMultiplier.rawValue)) / CGFloat(HourConstants.LabelHeightDivisor.rawValue)
            LabelNode.position = SCNVector3(FinalX, YOffset, FinalZ)
            #endif
            LabelNode.Tag = Label.HourLabel
            if Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self, Default: .None) == .RelativeToLocation
            {
                if let HomeLonS = Settings.GetSecureString(.UserHomeLongitude)
                {
                    if let HomeLon = Double(HomeLonS)
                    {
                        let Offset = Double(Label.HourLabel)!
                        let FinalLongitude = HomeLon + (HourConstants.HourDistance.rawValue * Offset)
                        LabelNode.InitialAngle = FinalLongitude
                        LabelNode.SetLocation(0.0, FinalLongitude)
                    }
                }
            }
            PhraseNode.addChildNode(LabelNode)
            PhraseNode.CanSwitchState = true
            
            //Adjust the angle by one hour in distance.
            Angle = Angle + HourConstants.HourDistance.rawValue
        }
        
        return PhraseNode
    }
    
    /// Update the hour labels' longitude. Should be called every earth rotate time.
    /// - Note: This function should be called regularly to make sure glowing hour labels appear over the
    ///         night side and not the day side.
    /// - Parameter Percent: Percent of the day.
    func UpdateHourLongitudes(_ Percent: Double)
    {
        if PreviousLongitudePercent == nil
        {
            PreviousLongitudePercent = Percent
        }
        else
        {
            if Percent == PreviousLongitudePercent!
            {
                return
            }
        }
        PreviousLongitudePercent = Percent
        if let HourLabels = HourNode?.childNodes
        {
            for Hour in HourLabels
            {
                if let HourNode = Hour as? SCNNode2
                {
                    HourNode.TestDaylight()
                }
            }
        }
    }
}
