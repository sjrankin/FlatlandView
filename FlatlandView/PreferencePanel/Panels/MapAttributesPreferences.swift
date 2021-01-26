//
//  MapAttributesPreferences.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class MapAttributesPreferences: NSViewController, PreferencePanelProtocol
{
    weak var Parent: PreferencePanelControllerProtocol? = nil
    weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        HelpButtons.append(ShowGridLineHelpButton)
        HelpButtons.append(GridLineColorHelpButton)
        HelpButtons.append(BackgroundColorHelpButton)
        HelpButtons.append(FlatMapNightLevelHelpButton)
        HelpButtons.append(PoleShapeHelpButton)
        SetHelpVisibility(To: Settings.GetBool(.ShowUIHelp))
    }
    
    @IBAction func HandleHelpButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            switch Button
            {
                case ShowGridLineHelpButton:
                    Parent?.ShowHelp(For: .ShowGridLines, Where: Button.bounds, What: ShowGridLineHelpButton)
                    
                case GridLineColorHelpButton:
                    Parent?.ShowHelp(For: .GridLineColor, Where: Button.bounds, What: GridLineColorHelpButton)
                    
                case BackgroundColorHelpButton:
                    Parent?.ShowHelp(For: .BackgroundColor, Where: Button.bounds, What: BackgroundColorHelpButton)
                    
                case FlatMapNightLevelHelpButton:
                    Parent?.ShowHelp(For: .FlatNightDarkness, Where: Button.bounds, What: FlatMapNightLevelHelpButton)
                    
                case ShowMoonlightHelpButton:
                    Parent?.ShowHelp(For: .ShowMoonlight, Where: Button.bounds, What: ShowMoonlightHelpButton)
                    
                case PoleShapeHelpButton:
                    Parent?.ShowHelp(For: .PoleShape, Where: Button.bounds, What: PoleShapeHelpButton)
            
                default:
                    break
            }
        }
    }
    
    func SetDarkMode(To: Bool)
    {
        
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

    @IBOutlet weak var ShowGridLineHelpButton: NSButton!
    @IBOutlet weak var GridLineColorHelpButton: NSButton!
    @IBOutlet weak var BackgroundColorHelpButton: NSButton!
    @IBOutlet weak var FlatMapNightLevelHelpButton: NSButton!
    @IBOutlet weak var ShowMoonlightHelpButton: NSButton!
    @IBOutlet weak var PoleShapeHelpButton: NSButton!
    
}
