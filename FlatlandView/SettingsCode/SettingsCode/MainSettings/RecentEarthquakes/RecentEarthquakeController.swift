//
//  RecentEarthquakeController.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/26/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class RecentEarthquakeController: NSViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        EarthquakeColorWell.color = Settings.GetColor(.EarthquakeColor, NSColor.red)
        
        TexturesCombo.removeAllItems()
        for Texture in EarthquakeTextures.allCases
        {
            TexturesCombo.addItem(withObjectValue: Texture.rawValue)
        }
        let CurrentTexture = Settings.GetEnum(ForKey: .EarthquakeTextures, EnumType: EarthquakeTextures.self, Default: .SolidColor)
        TexturesCombo.selectItem(withObjectValue: CurrentTexture.rawValue)
        
        EarthquakeStyleCombo.removeAllItems()
        for Style in EarthquakeIndicators.allCases
        {
            EarthquakeStyleCombo.addItem(withObjectValue: Style.rawValue)
        }
        let CurrentStyle = Settings.GetEnum(ForKey: .EarthquakeStyles, EnumType: EarthquakeIndicators.self, Default: .None)
        EarthquakeStyleCombo.selectItem(withObjectValue: CurrentStyle.rawValue)
        
        RecentCombo.removeAllItems()
        for Recent in EarthquakeRecents.allCases
        {
            RecentCombo.addItem(withObjectValue: Recent.rawValue)
        }
        let NowRecent = Settings.GetEnum(ForKey: .RecentEarthquakeDefinition, EnumType: EarthquakeRecents.self, Default: .Day1)
        RecentCombo.selectItem(withObjectValue: NowRecent.rawValue)
    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent?.endSheet(Window!, returnCode: .OK)
    }
    
    @IBAction func HandleEarthquakeStyleChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            if let Raw = Combo.objectValueOfSelectedItem as? String
            {
                if let Item = EarthquakeIndicators(rawValue: Raw)
                {
                    Settings.SetEnum(Item, EnumType: EarthquakeIndicators.self, ForKey: .EarthquakeStyles)
                }
            }
        }
    }
    
    @IBAction func HandleRecentComboChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            if let Raw = Combo.objectValueOfSelectedItem as? String
            {
                if let Item = EarthquakeRecents(rawValue: Raw)
                {
                    Settings.SetEnum(Item, EnumType: EarthquakeRecents.self, ForKey: .RecentEarthquakeDefinition)
                }
            }
        }
    }
    
    @IBAction func HandleTexturesComboChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            if let Raw = Combo.objectValueOfSelectedItem as? String
            {
                if let Item = EarthquakeTextures(rawValue: Raw)
                {
                    Settings.SetEnum(Item, EnumType: EarthquakeTextures.self, ForKey: .EarthquakeStyles)
                }
            }
        }
    }
    
    @IBAction func HandleEarthquakeColorChanged(_ sender: Any)
    {
        if let Well = sender as? NSColorWell
        {
            Settings.SetColor(.EarthquakeColor, Well.color)
        }
    }
    
    @IBOutlet weak var EarthquakeColorWell: NSColorWell!
    @IBOutlet weak var TexturesCombo: NSComboBox!
    @IBOutlet weak var RecentCombo: NSComboBox!
    @IBOutlet weak var EarthquakeStyleCombo: NSComboBox!
}
