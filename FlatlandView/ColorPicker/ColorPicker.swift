//
//  ColorPicker.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/25/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ColorPicker: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NewColorProtocol, WindowManagement
{
    public weak var Delegate: ColorPickerDelegate? = nil
    
    override func viewDidLoad()
    {
        let IType = Settings.GetEnum(ForKey: .ColorInputType, EnumType: InputTypes.self, Default: .Normal)
        switch IType
        {
            case .Normal:
                InputTypeSelector.selectedSegment = 2
                
            case .Hex:
                InputTypeSelector.selectedSegment = 1
                
            case .Integer:
                InputTypeSelector.selectedSegment = 0
        }
        ManualColorChip.IsStatic = true
        SetSourceColor(NSColor.white)
        PopulateManualWithColor(NSColor.white)
        MakeUITable()
    }
    
    // MARK: - UI management
    
    var UITable = [PickerColorChannels: (TextField: NSTextField, Label: NSTextField?, Slider: NSSlider, Space: PickerColorspaces?)]()
    
    /// Creates a table of UI elements for channel entry.
    func MakeUITable()
    {
        UITable[.Alpha] = (Channel5Box, nil, Channel5Slider, nil)
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
    
    func SetSourceColor(_ Color: NSColor)
    {
        CurrentColor = Color
        ManualColorChip.Color = Color
        ListColorChip.Color = Color
        PopulateManualWithColor(Color)
    }
    
    var CurrentColor: NSColor = NSColor.white
    
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
    
    // MARK: - Internal protocol handlers
    
    func NewColorEntered(_ Color: NSColor)
    {
        SetSourceColor(Color)
    }
    
    // MARK: - Window management
    
    @IBAction func ColorPickerOKButtonHandler(_ sender: Any)
    {
        Pop?.close()
        self.view.window?.close()
    }
    
    @IBAction func ColorPickerCancelButtonHandler(_ sender: Any)
    {
        Pop?.close()
        self.view.window?.close()
    }
    
    func MainClosing()
    {
        Pop?.close()
        self.view.window?.close()
    }
    
    // MARK: - Table management
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "ColorColumn"
        }
        else
        {
            CellIdentifier = "ColorNameColumn"
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    // MARK: - Help system
    
    
    @IBAction func RunHelp(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            let Where = Button.bounds
            var Topics = ColorTopics.GeneralColorSpaces
            switch Button
            {
                case InputTypeHelpButton:
                    Topics = .NumericInputTypes
                    
                case ColorSpaceHelpButton:
                    Topics = .GeneralColorSpaces
                    
                default:
                    return
            }
            ShowHelp(Message: Topics, Where: Where, What: Button)
        }
    }
    
    func ShowHelp(Message: ColorTopics, Where: NSRect, What: NSView)
    {
        if let PopController = NSStoryboard(name: "PreferenceHelpViewer", bundle: nil).instantiateController(withIdentifier: "PreferenceHelpViewer") as? PreferenceHelpPopover
        {
            guard let HelpController = PopController as? PreferenceHelpProtocol else
            {
                return
            }
            Pop = NSPopover()
            Pop?.contentSize = NSSize(width: 427, height: 237)
            Pop?.behavior = .semitransient
            Pop?.animates = true
            Pop?.contentViewController = PopController
            var HelpMessage = ""
            switch Message
            {
                case .GeneralColorSpaces:
                    HelpMessage = """
You can use different color spaces to manually enter color channels.
• |font type=bold|RGB|font type=system| for red, green blue channels.
• |font type=bold|HSB|font type=system| for hue, saturation, and brightness values.
• |font type=bold|CMYK|font type=system| for cyan, magenta, yellow, and black values.
"""
                    
                case .NumericInputTypes:
                    HelpMessage = """
Determines how you enter raw channel values. (You can use the slider to enter values as well.)
• |font type=bold|Number|font type=system| for integer values from 0 to 255.
• |font type=bold|Hex|font type=system| for hexidecimal values prefixed by # or 0x and ranging from #0 to #ff.
• |font type=bold|Normal|font type=system| for decimal values between 0.0 and 1.0. Values greater than 1.0 are interpeted as integers.
"""
            }
            HelpController.SetHelpText(HelpMessage)
            Pop?.show(relativeTo: Where, of: What, preferredEdge: .maxY)
        }
    }
    
    var Pop: NSPopover? = nil
    
    
    @IBAction func HandleSliderChanged(_ sender: Any)
    {
        if let Slider = sender as? NSSlider
        {
        UpdateFromManualSlider(Slider)
            }
    }
    
    func ChangeColorChannel(Source: NSColor, NewValue: Double, Channel: PickerColorChannels) -> NSColor
    {
        var Red: CGFloat = 1.0
        var Green: CGFloat = 1.0
        var Blue: CGFloat = 1.0
        var Alpha: CGFloat = 1.0
        Source.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
        switch Channel
        {
            case .Red:
                Red = CGFloat(NewValue)
                
            case .Green:
                Green = CGFloat(NewValue)
                
            case .Blue:
                Blue = CGFloat(NewValue)
                
            case .Alpha:
                Alpha = CGFloat(NewValue)
                
            default:
                Debug.Print("Unsupported channel (\(Channel)) encountered in \(#function)")
                return Source
        }
        let EditedColor = NSColor(calibratedRed: Red, green: Green, blue: Blue, alpha: Alpha)
        return EditedColor
    }
    
    @IBAction func HandleManualAlphaChanged(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            if Button.state == .off
            {
                CurrentColor = ChangeColorChannel(Source: CurrentColor, NewValue: 1.0, Channel: .Alpha)
//                CurrentColor = CurrentColor.withAlphaComponent(1.0)
                SetSourceColor(CurrentColor)
                Channel5Slider.isEnabled = false
                Channel5Box.isEnabled = false
            }
            else
            {
                CurrentColor = ChangeColorChannel(Source: CurrentColor, NewValue: LastAlpha, Channel: .Alpha)
//                CurrentColor = CurrentColor.withAlphaComponent(CGFloat(LastAlpha))
                SetSourceColor(CurrentColor)
                Channel5Slider.isEnabled = true
                Channel5Box.isEnabled = true
            }
        }
    }
    
    var LastAlpha: Double = 1.0
    
    // MARK: - Interface builder outlets
    
    @IBOutlet weak var ColorListTable: NSTableView!
    @IBOutlet weak var ListColorChip: ColorChip!
    @IBOutlet weak var InputTypeHelpButton: NSButton!
    @IBOutlet weak var ColorSpaceHelpButton: NSButton!
    @IBOutlet weak var ManualInputColorSpace: NSSegmentedControl!
    @IBOutlet weak var ManualColorChip: ColorChip!
    @IBOutlet weak var InputTypeSelector: NSSegmentedControl!
    
    
    @IBOutlet weak var Channel1Box: NSTextField!
    @IBOutlet weak var Channel2Box: NSTextField!
    @IBOutlet weak var Channel3Box: NSTextField!
    @IBOutlet weak var Channel4Box: NSTextField!
    @IBOutlet weak var Channel5Box: NSTextField!
    @IBOutlet weak var Channel1Label: NSTextField!
    @IBOutlet weak var Channel2Label: NSTextField!
    @IBOutlet weak var Channel3Label: NSTextField!
    @IBOutlet weak var Channel4Label: NSTextField!
    @IBOutlet weak var ManualAlphaCheck: NSButton!
    @IBOutlet weak var Channel1Slider: NSSlider!
    @IBOutlet weak var Channel2Slider: NSSlider!
    @IBOutlet weak var Channel3Slider: NSSlider!
    @IBOutlet weak var Channel4Slider: NSSlider!
    @IBOutlet weak var Channel5Slider: NSSlider!
}

/// Determines the input format for color channels.
enum InputTypes: String, CaseIterable
{
    /// Hex values (hex digits preceded by # or 0x).
    case Hex = "Hex"
    /// Integer values from 0 to 255.
    case Integer = "Integer"
    /// Normal values from 0.0 to 1.0.
    case Normal = "Normal"
}

/// Color picker channels supported.
enum PickerColorChannels: String, CaseIterable
{
    case Red = "Red"
    case Green = "Green"
    case Blue = "Blue"
    case Hue = "Hue"
    case Saturation = "Saturation"
    case Brightness = "Brightness"
    case Cyan = "Cyan"
    case Magenta = "Magenta"
    case Yellow = "Yellow"
    case Black = "Black"
    case Alpha = "Alpha"
}

/// Color picker colorspaces supported.
enum PickerColorspaces: String, CaseIterable
{
    case RGB = "RGB"
    case HSB = "HSB"
    case CMYK = "CMYK"
}

enum ColorTopics: String
{
    case GeneralColorSpaces = "GeneralColorSpaces"
    case NumericInputTypes = "NumericInputTypes"
}

