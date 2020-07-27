//
//  EarthquakeSettingsWindow.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class EarthquakeSettingsWindow: NSViewController, FontProtocol
{
    public weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InitializeAsynchronousEarthquakes()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    var LocalEarthquakeData = [Earthquake2]()
    
    var CurrentMagIndex = -1
    
    func InitializeAsynchronousEarthquakes()
    {
        #if DEBUG
        #else
        EarthquakeDebugButton.removeFromSuperview()
        #endif
        InitializeMagnitudeColors()
        let EnableEarthquakes = Settings.GetBool(.EnableEarthquakes)
        EarthquakeSwitch.state = EnableEarthquakes ? .on : .off
        let FetchInterval = Settings.GetDouble(.EarthquakeFetchInterval, 60.0)
        FrequencyCombo.removeAllItems()
        FrequencyCombo.addItem(withObjectValue: "30 seconds")
        FrequencyCombo.addItem(withObjectValue: "1 minute")
        FrequencyCombo.addItem(withObjectValue: "10 minutes")
        FrequencyCombo.addItem(withObjectValue: "30 minute")
        FrequencyCombo.addItem(withObjectValue: "1 hour")
        switch FetchInterval
        {
            case 30.0:
                FrequencyCombo.selectItem(at: 0)
                
            case 60.0:
                FrequencyCombo.selectItem(at: 1)
                
            case 600:
                FrequencyCombo.selectItem(at: 2)
                
            case 1800:
                FrequencyCombo.selectItem(at: 3)
                
            case 3600:
                FrequencyCombo.selectItem(at: 4)
                
            default:
                FrequencyCombo.selectItem(at: 1)
        }

        let MinMagValue = Settings.GetDouble(.MinimumMagnitude, 5.0)
        let IMinMag = Int(MinMagValue)
        MinMagSegment.selectedSegment = IMinMag - 4

        let ColDet = Settings.GetEnum(ForKey: .ColorDetermination, EnumType: EarthquakeColorMethods.self, Default: .Magnitude)
        ColorDetCombo.removeAllItems()
        for Method in EarthquakeColorMethods.allCases
        {
            ColorDetCombo.addItem(withObjectValue: Method.rawValue)
        }
        ColorDetCombo.selectItem(withObjectValue: ColDet.rawValue)
        BaseColorWell.color = Settings.GetColor(.BaseEarthquakeColor, NSColor.red)
        AgeCombo.removeAllItems()
        let EAge = Settings.GetEnum(ForKey: .EarthquakeAge, EnumType: EarthquakeAges.self, Default: .Age30)
        for SomeAge in EarthquakeAges.allCases
        {
            AgeCombo.addItem(withObjectValue: SomeAge.rawValue)
        }
        AgeCombo.selectItem(withObjectValue: EAge.rawValue)
        ShapeCombo.removeAllItems()
        let EShape = Settings.GetEnum(ForKey: .EarthquakeShapes, EnumType: EarthquakeShapes.self, Default: .Sphere)
        for SomeShape in EarthquakeShapes.allCases
        {
            ShapeCombo.addItem(withObjectValue: SomeShape.rawValue)
        }
        ShapeCombo.selectItem(withObjectValue: EShape.rawValue)
        if LocalEarthquakeData.isEmpty
        {
            EarthquakeViewButton.isEnabled = false
        }
        else
        {
            EarthquakeViewButton.isEnabled = true
        }
        let EqFont = Settings.GetFont(.EarthquakeFontName, StoredFont("Avenir-Heavy", 15.0, NSColor.black))
        if let FontName = FontHelper.PrettyFontName(From: EqFont.PostscriptName)
        {
            EarthquakeFontButton.title = FontName
        }
        else
        {
            EarthquakeFontButton.title = "Huh?"
        }
        let MagView = Settings.GetEnum(ForKey: .EarthquakeMagnitudeViews, EnumType: EarthquakeMagnitudeViews.self, Default: .No)
        switch MagView
        {
            case .No:
                MagnitudeViewSegment.selectedSegment = 0
                
            case .Horizontal:
                MagnitudeViewSegment.selectedSegment = 1
                
            case .Vertical:
                MagnitudeViewSegment.selectedSegment = 2
        }
        CombinedColorWell.color = Settings.GetColor(.CombinedEarthquakeColor, NSColor.orange)
    }
    
    @IBAction func HandleFetchFrequencyChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            let Index = Combo.indexOfSelectedItem
            switch Index
            {
                case 0:
                    Settings.SetDouble(.EarthquakeFetchInterval, 30.0)
                    
                case 1:
                    Settings.SetDouble(.EarthquakeFetchInterval, 60.0)
                    
                case 2:
                    Settings.SetDouble(.EarthquakeFetchInterval, 600.0)
                    
                case 3:
                    Settings.SetDouble(.EarthquakeFetchInterval, 1800.0)
                    
                case 4:
                    Settings.SetDouble(.EarthquakeFetchInterval, 3600.0)
                    
                default:
                    return
            }
        }
    }
    
    @IBAction func HandleMinMagComboChangedX(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            if let Raw = Combo.objectValueOfSelectedItem
            {
                if let RawValue = Raw as? String
                {
                    if let Done = Double(RawValue)
                    {
                        Settings.SetDouble(.MinimumMagnitude, Done)
                    }
                }
            }
        }
    }
    
    @IBAction func HandleMinMagChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            let Index = Segment.selectedSegment
            Settings.SetDouble(.MinimumMagnitude, Double(Index + 4))
        }
    }
    
    @IBAction func HandleEarthquakeSwitchChanged(_ sender: Any)
    {
        if let Check = sender as? NSSwitch
        {
            Settings.SetBool(.EnableEarthquakes, Check.state == .on ? true : false)
        }
    }
    
    @IBAction func HandleColorDeterminationChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            if let Raw = Combo.objectValueOfSelectedItem as? String
            {
                if let RawValue = EarthquakeColorMethods(rawValue: Raw)
                {
                    Settings.SetEnum(RawValue, EnumType: EarthquakeColorMethods.self,
                                     ForKey: .ColorDetermination)
                }
            }
        }
    }
    
    @IBAction func HandleNewBaseColor(_ sender: Any)
    {
        if let ColorWell = sender as? NSColorWell
        {
            Settings.SetColor(.BaseEarthquakeColor, ColorWell.color)
        }
    }
    
    @IBAction func HandleCombinedColorChanged(_ sender: Any)
    {
        if let ColorWell = sender as? NSColorWell
        {
            Settings.SetColor(.CombinedEarthquakeColor, ColorWell.color)
        }
    }
    
    @IBAction func HandleAgeComboChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            if let Raw = Combo.objectValueOfSelectedItem as? String
            {
                if let RawValue = EarthquakeAges(rawValue: Raw)
                {
                    Settings.SetEnum(RawValue, EnumType: EarthquakeAges.self, ForKey: .EarthquakeAge)
                }
            }
        }
    }
    
    @IBAction func HandleShapeChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            if let Raw = Combo.objectValueOfSelectedItem as? String
            {
                if let RawValue = EarthquakeShapes(rawValue: Raw)
                {
                    Settings.SetEnum(RawValue, EnumType: EarthquakeShapes.self, ForKey: .EarthquakeShapes)
                }
            }
        }
    }
    
    func LoadData(DataType: AsynchronousDataTypes, Raw: Any)
    {
        switch DataType
        {
            case .Earthquakes:
                if let RawData = Raw as? [Earthquake2]
                {
                    LocalEarthquakeData = RawData
                    if EarthquakeViewButton != nil
                    {
                        EarthquakeViewButton.isEnabled = true
                    }
                }
                
            default:
                break
        }
    }
    
    @IBAction func HandleViewCurrentEarthquakes(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "LiveData", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "Earthquake2Window") as? Earthquake2Window
        {
            let Window = WindowController.window
            let Controller = Window?.contentViewController as? Earthquake2Controller
            Controller?.LoadData(DataType: .Earthquakes, Raw: LocalEarthquakeData as Any)
            WindowController.showWindow(nil)
        }
    }
    
    #if DEBUG
    @IBAction func HandleDebugEarthquakes(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "EarthquakeDebugger", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "EarthquakeDebuggerWindow") as? EarthquakeDebugWindow
        {
            let Window = WindowController.window
            let ViewController = Window?.contentViewController as? EarthquakeDebugController
            if MainDelegate == nil
            {
                fatalError("Where's my main delegate?")
            }
            ViewController?.MainDelegate = MainDelegate
            self.view.window?.beginSheet(Window!, completionHandler: nil)
        }
    }
    #endif
    
    @IBAction func HandleSetupRecentEarthquakes(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "RecentEarthquakes", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "RecentEarthquakeWindow") as? RecentEarthquakeWindow
        {
            let Window = WindowController.window
            self.view.window?.beginSheet(Window!, completionHandler: nil)
        }
    }
    
    @IBAction func HandleEarthquakeFontPressed(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "FontPickerUI", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "FontPickerWindow") as? FontPickerWindow
        {
            let Window = WindowController.window
            let WindowView = Window?.contentViewController as? FontPickerController
            self.view.window?.beginSheet(Window!, completionHandler: nil)
            WindowView?.FontDelegate = self
        }
    }
    
    func InitializeMagnitudeColors()
    {
        MagnitudeDictionary = Settings.GetMagnitudeColors()
        for (Magnitude, Color) in MagnitudeDictionary
        {
            switch Magnitude
            {
                case .Mag4:
                    Mag4Color.color = Color
                    
                case .Mag5:
                    Mag5Color.color = Color
                    
                case .Mag6:
                    Mag6Color.color = Color
                    
                case .Mag7:
                    Mag7Color.color = Color
                    
                case .Mag8:
                    Mag8Color.color = Color
                    
                case .Mag9:
                    Mag9Color.color = Color
            }
        }
    }
    
    @IBAction func HandleResetMagnitudeColors(_ sender: Any)
    {
        MagnitudeDictionary = Settings.DefaultMagnitudeColors()
        InitializeMagnitudeColors()
    }
    
    @IBAction func HandleMagnitudeColorEvent(_ sender: Any)
    {
        if let ColorWell = sender as? NSColorWell
        {
            switch ColorWell
            {
                case Mag4Color:
                    MagnitudeDictionary[.Mag4] = ColorWell.color
                    
                case Mag5Color:
                    MagnitudeDictionary[.Mag5] = ColorWell.color
                    
                case Mag6Color:
                    MagnitudeDictionary[.Mag6] = ColorWell.color
                    
                case Mag7Color:
                    MagnitudeDictionary[.Mag7] = ColorWell.color
                    
                case Mag8Color:
                    MagnitudeDictionary[.Mag8] = ColorWell.color
                    
                case Mag9Color:
                    MagnitudeDictionary[.Mag9] = ColorWell.color
                    
                default:
                    return
            }
            
            Settings.SetMagnitudeColors(MagnitudeDictionary)
        }
    }
    
    var MagnitudeDictionary = [EarthquakeMagnitudes: NSColor]()
    
    // MARK: - Font protocol functions.
    
    func CurrentFont() -> StoredFont?
    {
        return Settings.GetFont(.EarthquakeFontName, StoredFont("Avenir-Heavy", 15.0, NSColor.orange))
    }
    
    func WantsContinuousUpdates() -> Bool
    {
        return false
    }
    
    func NewFont(_ NewFont: StoredFont)
    {
        print("Have new font: \(FontHelper.PrettyFontName(From: NewFont.PostscriptName)!)")
        Settings.SetFont(.EarthquakeFontName, NewFont)
        let EqFont = Settings.GetFont(.EarthquakeFontName, StoredFont("Avenir-Heavy", 15.0, NSColor.black))
        if let FontName = FontHelper.PrettyFontName(From: EqFont.PostscriptName)
        {
            EarthquakeFontButton.title = FontName
        }
        else
        {
            EarthquakeFontButton.title = "Huh?"
        }
    }
    
    func Closed(_ OK: Bool, _ SelectedFont: StoredFont?)
    {
        if OK
        {
            if let NewFont = SelectedFont
            {
            Settings.SetFont(.EarthquakeFontName, NewFont)
            let EqFont = Settings.GetFont(.EarthquakeFontName, StoredFont("Avenir-Heavy", 15.0, NSColor.black))
            if let FontName = FontHelper.PrettyFontName(From: EqFont.PostscriptName)
            {
                EarthquakeFontButton.title = FontName
            }
            else
            {
                EarthquakeFontButton.title = "Huh?"
            }
            }
        }
    }
    
    @IBAction func HandleMagnitudeViewChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            switch Segment.selectedSegment
            {
                case 0:
                    Settings.SetEnum(EarthquakeMagnitudeViews.No, EnumType: EarthquakeMagnitudeViews.self, ForKey: .EarthquakeMagnitudeViews)
                    
                case 1:
                    Settings.SetEnum(EarthquakeMagnitudeViews.Horizontal, EnumType: EarthquakeMagnitudeViews.self, ForKey: .EarthquakeMagnitudeViews)
                    
                case 2:
                    Settings.SetEnum(EarthquakeMagnitudeViews.Vertical, EnumType: EarthquakeMagnitudeViews.self, ForKey: .EarthquakeMagnitudeViews)
            
                default:
                    return
            }
        }
    }
    
    @IBOutlet weak var CombinedColorWell: NSColorWell!
    @IBOutlet weak var MagnitudeViewSegment: NSSegmentedControl!
    @IBOutlet weak var EarthquakeFontButton: NSButton!
    @IBOutlet weak var EarthquakeDebugButton: NSButton!
    @IBOutlet weak var Mag4Color: NSColorWell!
    @IBOutlet weak var Mag5Color: NSColorWell!
    @IBOutlet weak var Mag6Color: NSColorWell!
    @IBOutlet weak var Mag7Color: NSColorWell!
    @IBOutlet weak var Mag8Color: NSColorWell!
    @IBOutlet weak var Mag9Color: NSColorWell!
    @IBOutlet weak var MinMagSegment: NSSegmentedControl!
    @IBOutlet weak var BaseColorWell: NSColorWell!
    @IBOutlet weak var ColorDetCombo: NSComboBox!
    @IBOutlet weak var AgeCombo: NSComboBox!
    @IBOutlet weak var ShapeCombo: NSComboBox!
    @IBOutlet weak var EarthquakeSwitch: NSSwitch!
    @IBOutlet weak var FrequencyCombo: NSComboBox!
    @IBOutlet weak var EarthquakeViewButton: NSButton!
    
    
}
