//
//  ColorPicker.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/25/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ColorPicker: NSViewController, WindowManagement, ColorPanelParentProtocol
{
    public weak var Delegate: ColorPickerDelegate? = nil
    var ParentWindow: ColorPickerWindow? = nil
    
    override func viewDidLoad()
    {
        MainColorChip.IsStatic = true
        SetSourceColor(NSColor.white)
    }
    
    override func viewDidLayout()
    {
        if !HandledInitial
        {
            HandledInitial = true
            ParentWindow = self.view.window?.windowController as? ColorPickerWindow
            CreateColorPanels()
            RGBValueLabel.stringValue = ""
            HSBValueLabel.stringValue = ""
            CMYKValueLabel.stringValue = ""
            LoadPanel(.ColorWheel)
        }
    }
    
    var HandledInitial = false
    
    // MARK: - Panel management
    
    func LoadPanel(_ PanelType: ColorPanelTypes)
    {
        if Panels[PanelType] == nil
        {
            return
        }
        for SomeView in PanelContainer.subviews
        {
            SomeView.removeFromSuperview()
        }
        Panels[PanelType]!.Controller?.view.frame = PanelContainer.bounds
        PanelContainer.addSubview(Panels[PanelType]!.Controller!.view)
    }
    
    func CreateColorPanels()
    {
        Panels[.Manual] = ColorPanelBase(CreatePanelDialog("ManualEntryPanel"))
        Panels[.ColorList] = ColorPanelBase(CreatePanelDialog("ColorListPanel"))
        Panels[.SavedColors] = ColorPanelBase(CreatePanelDialog("SavedColorsPanel"))
    }
    
    var Panels = [ColorPanelTypes: ColorPanelBase]()
    
    func CreatePanelDialog(_ IDName: String) -> NSViewController?
    {
        if let Controller = NSStoryboard(name: "ColorPicker", bundle: nil).instantiateController(withIdentifier: IDName) as? NSViewController
        {
            guard let AController = Controller as? ColorPanelProtocol else
            {
                Debug.FatalError("Error casting preference panel to ColorPanelProtocol")
            }
            AController.Parent = self
            AController.SetColor(CurrentColor, From: .Picker)
            return Controller
        }
        fatalError("Error creating \(IDName)")
    }
    
    @IBAction func ShowColorWheelPanel(_ sender: Any)
    {
        LoadPanel(.ColorWheel)
    }
    
    @IBAction func ShowManualPanel(_ sender: Any)
    {
        LoadPanel(.Manual)
    }
    
    @IBAction func ShowColorListPanel(_ sender: Any)
    {
        LoadPanel(.ColorList)
    }
    
    @IBAction func ShowSavedColorsPanel(_ sender: Any)
    {
        LoadPanel(.SavedColors)
    }
    
    @IBAction func ShowAboutPanel(_ sender: Any)
    {
        LoadPanel(.About)
    }
    
    // MARK: - UI management
    
    func SetSourceColor(_ Color: NSColor)
    {
        CurrentColor = Color
        MainColorChip.Color = Color
        UpdateColorLabels(With: Color.InRGB)
    }
    
    func UpdateColorLabels(With: NSColor)
    {
        var Red: CGFloat = 0.0
        var Green: CGFloat = 0.0
        var Blue: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        With.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
        let IRed = Int(Red * 255.0)
        let IGreen = Int(Green * 255.0)
        let IBlue = Int(Blue * 255.0)
        let IAlpha = Int(Alpha * 255.0)
        let SRed = String(IRed, radix: 16)
        let SGreen = String(IGreen, radix: 16)
        let SBlue = String(IBlue, radix: 16)
        let SAlpha = String(IAlpha, radix: 16)
        RGBValueLabel.stringValue = "#\(SRed)\(SGreen)\(SBlue)\(SAlpha)"
        var Hue: CGFloat = 0.0
        var Saturation: CGFloat = 0.0
        var Brightness: CGFloat = 0.0
        With.getHue(&Hue, saturation: &Saturation, brightness: &Brightness, alpha: &Alpha)
        let SHue = "\(Hue.RoundedTo(2))"
        let SSaturation = "\(Saturation.RoundedTo(2))"
        let SBrightness = "\(Brightness.RoundedTo(2))"
        let ShAlpha = "\(Alpha.RoundedTo(2))"
        HSBValueLabel.stringValue = "\(SHue),\(SSaturation),\(SBrightness),\(ShAlpha)"
        let (Cyan, Magenta, Yellow, Black) = With.ToCMYK()
        let SCyan = "\(Cyan.RoundedTo(2))"
        let SMagenta = "\(Magenta.RoundedTo(2))"
        let SYellow = "\(Yellow.RoundedTo(2))"
        let SBlack = "\(Black.RoundedTo(2))"
        CMYKValueLabel.stringValue = "\(SCyan),\(SMagenta),\(SYellow),\(SBlack)"
    }
    
    var CurrentColor: NSColor = NSColor.white
    
    func NewColorFromPanel(_ Color: NSColor, From: ColorPanelTypes)
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
       
    // MARK: - Help system
        
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
    
    // MARK: - Interface builder outlets
    
    @IBOutlet weak var CMYKValueLabel: NSTextField!
    @IBOutlet weak var HSBValueLabel: NSTextField!
    @IBOutlet weak var RGBValueLabel: NSTextField!
    @IBOutlet weak var MainColorChip: ColorChip!
    @IBOutlet weak var PanelContainer: NSView!
}

enum ColorPanelTypes: String, CaseIterable
{
    case ColorWheel = "ColorWheel"
    case Manual = "Manual"
    case ColorList = "ColorList"
    case SavedColors = "SavedColors"
    case About = "About"
    case Picker = "ColorPicker"
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

