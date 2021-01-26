//
//  RGBEntry.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/25/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class RGBEntry: NSViewController, NSTextFieldDelegate, PanelSetupProtocol
{
    weak var ColorDelegate: NewColorProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidAppear()
    {
        super.viewDidAppear()
        Populate(From: CurrentColor ?? NSColor.white)
    }
    
    var CurrentColor: NSColor? = nil
    var CurrentInputType: InputTypes = .Integer
    
    func InitialColor(_ Color: NSColor, InputType: InputTypes, Receiver: NewColorProtocol)
    {
        ColorDelegate = Receiver
        CurrentColor = Color
        CurrentInputType = InputType
    }
    
    func UpdateInputType(_ NewInputType: InputTypes)
    {
        CurrentInputType = NewInputType
        Populate(From: CurrentColor ?? NSColor.white)
    }
    
    func SetColor(_ Color: NSColor)
    {
        Populate(From: Color)
    }
    
    func Populate(From: NSColor)
    {
        let ValidRGB = From.InRGB
        var Red: CGFloat = 0.0
        var Green: CGFloat = 0.0
        var Blue: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        ValidRGB.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
        var FinalRed: String = ""
        var FinalGreen: String = ""
        var FinalBlue: String = ""
        var FinalAlpha: String = ""
        switch CurrentInputType
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
        
        RedSlider.doubleValue = Double(Red) * 1275.0
        RedBox.stringValue = FinalRed
        GreenSlider.doubleValue = Double(Green) * 1275.0
        GreenBox.stringValue = FinalGreen
        BlueSlider.doubleValue = Double(Blue) * 1275.0
        BlueBox.stringValue = FinalBlue
        AlphaSlider.doubleValue = Double(Alpha) * 1275.0
        AlphaBox.stringValue = FinalAlpha
    }
    
    func MakeNewColor(From Value: Double, For Channel: PickerColorChannels)
    {
        if Value < 0.0 || Value > 1.0
        {
            print("Invalid normal value (\(Value)) passed to MakeNewColor for channel \(Channel)")
            return
        }
        var Red: CGFloat = 0.0
        var Green: CGFloat = 0.0
        var Blue: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        CurrentColor!.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
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
                return
        }
        
        CurrentColor = NSColor(calibratedRed: Red, green: Green, blue: Blue, alpha: Alpha)
        ColorDelegate?.NewColorEntered(CurrentColor!)
    }
    
    var LastAlpha: Double = 1.0
    
    func controlTextDidEndEditing(_ obj: Notification)
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
                case RedBox:
                    if WasAnError != .Success
                    {
                        
                    }
                    else
                    {
                        MakeNewColor(From: FinalValue, For: .Red)
                    }
                    
                case GreenBox:
                    if WasAnError != .Success
                    {
                        
                    }
                    else
                    {
                        MakeNewColor(From: FinalValue, For: .Green)
                    }
                    
                case BlueBox:
                    if WasAnError != .Success
                    {
                        
                    }
                    else
                    {
                        MakeNewColor(From: FinalValue, For: .Blue)
                    }
                    
                case AlphaBox:
                    if WasAnError != .Success
                    {
                        
                    }
                    else
                    {
                        MakeNewColor(From: FinalValue, For: .Alpha)
                        LastAlpha = FinalValue
                    }
                    
                default:
                    break
            }
        }
    }
    
    @IBAction func HandleSliderChanged(_ sender: Any)
    {
        if let Slider = sender as? NSSlider
        {
            let SliderValue = Slider.doubleValue / 1275.0
            let Normal = SliderValue / 255.0
            switch Slider
            {
                case RedSlider:
                    MakeNewColor(From: Normal, For: .Red)
                    
                case GreenSlider:
                    MakeNewColor(From: Normal, For: .Green)
                    
                case BlueSlider:
                    MakeNewColor(From: Normal, For: .Blue)
                    
                case AlphaSlider:
                    MakeNewColor(From: Normal, For: .Alpha)
                    LastAlpha = Normal
                    
                default:
                    return
            }
        }
    }
    
    func UpdateTextBox(With Value: Double, Channel: PickerColorChannels)
    {
        var Final = ""
        switch CurrentInputType
        {
            case .Hex:
                Final = String(Int(Value * 255.0), radix: 16)
                Final = "#" + Final
                
            case .Integer:
                let IFinal = Int(Value * 255.0)
                Final = "\(IFinal)"
                
            case .Normal:
                Final = "\(Value)"
        }
        switch Channel
        {
            case .Red:
                RedBox.stringValue = Final
                
            case .Green:
                GreenBox.stringValue = Final
                
            case .Blue:
                BlueBox.stringValue = Final
                
            case .Alpha:
                AlphaBox.stringValue = Final
                
            default:
                return
        }
    }
    
    @IBAction func HandleAlphaCheckChanged(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            if Button.state == .off
            {
                CurrentColor = CurrentColor!.withAlphaComponent(1.0)
                ColorDelegate?.NewColorEntered(CurrentColor!)
                AlphaSlider.isEnabled = false
                AlphaBox.isEnabled = false
            }
            else
            {
                CurrentColor = CurrentColor!.withAlphaComponent(CGFloat(LastAlpha))
                ColorDelegate?.NewColorEntered(CurrentColor!)
                AlphaSlider.isEnabled = true
                AlphaBox.isEnabled = true
            }
        }
    }
    
    @IBOutlet weak var RedSlider: NSSlider!
    @IBOutlet weak var GreenSlider: NSSlider!
    @IBOutlet weak var BlueSlider: NSSlider!
    @IBOutlet weak var AlphaSlider: NSSlider!
    @IBOutlet weak var HasAlphaCheck: NSButton!
    @IBOutlet weak var RedBox: NSTextField!
    @IBOutlet weak var GreenBox: NSTextField!
    @IBOutlet weak var BlueBox: NSTextField!
    @IBOutlet weak var AlphaBox: NSTextField!
    
}
