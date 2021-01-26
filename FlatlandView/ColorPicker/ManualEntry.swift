//
//  ManualEntry.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/25/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension ColorPicker: NSTextFieldDelegate
{
    func PopulateManualWithColor(_ Color: NSColor)
    {
        let InputType = Settings.GetEnum(ForKey: .ColorInputType, EnumType: InputTypes.self, Default: .Normal)
        let Valid = Color.InRGB
        switch Settings.GetEnum(ForKey: .ColorPickerColorspace, EnumType: PickerColorspaces.self, Default: .RGB)
        {
            case .RGB:
                var Red: CGFloat = 0.0
                var Green: CGFloat = 0.0
                var Blue: CGFloat = 0.0
                var Alpha: CGFloat = 0.0
                Valid.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
                var FinalRed: String = ""
                var FinalGreen: String = ""
                var FinalBlue: String = ""
                var FinalAlpha: String = ""
                switch InputType
                {
                    case .Hex:
                        let IRed = Int(Red * 255.0)
                        FinalRed = "#" + String(IRed, radix: 16)
                        let IGreen = Int(Green * 255.0)
                        FinalGreen = "#" + String(IGreen, radix: 16)
                        let IBlue = Int(Blue * 255.0)
                        FinalBlue = "#" + String(IBlue, radix: 16)
                        let IAlpha = Int(Alpha * 255.0)
                        FinalAlpha = "#" + String(IAlpha, radix: 16)
                        
                    case .Integer:
                        FinalRed = "\(Int(Red * 255.0))"
                        FinalGreen = "\(Int(Green * 255.0))"
                        FinalBlue = "\(Int(Blue * 255.0))"
                        FinalAlpha = "\(Int(Alpha * 255.0))"
                        
                    case .Normal:
                        FinalRed = "\(Red)"
                        FinalGreen = "\(Green)"
                        FinalBlue = "\(Blue)"
                        FinalAlpha = "\(Alpha)"
                }
                
                Channel1Slider.doubleValue = Double(Red) * 1275.0
                Channel1Box.stringValue = FinalRed
                Channel2Slider.doubleValue = Double(Green) * 1275.0
                Channel2Box.stringValue = FinalGreen
                Channel3Slider.doubleValue = Double(Blue) * 1275.0
                Channel3Box.stringValue = FinalBlue
                Channel5Slider.doubleValue = Double(Alpha) * 1275.0
                Channel5Box.stringValue = FinalAlpha
                
            case .HSB:
                break
                
            case .CMYK:
                break
        }
    }
    
    func FormatValue(_ Value: Double, For: InputTypes, In Colorspace: PickerColorspaces) -> String
    {
        switch For
        {
            case .Hex:
                let IValue = Int(Value * 255.0)
                let HValue = String(IValue, radix: 16)
                return "#" + HValue
                
            case .Integer:
                let IValue = Int(Value * 255.0)
                return "\(IValue)"
                
            case .Normal:
                return "\(Value)"
        }
    }
    
    func UpdateFromManualSlider(_ Slider: NSSlider)
    {
        let InputType = Settings.GetEnum(ForKey: .ColorInputType, EnumType: InputTypes.self, Default: .Integer)
        let SliderValue = Slider.doubleValue / 1275.0
        let Normal = SliderValue / 255.0
        let CurrentSpace = Settings.GetEnum(ForKey: .ColorPickerColorspace, EnumType: PickerColorspaces.self, Default: .RGB)
        switch Slider
        {
            case Channel1Slider:
                Channel1Box.stringValue = FormatValue(Normal, For: InputType, In: CurrentSpace)
                
            case Channel2Slider:
                Channel2Box.stringValue = FormatValue(Normal, For: InputType, In: CurrentSpace)
                
            case Channel3Slider:
                Channel3Box.stringValue = FormatValue(Normal, For: InputType, In: CurrentSpace)
                
            case Channel4Slider:
                Channel4Box.stringValue = FormatValue(Normal, For: InputType, In: CurrentSpace)
                
            case Channel5Slider:
                Channel5Box.stringValue = FormatValue(Normal, For: InputType, In: CurrentSpace)
                
            default:
                return
        }
        let NewColor = ColorFromSliders()
        SetSourceColor(NewColor)
    }
    
    func ColorFromSliders() -> NSColor
    {
        let CurrentSpace = Settings.GetEnum(ForKey: .ColorPickerColorspace, EnumType: PickerColorspaces.self, Default: .RGB)
        switch CurrentSpace
        {
            case .RGB:
                let NRed = Channel1Slider.doubleValue / 1275.0
                let NGreen = Channel2Slider.doubleValue / 1275.0
                let NBlue = Channel3Slider.doubleValue / 1275.0
                var NAlpha = 1.0
                if ManualAlphaCheck.state == .on
                {
                    NAlpha = Channel5Slider.doubleValue / 1275.0
                }
                return NSColor(calibratedRed: CGFloat(NRed), green: CGFloat(NGreen),
                               blue: CGFloat(NBlue), alpha: CGFloat(NAlpha))
                
            case .HSB:
                let NHue = Channel1Slider.doubleValue / 1275.0
                let NSat = Channel2Slider.doubleValue / 1275.0
                let NBri = Channel3Slider.doubleValue / 1275.0
                var NAlpha = 1.0
                if ManualAlphaCheck.state == .on
                {
                    NAlpha = Channel5Slider.doubleValue / 1275.0
                }
                return NSColor(calibratedHue: CGFloat(NHue), saturation: CGFloat(NSat),
                               brightness: CGFloat(NBri), alpha: CGFloat(NAlpha))
                
            case .CMYK:
                let NCyan = Channel1Slider.doubleValue / 1275.0
                let NMagenta = Channel2Slider.doubleValue / 1275.0
                let NYellow = Channel3Slider.doubleValue / 1275.0
                let NBlack = Channel4Slider.doubleValue / 1275.0
                var NAlpha = 1.0
                if ManualAlphaCheck.state == .on
                {
                    NAlpha = Channel5Slider.doubleValue / 1275.0
                }
                return NSColor(deviceCyan: CGFloat(NCyan), magenta: CGFloat(NMagenta),
                               yellow: CGFloat(NYellow), black: CGFloat(NBlack),
                               alpha: CGFloat(NAlpha))
        }
    }
    
    func UpdateForColorspace(_ NewColorspace: PickerColorspaces)
    {
        switch NewColorspace
        {
            case .RGB:
                Channel4Box.isHidden = true
                Channel4Box.isEnabled = false
                Channel4Slider.isHidden = true
                Channel4Slider.isEnabled = false
                Channel4Label.isHidden = true
                Channel1Label.stringValue = "Red"
                Channel2Label.stringValue = "Green"
                Channel3Label.stringValue = "Blue"
                
            case .HSB:
                Channel4Box.isHidden = true
                Channel4Box.isEnabled = false
                Channel4Slider.isHidden = true
                Channel4Slider.isEnabled = false
                Channel4Label.isHidden = true
                
                Channel1Label.stringValue = "Hue"
                Channel2Label.stringValue = "Saturation"
                Channel3Label.stringValue = "Brightness"
                
            case .CMYK:
                Channel4Box.isHidden = false
                Channel4Box.isEnabled = true
                Channel4Slider.isHidden = false
                Channel4Slider.isEnabled = true
                Channel4Label.isHidden = false
                Channel1Label.stringValue = "Cyan"
                Channel2Label.stringValue = "Magenta"
                Channel3Label.stringValue = "Yellow"
                Channel4Label.stringValue = "Black"
        }
    }
    
    /// Edited the current color with the specified channel value and color space.
    func MakeNewColor(From Value: Double, For Channel: PickerColorChannels, In Colorspace: PickerColorspaces) -> NSColor?
    {
        if Value < 0.0 || Value > 1.0
        {
            print("Invalid normal value (\(Value)) passed to MakeNewColor for channel \(Channel)")
            return nil
        }
        switch Colorspace
        {
            case .RGB:
                var Red: CGFloat = 0.0
                var Green: CGFloat = 0.0
                var Blue: CGFloat = 0.0
                var Alpha: CGFloat = 0.0
                CurrentColor.InRGB.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
                switch Channel
                {
                    case .Red:
                        Red = CGFloat(Value)
                        
                    case .Green:
                        Green = CGFloat(Value)
                        
                    case .Blue:
                        Blue = CGFloat(Value)
                        
                    case .Alpha:
                        Alpha = CGFloat(Value)
                        
                    default:
                        return nil
                }
                let Final = NSColor(calibratedRed: Red, green: Green, blue: Blue, alpha: Alpha)
                return Final
                
            case .HSB:
                break
                
            case .CMYK:
                break
        }
        return nil
    }
    
    func controlTextDidEndEditing(_ obj: Notification)
    {
        if let Field = obj.object as? NSTextField
        {
            let CurrentColorSpace = Settings.GetEnum(ForKey: .ColorPickerColorspace, EnumType: PickerColorspaces.self,
                                                     Default: .RGB)
            let Channel = ColorChannelFromField(Field, Colorspace: CurrentColorSpace)
        }
    }
    
    func controlTextDidEndEditingX(_ obj: Notification)
    {
        if let TextField = obj.object as? NSTextField
        {
            let Raw = TextField.stringValue
            let Result = InputValidation.ChannelValidation(Raw)
            var FinalValue: Double = 0.0
            var InputType = NumericValueTypes.Integer
            var WasAnError = ValidationResult.Success
            switch Result
            {
                case .failure(let Why):
                    WasAnError = Why
                    
                case .success(let (Value, ValueInputType)):
                    InputType = ValueInputType
                    FinalValue = Value
            }
            if WasAnError == .Success
            {
                if InputType != .Normal
                {
                    FinalValue = FinalValue / 255.0
                }
            }
            switch TextField
            {
                case Channel1Box:
                    if WasAnError != .Success
                    {
                        
                    }
                    else
                    {
                        if let NewColor = MakeNewColor(From: FinalValue, For: .Red, In: .RGB)
                        {
                            
                        }
                    }
                    
                case Channel2Box:
                    if WasAnError != .Success
                    {
                        
                    }
                    else
                    {
                        if let NewColor = MakeNewColor(From: FinalValue, For: .Green, In: .RGB)
                        {
                            
                        }
                    }
                    
                case Channel3Box:
                    if WasAnError != .Success
                    {
                        
                    }
                    else
                    {
                        if let NewColor = MakeNewColor(From: FinalValue, For: .Blue, In: .RGB)
                        {
                            
                        }
                    }
                    
                case Channel5Box:
                    if WasAnError != .Success
                    {
                        
                    }
                    else
                    {
                        if let NewColor = MakeNewColor(From: FinalValue, For: .Alpha, In: .RGB)
                        {
                        LastAlpha = FinalValue
                        }
                    }
                    
                default:
                    break
            }
        }
    }
}
