//
//  ManualEntryPanel.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/26/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ManualEntryPanel: NSViewController, NSTextFieldDelegate, ColorPanelProtocol
{
    public weak var Parent: ColorPanelParentProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidAppear()
    {
        super.viewDidAppear()
        MakeUITable()
        let ColorSpace = Settings.GetEnum(ForKey: .ColorPickerColorspace, EnumType: PickerColorspaces.self, Default: .RGB)
        UpdateUIForColorSpace(ColorSpace)
        if let FirstColor = InitialColor
        {
            PopulateManualWithColor(FirstColor)
        }
    }
    
    var UITable = [PickerColorChannels: (TextField: NSTextField, Label: NSTextField?, Slider: NSSlider, Space: PickerColorspaces?)]()
    
    /// Creates a table of UI elements for channel entry.
    func MakeUITable()
    {
        UITable[.Alpha] = (Channel5Box, Channel5Label, Channel5Slider, nil)
        UITable[.Red] = (Channel1Box, Channel1Label, Channel1Slider, .RGB)
        UITable[.Green] = (Channel2Box, Channel2Label, Channel2Slider, .RGB)
        UITable[.Blue] = (Channel3Box, Channel3Label, Channel3Slider, .RGB)
        UITable[.Hue] = (Channel1Box, Channel1Label, Channel1Slider, .HSB)
        UITable[.Saturation] = (Channel2Box, Channel2Label, Channel2Slider, .HSB)
        UITable[.Brightness] = (Channel3Box, Channel3Label, Channel3Slider, .HSB)
        UITable[.Cyan] = (Channel1Box, Channel1Label, Channel1Slider, .CMYK)
        UITable[.Magenta] = (Channel2Box, Channel2Label, Channel2Slider, .CMYK)
        UITable[.Yellow] = (Channel3Box, Channel3Label, Channel3Slider, .CMYK)
        UITable[.Black] = (Channel4Box, Channel4Label, Channel4Slider, .CMYK)
    }
    
    var InitialColor: NSColor? = nil
    
    func SetColor(_ Color: NSColor, From: ColorPanelTypes)
    {
        if From != .Manual
        {
            InitialColor = Color
        }
    }
    
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
    
    func ColorFromSliders() -> NSColor
    {
        let CurrentSpace = Settings.GetEnum(ForKey: .ColorPickerColorspace, EnumType: PickerColorspaces.self, Default: .RGB)
        switch CurrentSpace
        {
            case .RGB:
                let NRed = Channel1Slider.doubleValue / 1275.0
                let NGreen = Channel2Slider.doubleValue / 1275.0
                let NBlue = Channel3Slider.doubleValue / 1275.0
                let NAlpha = Channel5Slider.doubleValue / 1275.0
                return NSColor(calibratedRed: CGFloat(NRed), green: CGFloat(NGreen),
                               blue: CGFloat(NBlue), alpha: CGFloat(NAlpha))
                
            case .HSB:
                let NHue = Channel1Slider.doubleValue / 1275.0
                let NSat = Channel2Slider.doubleValue / 1275.0
                let NBri = Channel3Slider.doubleValue / 1275.0
                let NAlpha = Channel5Slider.doubleValue / 1275.0
                return NSColor(calibratedHue: CGFloat(NHue), saturation: CGFloat(NSat),
                               brightness: CGFloat(NBri), alpha: CGFloat(NAlpha))
                
            case .CMYK:
                let NCyan = Channel1Slider.doubleValue / 1275.0
                let NMagenta = Channel2Slider.doubleValue / 1275.0
                let NYellow = Channel3Slider.doubleValue / 1275.0
                let NBlack = Channel4Slider.doubleValue / 1275.0
                let NAlpha = Channel5Slider.doubleValue / 1275.0
                return NSColor(deviceCyan: CGFloat(NCyan), magenta: CGFloat(NMagenta),
                               yellow: CGFloat(NYellow), black: CGFloat(NBlack),
                               alpha: CGFloat(NAlpha))
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
        let CurrentSpace = Settings.GetEnum(ForKey: .ColorPickerColorspace, EnumType: PickerColorspaces.self, Default: .RGB)
        switch Slider
        {
            case Channel1Slider:
                Channel1Box.stringValue = FormatValue(SliderValue, For: InputType, In: CurrentSpace)
                
            case Channel2Slider:
                Channel2Box.stringValue = FormatValue(SliderValue, For: InputType, In: CurrentSpace)
                
            case Channel3Slider:
                Channel3Box.stringValue = FormatValue(SliderValue, For: InputType, In: CurrentSpace)
                
            case Channel4Slider:
                Channel4Box.stringValue = FormatValue(SliderValue, For: InputType, In: CurrentSpace)
                
            case Channel5Slider:
                Channel5Box.stringValue = FormatValue(SliderValue, For: InputType, In: CurrentSpace)
                
            default:
                return
        }
        let NewColor = ColorFromSliders()
        Parent?.NewColorFromPanel(NewColor, From: .Manual)
    }
    
    @IBAction func HandleSliderChanged(_ sender: Any)
    {
        if let Slider = sender as? NSSlider
        {
            UpdateFromManualSlider(Slider)
        }
    }
    
    func ColorChannelFromField(_ Field: NSTextField, Colorspace: PickerColorspaces) -> PickerColorChannels?
    {
        for (Channel, (ChannelBox, _, _, Space)) in UITable
        {
            if Space == Colorspace
            {
                if ChannelBox == Field
                {
                    return Channel
                }
            }
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
    
    @IBAction func HandleInputTypeChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            let Index = Segment.selectedSegment
            var NewType = InputTypes.Normal
            switch Index
            {
                case 0:
                    NewType = .Integer
                    
                case 1:
                    NewType = .Hex
                    
                case 2:
                    NewType = .Normal
                    
                default:
                    return
            }
            Settings.SetEnum(NewType, EnumType: InputTypes.self, ForKey: .ColorInputType)
        }
    }
    
    func UpdateUIForColorSpace(_ Colorspace: PickerColorspaces)
    {
        switch Colorspace
        {
            case .RGB:
                Channel1Label.stringValue = "Red"
                Channel2Label.stringValue = "Green"
                Channel3Label.stringValue = "Blue"
                Channel4Label.isHidden = true
                Channel4Box.isHidden = true
                Channel4Slider.isHidden = true
                
            case .HSB:
                Channel1Label.stringValue = "Hue"
                Channel2Label.stringValue = "Saturation"
                Channel3Label.stringValue = "Brightness"
                Channel4Label.isHidden = true
                Channel4Box.isHidden = true
                Channel4Slider.isHidden = true
                
            case .CMYK:
                Channel1Label.stringValue = "Cyan"
                Channel2Label.stringValue = "Magenta"
                Channel3Label.stringValue = "Yellow"
                Channel4Label.stringValue = "Black"
                Channel4Label.isHidden = false
                Channel4Box.isHidden = false
                Channel4Slider.isHidden = false
        }
    }
    
    @IBAction func HandleColorSpaceChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            let Index = Segment.selectedSegment
            switch Index
            {
                case 0:
                    Settings.SetEnum(.RGB, EnumType: PickerColorspaces.self, ForKey: .ColorPickerColorspace)
                    
                case 1:
                    Settings.SetEnum(.HSB, EnumType: PickerColorspaces.self, ForKey: .ColorPickerColorspace)
                    
                case 2:
                    Settings.SetEnum(.CMYK, EnumType: PickerColorspaces.self, ForKey: .ColorPickerColorspace)
                    
                default:
                    return
            }
            UpdateUIForColorSpace(Settings.GetEnum(ForKey: .ColorPickerColorspace, EnumType: PickerColorspaces.self, Default: .RGB))
        }
    }
    
    @IBOutlet weak var ColorSpaceSegment: NSSegmentedCell!
    @IBOutlet weak var InputTypeSegment: NSSegmentedControl!
    @IBOutlet weak var Channel1Box: NSTextField!
    @IBOutlet weak var Channel2Box: NSTextField!
    @IBOutlet weak var Channel3Box: NSTextField!
    @IBOutlet weak var Channel4Box: NSTextField!
    @IBOutlet weak var Channel5Box: NSTextField!
    @IBOutlet weak var Channel1Label: NSTextField!
    @IBOutlet weak var Channel2Label: NSTextField!
    @IBOutlet weak var Channel3Label: NSTextField!
    @IBOutlet weak var Channel4Label: NSTextField!
    @IBOutlet weak var Channel5Label: NSTextField!
    @IBOutlet weak var Channel1Slider: NSSlider!
    @IBOutlet weak var Channel2Slider: NSSlider!
    @IBOutlet weak var Channel3Slider: NSSlider!
    @IBOutlet weak var Channel4Slider: NSSlider!
    @IBOutlet weak var Channel5Slider: NSSlider!
}
