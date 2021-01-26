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
    weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let PreviousScale = Settings.GetEnum(ForKey: .QuakeScales, EnumType: MapNodeScales.self, Default: .Normal)
        switch PreviousScale
        {
            case .Small:
                QuakeScaleSegment.selectedSegment = 0
                
            case .Normal:
                QuakeScaleSegment.selectedSegment = 1
                
            case .Large:
                QuakeScaleSegment.selectedSegment = 2
        }
        FetchFrequencyCombo.removeAllItems()
        FetchFrequencyCombo.addItem(withObjectValue: "30 seconds")
        FetchFrequencyCombo.addItem(withObjectValue: "1 minute")
        FetchFrequencyCombo.addItem(withObjectValue: "5 minutes")
        FetchFrequencyCombo.addItem(withObjectValue: "10 minutes")
        FetchFrequencyCombo.addItem(withObjectValue: "30 minutes")
        FetchFrequencyCombo.addItem(withObjectValue: "1 hour")
        let FetchInterval = Settings.GetDouble(.EarthquakeFetchInterval, 60.0 * 5.0)
        if let Index = FetchFrequencies.firstIndex(of: FetchInterval)
        {
            FetchFrequencyCombo.selectItem(at: Index)
        }
        else
        {
            FetchFrequencyCombo.selectItem(at: 2)
        }
        QuakeShapeCombo.removeAllItems()
        let EShape = Settings.GetEnum(ForKey: .EarthquakeShapes, EnumType: EarthquakeShapes.self, Default: .Sphere)
        for SomeShape in EarthquakeShapes.allCases
        {
            QuakeShapeCombo.addItem(withObjectValue: SomeShape.rawValue)
        }
        QuakeShapeCombo.selectItem(withObjectValue: EShape.rawValue)
        DisplayQuakesSwitch.state = Settings.GetBool(.EnableEarthquakes) ? .on : .off
        HighlightNewQuakesSwitch.state = Settings.GetState(.HighlightRecentEarthquakes)
        
        HelpButtons.append(QuakeScaleHelpButton)
        HelpButtons.append(CheckEarthquakesNowHelpButton)
        HelpButtons.append(QuakeFetchFrequencyHelpButton)
        HelpButtons.append(QuakeRegionsHelpButton)
        HelpButtons.append(DisplayQuakesHelpButton)
        HelpButtons.append(EnableRegionsHelpButton)
        HelpButtons.append(SelectQuakeShapeHelpButton)
        HelpButtons.append(QuakeHighlightHelpButton)
        SetHelpVisibility(To: Settings.GetBool(.ShowUIHelp))
    }
    
    let FetchFrequencies: [Double] = [30.0, 60.0, 300.0, 600.0, 1800.0, 3600.0]
    
    @IBAction func HandleHelpButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            switch Button
            {
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
                    
                case CheckEarthquakesNowHelpButton:
                    Parent?.ShowHelp(For: .QuakeCheckNow, Where: Button.bounds, What: CheckEarthquakesNowHelpButton)
                    
                case QuakeScaleHelpButton:
                    Parent?.ShowHelp(For: .QuakeScale, Where: Button.bounds, What: QuakeScaleHelpButton)
                    
                default:
                    return
            }
        }
    }
    
    @IBAction func SetRegionsButtonHandler(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "PreferencePanel", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "EarthquakeRegionWindow3") as? EarthquakeRegionWindow3
        {
            let Window = WindowController.window
            self.view.window?.beginSheet(Window!)
            {
                _ in
            }
        }
    }
    
    @IBAction func HandleCheckForEarthquakesNow(_ sender: Any)
    {
        MainDelegate?.GetEarthquakeController()?.ForceFetch()
    }
    
    @IBAction func HandleHighlightEarthquakesChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetState(.HighlightRecentEarthquakes, Switch.state)
        }
    }
    
    @IBAction func HandleEnableRegionsSwitchChanged(_ sender: Any)
    {

    }
    
    @IBAction func HandleEnableQuakesChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.EnableEarthquakes, Switch.state == .on ? true : false)
        }
    }
    
    @IBAction func HandleComboChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            let Index = Combo.indexOfSelectedItem
            switch Combo
            {
                case QuakeShapeCombo:
                    if let RawValue = Combo.objectValueOfSelectedItem as? String
                    {
                        if let Raw = EarthquakeShapes(rawValue: RawValue)
                        {
                            Settings.SetEnum(Raw, EnumType: EarthquakeShapes.self, ForKey: .EarthquakeShapes)
                        }
                    }
                    
                case FetchFrequencyCombo:
                    if Index >= FetchFrequencies.count
                    {
                        return
                    }
                    let Frequency = FetchFrequencies[Index]
                    Settings.SetDouble(.EarthquakeFetchInterval, Frequency)
                    
                default:
                    return
            }
        }
    }
    
    @IBAction func HandleQuakeScaleChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            let Index = Segment.selectedSegment
            if Index <= MapNodeScales.allCases.count - 1
            {
                let NewScale = MapNodeScales.allCases[Index]
                Settings.SetEnum(NewScale, EnumType: MapNodeScales.self, ForKey: .QuakeScales)
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

    @IBOutlet weak var QuakeScaleSegment: NSSegmentedControl!
    @IBOutlet weak var QuakeScaleHelpButton: NSButton!
    @IBOutlet weak var QuakeShapeCombo: NSComboBox!
    @IBOutlet weak var FetchFrequencyCombo: NSComboBox!
    @IBOutlet weak var HighlightNewQuakesSwitch: NSSwitch!
    @IBOutlet weak var EnableRegionsSwitch: NSSwitch!
    @IBOutlet weak var DisplayQuakesSwitch: NSSwitch!
    @IBOutlet weak var CheckEarthquakesNowHelpButton: NSButton!
    @IBOutlet weak var QuakeRegionsHelpButton: NSButton!
    @IBOutlet weak var DisplayQuakesHelpButton: NSButton!
    @IBOutlet weak var EnableRegionsHelpButton: NSButton!
    @IBOutlet weak var QuakeFetchFrequencyHelpButton: NSButton!
    @IBOutlet weak var SelectQuakeShapeHelpButton: NSButton!
    @IBOutlet weak var QuakeHighlightHelpButton: NSButton!
}
