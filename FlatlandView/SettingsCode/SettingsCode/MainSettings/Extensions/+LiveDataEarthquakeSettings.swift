//
//  +LiveDataEarthquakeSettings.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainSettings
{
    func InitializeAsynchronousEarthquakes()
    {
        let EnableEarthquakes = Settings.GetBool(.EnableEarthquakes)
        EarthquakeCheck.state = EnableEarthquakes ? .on : .off
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
        let MinMag = Settings.GetDouble(.MinimumMagnitude, EarthquakeMagnitudes.Mag6.rawValue)
        let MagIndex = Int(MinMag) - 4
        MinMagnitudeSegment.selectedSegment = MagIndex
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
            MainDelegate?.Refresh("MainSettings.HandleFetchFrequencyChanged")
        }
    }
    
    @IBAction func HandleMinMagnitudeChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            let Index = Segment.selectedSegment
            let MinMag = EarthquakeMagnitudes.allCases[Index]
            Settings.SetDouble(.MinimumMagnitude, MinMag.rawValue)
            MainDelegate?.Refresh("MainSettings.HandleMinMagnitudeChanged")
        }
    }
    
    @IBAction func HandleEarthquakeCheckChanged(_ sender: Any)
    {
        if let Check = sender as? NSButton
        {
            Settings.SetBool(.EnableEarthquakes, Check.state == .on ? true : false)
            MainDelegate?.Refresh("MainSettings.HandleEarthquakeCheckChanged")
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
                    MainDelegate?.Refresh(#function)
                }
            }
        }
    }
    
    @IBAction func HandleNewBaseColor(_ sender: Any)
    {
        if let ColorWell = sender as? NSColorWell
        {
            Settings.SetColor(.BaseEarthquakeColor, ColorWell.color)
            MainDelegate?.Refresh(#function)
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
                    MainDelegate?.Refresh(#function)
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
                    MainDelegate?.Refresh(#function)
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
                    EarthquakeViewButton.isEnabled = true
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
}
