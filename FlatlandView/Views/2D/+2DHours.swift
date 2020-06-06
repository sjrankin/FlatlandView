//
//  +2DHours.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainView
{
    /// Draw hours. The hours that are drawn depends on user settings.
    func Show2DHours()
    {
        let ViewType = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter)
        if ViewType == .Globe3D || ViewType == .CubicWorld
        {
            HourLayer2D.isHidden = false
            HourLayer2D.layer!.sublayers?.removeAll()
            return
        }
        if Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self, Default: .None) != .None
        {
            HourLayer2D.isHidden = false
            HourLayer2D.layer!.zPosition = CGFloat(LayerZLevels.HourLayer.rawValue)
            HourLayer2D.layer!.sublayers?.removeAll()
            HourLayer2D.layer!.backgroundColor = NSColor.clear.cgColor
            
            let TextLayer = CALayer()
            TextLayer.zPosition = CGFloat(LayerZLevels.HourLayer.rawValue)
            let TextLayerRect = HourLayer2D.frame
            TextLayer.frame = TextLayerRect
            TextLayer.bounds = TextLayerRect
            TextLayer.backgroundColor = NSColor.clear.cgColor
            let RadialOffset: CGFloat = 20.0
            var Radius: CGFloat = 0.0
            if TextLayerRect.size.width > TextLayerRect.size.height
            {
                Radius = (TextLayerRect.size.height / 2.0) - RadialOffset
            }
            else
            {
                Radius = (TextLayerRect.size.width / 2.0) - RadialOffset
            }
            let HourType = Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self, Default: .None)
            var HourOffset: CGFloat = 0.0
            if HourType != .RelativeToLocation
            {
                let Rotation = CATransform3DMakeRotation(0.0, 0.0, 0.0, 1.0)
                HourLayer2D.layer!.transform = Rotation
            }
            else
            {
                HourOffset = -0.5
            }
            var HourList = [0, -1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
            var InitialOffset = 0
            if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .FlatSouthCenter
            {
                InitialOffset = 5
            }
            else
            {
                InitialOffset = 6
            }
            HourList = HourList.Shift(By: InitialOffset)
            if let LocalLongitude = Settings.GetDoubleNil(.LocalLongitude)
            {
                var Long = Int(LocalLongitude / 15.0)
                var Multiplier = 1
                if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .FlatSouthCenter
                {
                    Multiplier = -1
                }
                Long = Long * Int(Multiplier)
                HourList = HourList.Shift(By: Long)
            }
            for Hour in 0 ... 23
            {
                let Angle = (CGFloat(Hour) + HourOffset) / 24.0 * 360.0
                let Radial = Angle.Radians
                var DisplayHour = (Hour + 6) % 24
                var IncludeSign = false
                
                switch HourType
                {
                    case .Solar:
                        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .FlatNorthCenter
                        {
                            DisplayHour = 24 - (DisplayHour + 12) % 24
                    }
                    
                    case .RelativeToLocation:
                        //Only valid if the user has entered local coordinates.
                        IncludeSign = true
                        if let _ = Settings.GetDoubleNil(.LocalLongitude)
                        {
                            DisplayHour = HourList[Hour]
                    }
                    
                    case .RelativeToNoon:
                        IncludeSign = true
                        DisplayHour = DisplayHour - 12
                        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .FlatNorthCenter
                        {
                            DisplayHour = (DisplayHour + 12) % 24
                            if DisplayHour > 12
                            {
                                DisplayHour = DisplayHour - 24
                            }
                            DisplayHour = DisplayHour * -1
                    }
                    
                    default:
                        return
                }
                
                let TextNode = CATextLayer()
                let (AText, Width, Height) = MakeHourText(Hour: DisplayHour,
                                                          Font: NSFont.boldSystemFont(ofSize: 36.0),
                                                          Color: NSColor.yellow,
                                                          StrokeColor: NSColor.black,
                                                          StrokeThickness: -2,
                                                          IncludeSign: IncludeSign)
                TextNode.string = AText
                var X = CGFloat(Radius) * cos(Radial)
                var Y = CGFloat(Radius) * sin(Radial)
                X = X + HourLayer2D.bounds.size.width / 2.0
                X = X - (Width / 2.0)
                Y = Y + HourLayer2D.bounds.size.height / 2.0
                Y = Y - (Height / 2.0)
                TextNode.font = NSFont.systemFont(ofSize: 36.0)
                TextNode.fontSize = 36.0
                TextNode.alignmentMode = .center
                TextNode.foregroundColor = NSColor.yellow.cgColor
                TextNode.frame = CGRect(x: X, y: Y, width: Width, height: Height)
                TextNode.bounds = CGRect(x: 0, y: 0, width: Width, height: Height)
                let TextRotate = ((90.0 - Angle) + /*180.0*/0.0).Radians
                TextNode.transform = CATransform3DRotate(TextNode.transform, -TextRotate, 0.0, 0.0, 1.0)
                TextLayer.addSublayer(TextNode)
            }
            HourLayer2D.layer!.addSublayer(TextLayer)
        }
        else
        {
            HourLayer2D.isHidden = true
            HourLayer2D.layer!.sublayers?.removeAll()
        }
    }
    
    /// Make a nice-looking attributed text string to use as hour displays.
    /// - Parameter Hour: The hour value to display.
    /// - Parameter Font: The font of the hour value.
    /// - Parameter Color: The color of the text.
    /// - Parameter StrokeColor: The color of the stroke of the text.
    /// - Parameter StrokeThickness: The thickness of the stroke. Specify a negative number to ensure
    ///                              `Color` is used to fill the text.
    /// - Parameter IncludeSide: If true, "+" will prefix all positive numbers.
    /// - Returns: Tuple of the attributed string, the width of the text, and the height of the text.
    func MakeHourText(Hour: Int, Font: NSFont, Color: NSColor, StrokeColor: NSColor,
                      StrokeThickness: CGFloat, IncludeSign: Bool) -> (NSAttributedString, CGFloat, CGFloat)
    {
        var Sign = ""
        if IncludeSign
        {
            if Hour > 0
            {
                Sign = "+"
            }
        }
        let TextValue = "\(Sign)\(Hour)"
        let Attributes: [NSAttributedString.Key: Any] =
            [.font: Font as Any,
             .foregroundColor: Color.cgColor as Any,
             .strokeColor: StrokeColor.cgColor as Any,
             .strokeWidth: StrokeThickness as Any]
        let Final = NSAttributedString(string: TextValue, attributes: Attributes)
        let Size = TextValue.size(withAttributes: Attributes)
        return (Final, Size.width, Size.height)
    }
}
