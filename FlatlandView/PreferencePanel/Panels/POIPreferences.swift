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
    
    @IBAction func HandleHelpButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            switch Button
            {
                case ShowCityHelpButton:
                    Parent?.ShowHelp(For: .ShowCities, Where: Button.bounds, What: ShowCityHelpButton)
                    
                case CapitalCityHelpButton:
                    Parent?.ShowHelp(For: .CityShape, Where: Button.bounds, What: CapitalCityHelpButton)
                    
                case CityByPopHelpButton:
                    Parent?.ShowHelp(For: .CityByPopulation, Where: Button.bounds, What: CityByPopHelpButton)
                    
                case CityShapeHelpButton:
                    Parent?.ShowHelp(For: .CapitalCities, Where: Button.bounds, What: CityShapeHelpButton)
                    
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
