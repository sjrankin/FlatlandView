//
//  PerformanceOptions.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/10/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class PerformanceOptions: NSViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InitializePerformanceSettings()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    let SmoothMap = [TextSmoothnesses.Smoothest.rawValue,
                     TextSmoothnesses.Smooth.rawValue,
                     TextSmoothnesses.Medium.rawValue,
                     TextSmoothnesses.Rough.rawValue,
                     TextSmoothnesses.Roughest.rawValue]
    
    func InitializePerformanceSettings()
    {
        let Smooth = Settings.GetCGFloat(.TextSmoothness, 0.2)
        if let Index = SmoothMap.firstIndex(of: Smooth)
        {
            SmoothSegment.selectedSegment = Index
        }
        else
        {
            SmoothSegment.selectedSegment = 2
        }
        LiveDataChamferSwitch.state = Settings.GetBool(.UseLiveDataChamfer) ? .on : .off
        HourChamferSwitch.state = Settings.GetBool(.UseHourChamfer) ? .on : .off
    }
    
    @IBAction func HandleSmoothnessChanged(_ sender: Any)
    {
        if let Smooth = sender as? NSSegmentedControl
        {
            let Value = SmoothMap[Smooth.selectedSegment]
            Settings.SetCGFloat(.TextSmoothness, Value)
        }
    }
    
    @IBAction func HandleLiveDataChamferSwitch(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.UseLiveDataChamfer, Switch.state == .on ? true : false)
        }
    }
    
    @IBAction func HandleHourChamferChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.UseHourChamfer, Switch.state == .on ? true : false)
        }
    }
    
    @IBOutlet weak var LiveDataChamferSwitch: NSSwitch!
    @IBOutlet weak var HourChamferSwitch: NSSwitch!
    @IBOutlet weak var SmoothSegment: NSSegmentedControl!
}
