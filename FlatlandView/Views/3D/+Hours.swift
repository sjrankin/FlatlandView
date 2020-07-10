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
    /// Convience function to update the hours by those callers who do not want to worry about
    /// the internals of doing so.
    func UpdateHours()
    {
        UpdateHourLabels(With: Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self, Default: .None))
    }
    
    /// Update the globe display with the specified hour types.
    /// - Note: If `InVersionDisplayMode` is true, a special case is executed and control returned
    ///         before any other cases are executed. Also, the current declination is ignored if
    ///         `InVersionDisplayMode` is true.
    /// - Parameter With: The hour type to display.
    func UpdateHourLabels(With: HourValueTypes)
    {
        HourNode?.removeAllActions()
        HourNode?.removeFromParentNode()
        HourNode = nil
        switch With
        {
            case .None:
                break
            
            case .Solar:
                HourNode = DrawHourLabels(Radius: Double(GlobeRadius.HourSphere.rawValue))
                let Declination = Sun.Declination(For: Date())
                HourNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
                self.scene?.rootNode.addChildNode(HourNode!)
            
            case .RelativeToNoon:
                HourNode = DrawHourLabels(Radius: Double(GlobeRadius.HourSphere.rawValue))
                let Declination = Sun.Declination(For: Date())
                HourNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
                self.scene?.rootNode.addChildNode(HourNode!)
            
            case .RelativeToLocation:
                HourNode = DrawHourLabels(Radius: Double(GlobeRadius.HourSphere.rawValue))
                SystemNode?.addChildNode(HourNode!)
        }
        PreviousHourType = With
    }
    
    /// Create an hour node with labels.
    /// - Note: `.RelativeToLocation` is not available if the user has not entered his location.
    ///         If no local information is available, nil is returned.
    /// - Parameter Radius: Radial value for where to place hour labels.
    /// - Returns: The node with the hour labels. Nil if the user does not want to display hours or if
    ///            `.RelativeToLocation` is selected but no local information is available.
    func DrawHourLabels(Radius: Double) -> SCNNode?
    {
        switch Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self, Default: .None)
        {
            case .None:
                return nil
            
            case .Solar:
                return MakeNoonHours(Radius: Radius)
            
            case .RelativeToNoon:
                return MakeNoonDeltaHours(Radius: Radius)
            
            case .RelativeToLocation:
                if Settings.GetDoubleNil(.LocalLatitude) == nil ||
                    Settings.GetDoubleNil(.LocalLongitude) == nil
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
    func MakeNoonHours(Radius: Double) -> SCNNode
    {
        let NodeShape = SCNSphere(radius: CGFloat(Radius))
        let Node = SCNNode(geometry: NodeShape)
        Node.position = SCNVector3(0.0, 0.0, 0.0)
        Node.geometry?.firstMaterial?.diffuse.contents = NSColor.clear
        Node.geometry?.firstMaterial?.specular.contents = NSColor.clear
        Node.name = GlobeNodeNames.HourNode.rawValue
        var HourLabelList = [(String, Int)]()
        
        for Hour in 0 ... 23
        {
            let SolarHours = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]
            let DisplayHour = SolarHours[(Hour + 6) % 24]
            let DisplayString = GetScriptHours("\(DisplayHour)", Actual: DisplayHour)
            HourLabelList.append((DisplayString, DisplayHour))
        }
        let Color = Settings.GetColor(.HourColor, NSColor.systemOrange)
        return PlotHourLabels(Radius: Radius, Labels: HourLabelList, LetterColor: Color, RadialOffset: 6.0)
    }
    
    /// Make the hour node such that each label shows number of hours away from noon.
    /// - Parameter Radius: The radius of the hour label.
    /// - Returns: Node with labels set up for noon delta.
    func MakeNoonDeltaHours(Radius: Double) -> SCNNode
    {
        let NodeShape = SCNSphere(radius: CGFloat(Radius))
        let Node = SCNNode(geometry: NodeShape)
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
        return PlotHourLabels(Radius: Radius, Labels: HourLabelList, LetterColor: Color, RadialOffset: 6.0)
    }
    
    /// Make the hour node such that `0` is always under the user's location (if set) with offsets
    /// for the other hour labels.
    /// - Parameter Radius: The radius of the hour label.
    /// - Returns: Node with labels set up for current location.
    func MakeRelativeHours(Radius: Double) -> SCNNode
    {
        let NodeShape = SCNSphere(radius: CGFloat(Radius))
        let Node = SCNNode(geometry: NodeShape)
        Node.position = SCNVector3(0.0, 0.0, 0.0)
        Node.geometry?.firstMaterial?.diffuse.contents = NSColor.clear
        Node.geometry?.firstMaterial?.specular.contents = NSColor.clear
        Node.name = GlobeNodeNames.HourNode.rawValue
        
        var HourList = [0, -1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
        HourList = HourList.Shift(By: -6)
        let LocalLongitude = Settings.GetDoubleNil(.LocalLongitude)!
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
        return PlotHourLabels(Radius: Radius, Labels: HourLabelList, LetterColor: Color)
    }
    
    /// Given an array of words, place a set of words in the hour ring over the Earth.
    /// - Note: Pay attention to the word order - it must be reversed in `Words` in order for
    ///         words to appear correctly as people would expect.
    /// - Parameter Radius: The radius of the word.
    /// - Parameter Labels: Array of hour values (if order is significant, the first word in the order
    ///                    must be the last entry in the array) to display as expected. Also contains
    ///                    corresponding actual value.
    /// - Parameter LetterColor: The color to use for the diffuse surface.
    /// - Parameter RadialOffset: Offset value for adjusting the final location of the letter in orbit.
    /// - Returns: Node for words in the hour ring.
    func PlotHourLabels(Radius: Double, Labels: [(String, Int)], LetterColor: NSColor = NSColor.systemYellow,
                        RadialOffset: CGFloat = 0.0) -> SCNNode
    {
        print("Plotting hours")
        let NodeShape = SCNSphere(radius: CGFloat(Radius))
        let Node = SCNNode(geometry: NodeShape)
        Node.position = SCNVector3(0.0, 0.0, 0.0)
        Node.geometry?.firstMaterial?.diffuse.contents = NSColor.clear
        Node.geometry?.firstMaterial?.specular.contents = NSColor.clear
        Node.name = GlobeNodeNames.HourNode.rawValue

        let VisualScript = Settings.GetEnum(ForKey: .Script, EnumType: Scripts.self, Default: .English)
        
        let StartAngle = 0
        var Angle = StartAngle
        for Label in Labels
        {
            let Actual = Label.1
            var WorkingAngle: CGFloat = CGFloat(Angle) + RadialOffset
            var PreviousEnding: CGFloat = 0.0
            var TotalLabelWidth: CGFloat = 0.0
            var LabelHeight: CGFloat = 0.0
            let LabelNode = SCNNode()
            let VerticalOffset: CGFloat = 0.8
            let SpecularColor = NSColor.white
            for (_, Letter) in Label.0.enumerated()
            {
                let Radians = WorkingAngle.Radians
                let HourText = SCNText(string: String(Letter), extrusionDepth: 5.0)
                let FontSize: CGFloat = VisualScript == .English ? 20.0 : 14.0
                #if true
                let FontData = Settings.GetFont(.HourFontName, StoredFont("Avenir-Medium", 20.0, NSColor.yellow))
                HourText.font = NSFont(name: FontData.PostscriptName, size: FontSize)
                #else
                HourText.font = NSFont(name: "Avenir-Heavy", size: FontSize)
                #endif
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
                    PreviousEnding = CGFloat(10.0)
                }
                if Letter == "1"
                {
                    PreviousEnding = CGFloat(6.0)
                }
                let DeltaHeight = abs(HourText.boundingBox.max.y - HourText.boundingBox.min.y)
                if CGFloat(DeltaHeight) > LabelHeight
                {
                    LabelHeight = CGFloat(DeltaHeight)
                }
                WorkingAngle = WorkingAngle - (PreviousEnding * 0.5)
                var FinalLetterColor = LetterColor
                if VisualScript != .English
                {
                    if Actual < 0
                    {
                        FinalLetterColor = NSColor.red
                    }
                    if Actual > 0
                    {
                        FinalLetterColor = NSColor.green
                    }
                    if Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self, Default: .None) == .Solar
                    {
                        FinalLetterColor = LetterColor
                    }
                }
                HourText.firstMaterial?.diffuse.contents = FinalLetterColor
                HourText.firstMaterial?.specular.contents = SpecularColor
                HourText.flatness = 0.2
                let X = CGFloat(Radius) * cos(Radians)
                let Z = CGFloat(Radius) * sin(Radians)
                let HourTextNode = SCNNode(geometry: HourText)
                HourTextNode.categoryBitMask = SunMask | MoonMask
                HourTextNode.scale = SCNVector3(NodeScales.HourText.rawValue,
                                                NodeScales.HourText.rawValue,
                                                NodeScales.HourText.rawValue)
                HourTextNode.position = SCNVector3(X, -VerticalOffset, Z)
                let HourRotation = (90.0 - Double(WorkingAngle)).Radians
                HourTextNode.eulerAngles = SCNVector3(0.0, HourRotation, 0.0)
                LabelNode.addChildNode(HourTextNode)
                TotalLabelWidth = TotalLabelWidth + (CGFloat(CharWidth) + PreviousEnding)
            }
            let LastAngle = CGFloat(Angle).Radians
            let FinalX = CGFloat(0) * cos(LastAngle)
            let FinalZ = CGFloat(0) * sin(LastAngle)
            let YOffset = -(LabelHeight * 0.07) / 8.0
            LabelNode.position = SCNVector3(FinalX, YOffset, FinalZ)
            Node.addChildNode(LabelNode)
            
            //Adjust the angle by one hour.
            Angle = Angle + 15
        }
        
        return Node
    }
}
