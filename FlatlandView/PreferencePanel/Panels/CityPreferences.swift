//
//  CityPreferences.swift
//  Flatland
//
//  Created by Stuart Rankin on 2/7/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class CityPreferences: NSViewController, PreferencePanelProtocol
{
    weak var Parent: PreferencePanelControllerProtocol? = nil
    weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidLayout()
    {
        super.viewDidLayout()
        
        ShowCitiesSwitch.state = Settings.GetBool(.ShowCities) ? .on : .off
        CityShapesCombo.removeAllItems()
        for Shape in CityDisplayTypes.allCases
        {
            let Name = Shape.rawValue
            CityShapesCombo.addItem(withObjectValue: Name)
        }
        let CurrentShape = Settings.GetEnum(ForKey: .CityShapes, EnumType: CityDisplayTypes.self, Default: .UniformEmbedded)
        CityShapesCombo.selectItem(withObjectValue: CurrentShape.rawValue)
        
        HelpButtons.append(AllCitiesHelpButton)
        HelpButtons.append(CapitalCityHelpButton)
        HelpButtons.append(CityShapeHelpButton)
        HelpButtons.append(ShowCityHelpButton)
        HelpButtons.append(CityByPopHelpButton)
        SetHelpVisibility(To: Settings.GetBool(.ShowUIHelp))
    }
    
    @IBAction func ShowCitySwitchChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.ShowCities, Switch.state == .on ? true : false)
        }
    }
    
    @IBAction func ShowCitiesByPopulationChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.ShowCitiesByPopulation, Switch.state == .on ? true : false)
        }
    }
    
    @IBAction func ShowAllCitiesChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
        }
    }
    
    @IBAction func ShowCapitalCitiesChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.ShowCapitalCities, Switch.state == .on ? true : false)
        }
    }
    
    @IBAction func HandleCityShapeChanged(_ sender: Any)
    {
        if let ComboBox = sender as? NSComboBox
        {
            if let SelectedItem = ComboBox.objectValueOfSelectedItem
            {
                if let Selected = SelectedItem as? String
                {
                    if let Shape = CityDisplayTypes(rawValue: Selected)
                    {
                        Settings.SetEnum(Shape, EnumType: CityDisplayTypes.self, ForKey: .CityShapes)
                    }
                }
            }
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
    
    func SetDarkMode(To: Bool)
    {
    }
    
    @IBAction func HandleHelpButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            switch Button
            {
                case ShowCityHelpButton:
                    Parent?.ShowHelp(For: .ShowCities, Where: Button.bounds, What: ShowCityHelpButton)
                    
                case CapitalCityHelpButton:
                    Parent?.ShowHelp(For: .CapitalCities, Where: Button.bounds, What: CapitalCityHelpButton)
                    
                case CityByPopHelpButton:
                    Parent?.ShowHelp(For: .CityByPopulation, Where: Button.bounds, What: CityByPopHelpButton)
                    
                case CityShapeHelpButton:
                    Parent?.ShowHelp(For: .CityShape, Where: Button.bounds, What: CityShapeHelpButton)
                    
                case AllCitiesHelpButton:
                    Parent?.ShowHelp(For: .AllCities, Where: Button.bounds, What: AllCitiesHelpButton)
                    
                default:
                    return
            }
        }
    }
    
    func SetHelpVisibility(To: Bool)
    {
        for HelpButton in HelpButtons
        {
            HelpButton.alphaValue = To ? 1.0 : 0.0
            HelpButton.isEnabled = To ? true : false
        }
    }
    
    var HelpButtons: [NSButton] = [NSButton]()
    
    // MARK: - Interface builder outlets
    @IBOutlet weak var ShowCitiesSwitch: NSSwitch!
    @IBOutlet weak var CityShapesCombo: NSComboBox!
    @IBOutlet weak var CitiesByPopulationSwitch: NSSwitch!
    @IBOutlet weak var CapitalCitiesSwitch: NSSwitch!
    @IBOutlet weak var AllCitiesSwitch: NSSwitch!
    
    // MARK: - Help buttons
    
    @IBOutlet weak var AllCitiesHelpButton: NSButton!
    @IBOutlet weak var CapitalCityHelpButton: NSButton!
    @IBOutlet weak var CityByPopHelpButton: NSButton!
    @IBOutlet weak var CityShapeHelpButton: NSButton!
    @IBOutlet weak var ShowCityHelpButton: NSButton!
    
}