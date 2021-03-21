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
        //ShowPleaseWait()
        RegionQuakeButton.toolTip = "Enables filtering by a region."
    }
    
    var ChildController: EarthquakeViewerController!
    
    func ShowPleaseWait()
    {
        let Trace = Debug.StackFrameContents(10)
        Debug.Print("ShowPleaseWait: \(Debug.PrettyStackTrace(Trace))")
        WorkingItem.label = "Downloading"
        WorkingIndicator.startAnimation(self)
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
        WorkingIndicator.stopAnimation(self)
        WorkingItem.label = ""
    }
    
    func ShowNextIndicator(For Seconds: Double)
    {
        let Trace = Debug.StackFrameContents(10)
        Debug.Print("ShowNextIndicator: \(Debug.PrettyStackTrace(Trace))")
        NextIndicator.minValue = 0.0
        NextIndicator.maxValue = 1.0
        NextIndicator.isHidden = false
        NextItem.label = "Next"
        UpdateElapsedTime = 0.0
        TotalUpdateTime = Seconds
        UpdateTimer = Timer.scheduledTimer(timeInterval: UpdateInterval,
                                           target: self,
                                           selector: #selector(UpdateNextIndicator),
                                           userInfo: nil,
                                           repeats: true)
    }
    
    @objc func UpdateNextIndicator()
    {
        UpdateElapsedTime = UpdateElapsedTime + UpdateInterval
        if UpdateElapsedTime >= TotalUpdateTime
        {
            NextIndicator.doubleValue = 1.0
            UpdateTimer?.invalidate()
            UpdateTimer = nil
        }
        else
        {
            NextIndicator.doubleValue = UpdateElapsedTime / TotalUpdateTime
        }
    }
    
    var UpdateElapsedTime: Double = 0.0
    let UpdateInterval: Double = 0.1
    var UpdateTimer: Timer? = nil
    var TotalUpdateTime: Double = 0.0
    
    func HideNextIndicator()
    {
        NextItem.label = ""
        NextIndicator.isHidden = true
        UpdateTimer?.invalidate()
        UpdateTimer = nil
    }
    
    @IBAction func HandleRegionalQuakesPressed(_ sender: Any)
    {
        ChildController.RunRegionalQuakeDialog() 
    }
    
    @IBAction func HandleRefreshButtonPressed(_ sender: Any)
    {
        ChildController.HandleRefreshPressed()
    }
    
    func UpdateRegionalQuakeIcon(Enabled: Bool)
    {
        RegionQuakeButton.isEnabled = Enabled
//        RegionQuakeButton.image = Enabled ? NSImage(named: "TargetIconOn") : NSImage(named: "TargetIcon")
    }
    
    @IBOutlet weak var NextIndicator: NSProgressIndicator!
    @IBOutlet weak var NextItem: NSToolbarItem!
    @IBOutlet weak var WorkingItem: NSToolbarItem!
    @IBOutlet weak var WorkingIndicator: NSProgressIndicator!
    @IBOutlet weak var RegionQuakeButton: NSButton!
    @IBOutlet weak var RefreshButton: NSButton!
}
