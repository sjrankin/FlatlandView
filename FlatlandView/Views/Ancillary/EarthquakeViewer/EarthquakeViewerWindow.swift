//
//  EarthquakeViewerWindow.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/31/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class EarthquakeViewerWindow: NSWindowController
{
    override func windowDidLoad()
    {
        ShowPleaseWait()
        DecorateSwitch.toolTip = "Shows or hides coordinate N, S, E, W labels."
        RegionQuakeButton.toolTip = "Enables filtering by a region."
        UpdateFilterCount(0)
    }
    
    var ChildController: EarthquakeViewerController!
    
    func ShowPleaseWait()
    {
        RoundTextView.TextColor = NSColor.systemRed
        RoundTextView.RotateClockwise = false
        RoundTextView.TextFont = NSFont.boldSystemFont(ofSize: 80.0)
        RoundTextView.TextRadius = 7.0
        RoundTextView.RotationOffset = 0.33
        RoundTextView.AnimationDuration = 0.01
        RoundTextView.ShowText("Please Wait")
        if let Child = self.contentViewController as? EarthquakeViewerController
        {
            ChildController = Child
        }
        else
        {
            fatalError("Error getting content view controller in \(#function)")
        }
    }
    
    func HidePleaseWait()
    {
        RoundTextView.Hide()
    }
    
    @IBAction func HandleDecorateSwitch(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            let SwitchIsOn = Switch.state == .on
            ChildController.HandleDecorateCoordinatesChanged(SwitchIsOn)
        }
    }
    
    @IBAction func HandleComboChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            if let SelectedObject = Combo.objectValueOfSelectedItem as? String
            {
                switch Combo
                {
                    case MagnitudeFilterCombo:
                        ChildController.HandleNewMagnitudeFilter(SelectedObject)
                        
                    case AgeFilterCombo:
                        ChildController.HandleNewAgeFilter(SelectedObject)
                        
                    default:
                        return
                }
            }
        }
    }
    
    @IBAction func HandleRegionalQuakesPressed(_ sender: Any)
    {
        ChildController.RunRegionalQuakeDialog() 
    }
    
    @IBAction func HandleRefreshButtonPressed(_ sender: Any)
    {
        ChildController.HandleRefreshPressed()
    }
    
    func UpdateFilterCount(_ NewValue: Int)
    {
        FilterCountLabel.stringValue = "Filtered quakes: \(NewValue)"
    }
    
    func UpdateRegionalQuakeIcon(Enabled: Bool)
    {
        RegionQuakeButton.image = Enabled ? NSImage(named: "TargetIconOn") : NSImage(named: "TargetIcon")
    }
    
    @IBOutlet weak var RegionQuakeButton: NSButton!
    @IBOutlet weak var FilterCountLabel: NSTextField!
    @IBOutlet weak var DecorateSwitch: NSSwitch!
    @IBOutlet weak var MagnitudeFilterCombo: NSComboBox!
    @IBOutlet weak var AgeFilterCombo: NSComboBox!
    @IBOutlet weak var RefreshButton: NSButton!
    @IBOutlet weak var RoundTextView: RoundTextIndicator!
}
