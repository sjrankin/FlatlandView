//
//  CitySettingsWindow.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class CitySettingsWindow: NSViewController, FontProtocol
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InitializeCitySettingsUI()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    func InitializeCitySettingsUI()
    {
        ShowCitiesSwitch.state = Settings.GetBool(.ShowCities) ? .on : .off
        ShowCapitalCitiesSwitch.state = Settings.GetBool(.ShowCapitalCities) ? .on : .off
        ShowWorldCitiesSwitch.state = Settings.GetBool(.ShowWorldCities) ? .on : .off
        ShowAfricanCitiesSwitch.state = Settings.GetBool(.ShowAfricanCities) ? .on : .off
        ShowAsianCitiesSwitch.state = Settings.GetBool(.ShowAsianCities) ? .on : .off
        ShowEuropeanCitiesSwitch.state = Settings.GetBool(.ShowEuropeanCities) ? .on : .off
        ShowNorthAmericanCitiesSwitch.state = Settings.GetBool(.ShowNorthAmericanCities) ? .on : .off
        ShowSouthAmericanCitiesSwitch.state = Settings.GetBool(.ShowSouthAmericanCities) ? .on : .off
        ShowCustomCitiesSwitch.state = Settings.GetBool(.ShowCustomCities) ? .on : .off
        PopulationRankSwitch.state = Settings.GetBool(.ShowCitiesByPopulation) ? .on : .off
        //On and off are reversed for this setting.
        FloatingCityNameSwitch.state = Settings.GetBool(.CityNamesDrawnOnMap) ? .off : .on
        
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
        let EqFont = Settings.GetFont(.CityFontName, StoredFont("Avenir-Medium", 8.0, NSColor.black))
        if let FontName = FontHelper.PrettyFontName(From: EqFont.PostscriptName)
        {
            CityFontButton.title = FontName
        }
        else
        {
            CityFontButton.title = "Huh?"
        }
        WorldCityColorWell.color = Settings.GetColor(.WorldCityColor, NSColor.white)
        AfricanCityColorWell.color = Settings.GetColor(.AfricanCityColor, NSColor.cyan)
        AsianCityColorWell.color = Settings.GetColor(.AsianCityColor, NSColor.green)
        EuropeanCityColorWell.color = Settings.GetColor(.EuropeanCityColor, NSColor.magenta)
        NorthAmericanCityColorWell.color = Settings.GetColor(.NorthAmericanCityColor, NSColor.blue)
        SouthAmericanCityColorWell.color = Settings.GetColor(.SouthAmericanCityColor, NSColor.orange)
        CapitalCityColorWell.color = Settings.GetColor(.CapitalCityColor, NSColor.yellow)
        CustomCityListColorWell.color = Settings.GetColor(.CustomCityListColor, NSColor.gray)
        CityNodesGlowSwitch.state = Settings.GetBool(.CityNodesGlow) ? .on : .off
        let RelativeFontSize = Settings.GetEnum(ForKey: .CityFontRelativeSize, EnumType: RelativeSizes.self, Default: .Small)
        if let Index = FontSizeMap[RelativeFontSize]
        {
            CityFontSizeSegment.selectedSegment = Index
        }
        else
        {
            CityFontSizeSegment.selectedSegment = 0
        }
    }
    
    let FontSizeMap =
        [
            RelativeSizes.Small: 0,
            RelativeSizes.Medium: 1,
            RelativeSizes.Large: 2
        ]
    
    @IBAction func ShowCitiesChanged(_ sender: Any)
    {
        if let Button = sender as? NSSwitch
        {
            Settings.SetBool(.ShowCities, Button.state == .on ? true : false)
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
                return
            }
            if Segment.indexOfSelectedItem == 1
            {
                Settings.SetEnum(.Metropolitan, EnumType: PopulationTypes.self, ForKey: .PopulationType)
                return
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
                    
                case ShowCustomCitiesSwitch:
                    Settings.SetBool(.ShowCustomCities, IsChecked)
                    
                case PopulationRankSwitch:
                    Settings.SetBool(.ShowCitiesByPopulation, IsChecked)
                    
                default:
                    return
            }
        }
    }
    
    @IBAction func HandleCityFontButtonPressed(_ sender: Any)
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
    
    // MARK: - Font protocol functions.
    
    func CurrentFont() -> StoredFont?
    {
        return Settings.GetFont(.CityFontName, StoredFont("Avenir-Heavy", 15.0, NSColor.orange))
    }
    
    func WantsContinuousUpdates() -> Bool
    {
        return false
    }
    
    func NewFont(_ NewFont: StoredFont)
    {
        print("Have new font: \(FontHelper.PrettyFontName(From: NewFont.PostscriptName)!)")
        Settings.SetFont(.CityFontName, NewFont)
        let EqFont = Settings.GetFont(.CityFontName, StoredFont("Avenir-Heavy", 15.0, NSColor.black))
        if let FontName = FontHelper.PrettyFontName(From: EqFont.PostscriptName)
        {
            CityFontButton.title = FontName
        }
        else
        {
            CityFontButton.title = "Huh?"
        }
    }
    
    func Closed(_ OK: Bool, _ SelectedFont: StoredFont?)
    {
        if OK
        {
            if let NewFont = SelectedFont
            {
                Settings.SetFont(.CityFontName, NewFont)
                let EqFont = Settings.GetFont(.CityFontName, StoredFont("Avenir-Heavy", 15.0, NSColor.black))
                if let FontName = FontHelper.PrettyFontName(From: EqFont.PostscriptName)
                {
                    CityFontButton.title = FontName
                }
                else
                {
                    CityFontButton.title = "Huh?"
                }
            }
        }
    }
    
    @IBAction func HandleFloatingCityNameChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.CityNamesDrawnOnMap, Switch.state == .on ? false : true)
        }
    }
    
    @IBAction func HandleCityColorChanged(_ sender: Any)
    {
        if let ColorWell = sender as? NSColorWell
        {
            switch ColorWell
            {
                case CapitalCityColorWell:
                    Settings.SetColor(.CapitalCityColor, ColorWell.color)
                    
                case SouthAmericanCityColorWell:
                    Settings.SetColor(.SouthAmericanCityColor, ColorWell.color)
                    
                case NorthAmericanCityColorWell:
                    Settings.SetColor(.NorthAmericanCityColor, ColorWell.color)
                    
                case EuropeanCityColorWell:
                    Settings.SetColor(.EuropeanCityColor, ColorWell.color)
                    
                case AsianCityColorWell:
                    Settings.SetColor(.AsianCityColor, ColorWell.color)
                    
                case AfricanCityColorWell:
                    Settings.SetColor(.AfricanCityColor, ColorWell.color)
                    
                case WorldCityColorWell:
                    Settings.SetColor(.WorldCityColor, ColorWell.color)
                    
                case CustomCityListColorWell:
                    Settings.SetColor(.CustomCityListColor, ColorWell.color)
                    
                default:
                    return
            }
        }
    }
    
    @IBAction func HandleCustomCityButtonPressed(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "Settings", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "CustomCityWindow") as? CustomCityWindow
        {
            let Window = WindowController.window
            //let ViewController = Window?.contentViewController as? CustomCityController
            self.view.window?.beginSheet(Window!, completionHandler: nil)
        }
    }
    
    @IBAction func HandleCityNodesGlowChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.CityNodesGlow, Switch.state == .on ? true : false)
        }
    }
    
    @IBAction func HandleSetPopulationFilterButtonPressed(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "Settings", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "CityPopulationWindow") as? CityPopulationWindow
        {
            let Window = WindowController.window
            self.view.window?.beginSheet(Window!)
            {
                _ in
            }
        }
    }
    
    @IBAction func HandleCityFontSizeChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            switch Segment.selectedSegment
            {
                case 0:
                    Settings.SetEnum(.Small, EnumType: RelativeSizes.self, ForKey: .CityFontRelativeSize)
                    
                case 1:
                    Settings.SetEnum(.Medium, EnumType: RelativeSizes.self, ForKey: .CityFontRelativeSize)
                    
                case 2:
                    Settings.SetEnum(.Large, EnumType: RelativeSizes.self, ForKey: .CityFontRelativeSize)
                    
                default:
                    return
            }
        }
    }
    
    @IBOutlet weak var CityFontSizeSegment: NSSegmentedControl!
    @IBOutlet weak var PopulationRankSwitch: NSSwitch!
    @IBOutlet weak var CityNodesGlowSwitch: NSSwitch!
    @IBOutlet weak var ShowCustomCitiesSwitch: NSSwitch!
    @IBOutlet weak var CustomCityListColorWell: NSColorWell!
    @IBOutlet weak var CapitalCityColorWell: NSColorWell!
    @IBOutlet weak var SouthAmericanCityColorWell: NSColorWell!
    @IBOutlet weak var NorthAmericanCityColorWell: NSColorWell!
    @IBOutlet weak var EuropeanCityColorWell: NSColorWell!
    @IBOutlet weak var AsianCityColorWell: NSColorWell!
    @IBOutlet weak var AfricanCityColorWell: NSColorWell!
    @IBOutlet weak var WorldCityColorWell: NSColorWell!
    @IBOutlet weak var FloatingCityNameSwitch: NSSwitch!
    @IBOutlet weak var CityFontButton: NSButton!
    @IBOutlet weak var ShowCapitalCitiesSwitch: NSSwitch!
    @IBOutlet weak var ShowSouthAmericanCitiesSwitch: NSSwitch!
    @IBOutlet weak var ShowNorthAmericanCitiesSwitch: NSSwitch!
    @IBOutlet weak var ShowEuropeanCitiesSwitch: NSSwitch!
    @IBOutlet weak var ShowAsianCitiesSwitch: NSSwitch!
    @IBOutlet weak var ShowAfricanCitiesSwitch: NSSwitch!
    @IBOutlet weak var ShowWorldCitiesSwitch: NSSwitch!
    @IBOutlet weak var PopulationSegment: NSSegmentedControl!
    @IBOutlet weak var ShowCitiesSwitch: NSSwitch!
    @IBOutlet weak var CityShapeCombo: NSComboBox!
}
