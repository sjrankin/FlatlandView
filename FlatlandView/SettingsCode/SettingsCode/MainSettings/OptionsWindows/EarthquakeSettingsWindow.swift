//
//  EarthquakeSettingsWindow.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class EarthquakeSettingsWindow: NSViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InitializeAsynchronousEarthquakes()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    var LocalEarthquakeData = [Earthquake]()

    var CurrentMagIndex = -1
    
    func InitializeAsynchronousEarthquakes()
    {
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
        MinMagCombo.removeAllItems()
        for QuakeM in EarthquakeMagnitudes.allCases
        {
            MinMagCombo.addItem(withObjectValue: "\(QuakeM.rawValue)")
        }
        let MinMag = Settings.GetDouble(.MinimumMagnitude, EarthquakeMagnitudes.Mag6.rawValue)
        MinMagCombo.selectItem(withObjectValue: MinMag)
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
    
    @IBAction func HandleMinMagComboChanged(_ sender: Any)
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
                if let RawData = Raw as? [Earthquake]
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
        if let WindowController = Storyboard.instantiateController(withIdentifier: "DataViewWindow") as? LiveDataViewWindow
        {
            let Window = WindowController.window
            let Controller = Window?.contentViewController as? LiveDataViewer
            Controller?.LoadData(DataType: .Earthquakes, Raw: LocalEarthquakeData as Any)
            WindowController.showWindow(nil)
        }
    }
    
    @IBAction func HandleRunMagnitudeColorsButton(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "Settings", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "MagnitudeColorWindow") as? MagColorWindow
        {
            let Window = WindowController.window
            self.view.window?.beginSheet(Window!, completionHandler: nil)
        }
    }
    
    @IBOutlet weak var MinMagCombo: NSComboBox!
    @IBOutlet weak var BaseColorWell: NSColorWell!
    @IBOutlet weak var ColorDetCombo: NSComboBox!
    @IBOutlet weak var AgeCombo: NSComboBox!
    @IBOutlet weak var ShapeCombo: NSComboBox!
    @IBOutlet weak var EarthquakeSwitch: NSSwitch!
    @IBOutlet weak var MagColorTable: NSTableView!
    @IBOutlet weak var FrequencyCombo: NSComboBox!
    @IBOutlet weak var EarthquakeViewButton: NSButton!
}
