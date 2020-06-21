//
//  +CitySettings.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainSettings
{
    func InitializeCitySettingsUI()
    {
        ShowCitiesCheck.state = Settings.GetBool(.ShowCities) ? .on : .off
        ShowCapitalCitiesSwitch.state = Settings.GetBool(.ShowCapitalCities) ? .on : .off
        ShowWorldCitiesSwitch.state = Settings.GetBool(.ShowWorldCities) ? .on : .off
        ShowAfricanCitiesSwitch.state = Settings.GetBool(.ShowAfricanCities) ? .on : .off
        ShowAsianCitiesSwitch.state = Settings.GetBool(.ShowAsianCities) ? .on : .off
        ShowEuropeanCitiesSwitch.state = Settings.GetBool(.ShowEuropeanCities) ? .on : .off
        ShowNorthAmericanCitiesSwitch.state = Settings.GetBool(.ShowNorthAmericanCities) ? .on : .off
        ShowSouthAmericanCitiesSwitch.state = Settings.GetBool(.ShowSouthAmericanCities) ? .on : .off
        CityShapeCombo.removeAllItems()
        for Shape in CityDisplayTypes.allCases
        {
            CityShapeCombo.addItem(withObjectValue: Shape.rawValue)
        }
        let CurrentShape = Settings.GetEnum(ForKey: .CityShapes, EnumType: CityDisplayTypes.self, Default: .UniformEmbedded)
        CityShapeCombo.selectItem(withObjectValue: CurrentShape.rawValue)
        let PopType = Settings.GetEnum(ForKey: .PopulationType, EnumType: PopulationTypes.self, Default: .City)
        if PopType == .City
        {
            PopulationSegment.selectedSegment = 0
        }
        else
        {
            PopulationSegment.selectedSegment = 1
        }
    }
    
    @IBAction func ShowCitiesChanged(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            Settings.SetBool(.ShowCities, Button.state == .on ? true : false)
            MainDelegate?.Refresh("MainSettings.ShowCitiesChanged")
        }
    }
    
    @IBAction func HandleCityShapeChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            if let Raw = Combo.objectValueOfSelectedItem as? String
            {
                if let Final = CityDisplayTypes(rawValue: Raw)
                {
                    Settings.SetEnum(Final, EnumType: CityDisplayTypes.self, ForKey: .CityShapes)
                    MainDelegate?.Refresh("MainSettings.HandleCityShapeChanged")
                }
            }
        }
    }
    
    @IBAction func HandlePopulationTypeChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            if Segment.indexOfSelectedItem == 0
            {
                Settings.SetEnum(.City, EnumType: PopulationTypes.self, ForKey: .PopulationType)
                MainDelegate?.Refresh("MainSettings.HandlePopulationTypeChanged")
                return
            }
            if Segment.indexOfSelectedItem == 1
            {
                Settings.SetEnum(.Metropolitan, EnumType: PopulationTypes.self, ForKey: .PopulationType)
                MainDelegate?.Refresh("MainSettings.HandlePopulationTypeChanged")
                return
            }
        }
    }
    
    @IBAction func HandleCityColorsPressed(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "Settings", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "CityColorWindow") as? CityColorWindow
        {
            let Window = WindowController.window
            self.view.window?.beginSheet(Window!, completionHandler: nil)
            if let WinCon = Window?.contentViewController as? CityColorCode
            {
                WinCon.MainDelegate = MainDelegate
            }
        }
    }
    
    @IBAction func HandleShowCityTypeChanged(_ sender: Any)
    {
        if let Button = sender as? NSSwitch
        {
            let IsChecked = Button.state == .on ? true : false
            switch Button
            {
                case ShowCapitalCitiesSwitch:
                    Settings.SetBool(.ShowCapitalCities, IsChecked)
                
                case ShowSouthAmericanCitiesSwitch:
                    Settings.SetBool(.ShowSouthAmericanCities, IsChecked)
                
                case ShowNorthAmericanCitiesSwitch:
                    Settings.SetBool(.ShowNorthAmericanCities, IsChecked)
                
                case ShowEuropeanCitiesSwitch:
                    Settings.SetBool(.ShowEuropeanCities, IsChecked)
                
                case ShowAsianCitiesSwitch:
                    Settings.SetBool(.ShowAsianCities, IsChecked)
                
                case ShowAfricanCitiesSwitch:
                    Settings.SetBool(.ShowAfricanCities, IsChecked)
                
                case ShowWorldCitiesSwitch:
                    Settings.SetBool(.ShowWorldCities, IsChecked)
                
                default:
                    return
            }
            MainDelegate?.Refresh("MainSettings.HandleShowCityTypeChanged")
        }
    }
}
