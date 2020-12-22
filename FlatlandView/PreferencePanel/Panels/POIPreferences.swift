//
//  POIPreferences.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/3/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class POIPreferences: NSViewController, PreferencePanelProtocol
{
    weak var Parent: PreferencePanelControllerProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidLayout()
    {
        super.viewDidLayout()
        ShowHomeSwitch.state = Settings.GetState(.ShowHomeLocation)
//        ShowHomeSwitch.state = Settings.GetBool(.ShowHomeLocation) ? .on : .off
        let WHSSites = Settings.GetEnum(ForKey: .WorldHeritageSiteType, EnumType: WorldHeritageSiteTypes.self, Default: .Natural)
        if let WHSIndex = WorldHeritageSiteTypes.allCases.firstIndex(of: WHSSites)
        {
            UnescoSitesSegment.selectedSegment = WHSIndex
        }
        ShowUnescoSitesSwitch.state = Settings.GetBool(.ShowWorldHeritageSites) ? .on : .off
        ShowCitiesSwitch.state = Settings.GetBool(.ShowCities) ? .on : .off
        ShowUnescoSitesSwitch.state = Settings.GetBool(.ShowWorldHeritageSites) ? .on : .off
        CityShapesCombo.removeAllItems()
        let CurrentShape = Settings.GetEnum(ForKey: .CityShapes, EnumType: CityDisplayTypes.self, Default: .RelativeEmbedded)
        for CityShape in CityDisplayTypes.allCases
        {
            CityShapesCombo.addItem(withObjectValue: CityShape.rawValue)
            if CityShape == CurrentShape
            {
                CityShapesCombo.selectItem(withObjectValue: CityShape.rawValue)
            }
        }
    }
    
    @IBAction func HandleHelpButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            switch Button
            {
                case ShowWorldHeritageSiteHelpButton:
                    Parent?.ShowHelp(For: .ShowUNESCOSites, Where: Button.bounds, What: ShowWorldHeritageSiteHelpButton)
                
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
                    
                case UNESCOHelpButton:
                    Parent?.ShowHelp(For: .UNESCOSites, Where: Button.bounds, What: UNESCOHelpButton)
                    
                case ShowHomeHelpButton:
                    Parent?.ShowHelp(For: .ShowHome, Where: Button.bounds, What: ShowHomeHelpButton)
                    
                case EditHomeLocationHelpButton:
                    Parent?.ShowHelp(For: .EditHome, Where: Button.bounds, What: EditHomeLocationHelpButton)
                    
                case ShowUserPOIHelpButton:
                    Parent?.ShowHelp(For: .ShowUserPOIs, Where: Button.bounds, What: ShowUserPOIHelpButton)
                    
                case EditUserPOIHelpButton:
                    Parent?.ShowHelp(For: .EditUserPOIs, Where: Button.bounds, What: EditUserPOIHelpButton)
            
                default:
                    return
            }
        }
    }
    
    @IBAction func HandleShowCitiesChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.ShowCities, Switch.state == .on ? true : false)
        }
    }
    
    @IBAction func HandleCityShapesChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            if let SelectedShape = Combo.objectValueOfSelectedItem as? String
            {
                if let FinalShape = CityDisplayTypes(rawValue: SelectedShape)
                {
                    Settings.SetEnum(FinalShape, EnumType: CityDisplayTypes.self, ForKey: .CityShapes)
                }
            }
        }
    }
    
    @IBAction func HandleCitiesByPopulationChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            
        }
    }
    
    @IBAction func HandleCapitalCitiesChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            
        }
    }
    
    @IBAction func HandleAllCitiesSwitch(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            
        }
    }
    
    @IBAction func HandleSetPopulationButton(_ sender: Any)
    {
    }
    
    @IBAction func HandleViewUnescoSitesChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.ShowWorldHeritageSites, Switch.state == .on ? true : false)
        }
    }
    
    @IBAction func HandleUnescoSitesChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            let Index = Segment.selectedSegment
            let Final = WorldHeritageSiteTypes.allCases[Index]
            Settings.SetEnum(Final, EnumType: WorldHeritageSiteTypes.self, ForKey: .WorldHeritageSiteType)
        }
    }
    
    @IBAction func HandleShowHomeChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.ShowHomeLocation, Switch.state == .on ? true : false)
        }
    }
    
    @IBAction func HandleEditHomeLocationButton(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "HelperPanels", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "HomeLocationWindow") as?
            HomeLocationWindow
        {
            let Window = WindowController.window
            self.view.window?.beginSheet(Window!)
            {
                Result in
            }
        }
    }
    
    @IBAction func HandleShowUserPOIsChanged(_ sender: Any)
    {
    }
    
    @IBAction func HandleEditUserPOIs(_ sender: Any)
    {
    }
    
    // MARK: - Interface builder outlets
    @IBOutlet weak var ShowCitiesSwitch: NSSwitch!
    @IBOutlet weak var CityShapesCombo: NSComboBox!
    @IBOutlet weak var CitiesByPopulationSwitch: NSSwitch!
    @IBOutlet weak var CapitalCitiesSwitch: NSSwitch!
    @IBOutlet weak var AllCitiesSwitch: NSSwitch!
    @IBOutlet weak var UnescoSitesSegment: NSSegmentedControl!
    @IBOutlet weak var ShowHomeSwitch: NSSwitch!
    @IBOutlet weak var ShowUserPOISwitch: NSSwitch!
    @IBOutlet weak var ShowUnescoSitesSwitch: NSSwitch!
    
    // MARK: - Help buttons
    @IBOutlet weak var ShowWorldHeritageSiteHelpButton: NSButton!
    @IBOutlet weak var AllCitiesHelpButton: NSButton!
    @IBOutlet weak var CapitalCityHelpButton: NSButton!
    @IBOutlet weak var CityByPopHelpButton: NSButton!
    @IBOutlet weak var CityShapeHelpButton: NSButton!
    @IBOutlet weak var ShowCityHelpButton: NSButton!
    @IBOutlet weak var EditUserPOIHelpButton: NSButton!
    @IBOutlet weak var ShowUserPOIHelpButton: NSButton!
    @IBOutlet weak var EditHomeLocationHelpButton: NSButton!
    @IBOutlet weak var ShowHomeHelpButton: NSButton!
    @IBOutlet weak var UNESCOHelpButton: NSButton!
}
