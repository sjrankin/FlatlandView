//
//  CityPopulationController2.swift
//  Flatland
//
//  Created by Stuart Rankin on 2/16/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class CityPopulationController2: NSViewController, NSTextFieldDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        CityPopulationColor.color = Settings.GetColor(.PopulationColor, NSColor.white)
        UseMetropolitanSwitch.state = Settings.GetBool(.PopulationRankIsMetro) ? .on : .off
        GreaterThanCheck.state = Settings.GetBool(.PopulationFilterGreater) ? .on : .off
        let PopRankFilter = Settings.GetInt(.PopulationFilterValue, IfZero: 1000000)
        PopulationBox.stringValue = "\(PopRankFilter)"
        let PopFilter = Settings.GetEnum(ForKey: .PopulationFilterType, EnumType: PopulationFilterTypes.self,
                                         Default: .ByRank)
        switch PopFilter
        {
            case .ByRank:
                ByRankSwitch.state = .on
                ByPopulationSwitch.state = .off
                
            case .ByPopulation:
                ByRankSwitch.state = .off
                ByPopulationSwitch.state = .on
        }
        let Rank = Settings.GetInt(.PopulationRank, IfZero: 100)
        switch Rank
        {
            case 10:
                RankSegment.selectedSegment = 0
                
            case 20:
                RankSegment.selectedSegment = 1
                
            case 50:
                RankSegment.selectedSegment = 2
                
            case 100:
                RankSegment.selectedSegment = 3
                
            case 150:
                RankSegment.selectedSegment = 4
                
            case 200:
                RankSegment.selectedSegment = 5
                
            default:
                RankSegment.selectedSegment = 3
        }
    }
    
    func controlTextDidEndEditing(_ obj: Notification)
    {
        if let TextField = obj.object as? NSTextField
        {
            let Raw = TextField.stringValue
            if let ActualValue = Int(Raw)
            {
                Settings.SetInt(.PopulationFilterValue, ActualValue)
            }
        }
    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent?.endSheet(Window!, returnCode: .OK)
    }
    
    @IBAction func HandleFilterTypeChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            switch Switch
            {
                case ByRankSwitch:
                    ByRankSwitch.state = .on
                    ByPopulationSwitch.state = .off
                    Settings.SetEnum(.ByRank, EnumType: PopulationFilterTypes.self, ForKey: .PopulationFilterType)
                    
                case ByPopulationSwitch:
                    ByRankSwitch.state = .off
                    ByPopulationSwitch.state = .on
                    Settings.SetEnum(.ByPopulation, EnumType: PopulationFilterTypes.self, ForKey: .PopulationFilterType)
                    
                default:
                    return
            }
        }
    }
    
    @IBAction func HandleRankSegmentChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            var Value = 100
            switch Segment.selectedSegment
            {
                case 0:
                    Value = 10
                    
                case 1:
                    Value = 20
                    
                case 2:
                    Value = 50
                    
                case 3:
                    Value = 100
                    
                case 4:
                    Value = 150
                    
                case 5:
                    Value = 200
                    
                default:
                    Value = 100
            }
            Settings.SetInt(.PopulationRank, Value)
        }
    }
    
    @IBAction func HandleCityColorChanged(_ sender: Any)
    {
        if let ColorWell = sender as? NSColorWell
        {
            Settings.SetColor(.PopulationColor, ColorWell.color)
        }
    }
    
    @IBAction func HandleUseMetroChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.PopulationRankIsMetro, Switch.state == .on ? true: false)
        }
    }
    
    @IBAction func HandleGreaterThanChanged(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            Settings.SetBool(.PopulationFilterGreater, Button.state == .on ? true : false)
        }
    }
    
    @IBOutlet weak var UseMetropolitanSwitch: NSSwitch!
    @IBOutlet weak var RankSegment: NSSegmentedControl!
    @IBOutlet weak var GreaterThanCheck: NSButton!
    @IBOutlet weak var PopulationBox: NSTextField!
    @IBOutlet weak var CityPopulationColor: NSColorWell!
    @IBOutlet weak var ByPopulationSwitch: NSSwitch!
    @IBOutlet weak var ByRankSwitch: NSSwitch!
}
