//
//  EarthquakePreferences.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/3/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class EarthquakePreferences: NSViewController, PreferencePanelProtocol
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
                case AnimateEarthquakeShapeHelpButton:
                    Parent?.ShowHelp(For: .AnimateQuakes, Where: Button.bounds, What: AnimateEarthquakeShapeHelpButton)
                    
                case QuakeRegionsHelpButton:
                    Parent?.ShowHelp(For: .QuakeRegions, Where: Button.bounds, What: QuakeRegionsHelpButton)
                    
                case DisplayQuakesHelpButton:
                    Parent?.ShowHelp(For: .DisplayQuakes, Where: Button.bounds, What: DisplayQuakesHelpButton)
                    
                case EnableRegionsHelpButton:
                    Parent?.ShowHelp(For: .EnableQuakeRegions, Where: Button.bounds, What: EnableRegionsHelpButton)
                    
                case QuakeFetchFrequencyHelpButton:
                    Parent?.ShowHelp(For: .QuakeFetchFrequency, Where: Button.bounds, What: QuakeFetchFrequencyHelpButton)
                    
                case SelectQuakeShapeHelpButton:
                    Parent?.ShowHelp(For: .QuakeShape, Where: Button.bounds, What: SelectQuakeShapeHelpButton)
                    
                case QuakeHighlightHelpButton:
                    Parent?.ShowHelp(For: .QuakeHighlight, Where: Button.bounds, What: QuakeHighlightHelpButton)
                    
                default:
                    return
            }
        }
    }
    
    @IBOutlet weak var AnimateEarthquakeShapeHelpButton: NSButton!
    @IBOutlet weak var QuakeRegionsHelpButton: NSButton!
    @IBOutlet weak var DisplayQuakesHelpButton: NSButton!
    @IBOutlet weak var EnableRegionsHelpButton: NSButton!
    @IBOutlet weak var QuakeFetchFrequencyHelpButton: NSButton!
    @IBOutlet weak var SelectQuakeShapeHelpButton: NSButton!
    @IBOutlet weak var QuakeHighlightHelpButton: NSButton!
}
