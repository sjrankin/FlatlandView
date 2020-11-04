//
//  RegionalQuakeController.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/1/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class RegionalQuakeController: NSViewController, NSTextFieldDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if Settings.GetBool(.QuakeRegionEnable)
        {
            let Distance = Settings.GetDoubleNil(.QuakeRegionRadius, 100.0)
            let Latitude = Settings.GetDoubleNil(.QuakeRegionLatitude, 0.0)
            let Longitude = Settings.GetDoubleNil(.QuakeRegionLongitude, 0.0)
            DistanceBox.stringValue = "\(Distance!)"
            LatitudeBox.stringValue = "\(Latitude!)"
            LongitudeBox.stringValue = "\(Longitude!)"
            EnableRegionSwitch.state = .on
        }
        else
        {
            DistanceBox.stringValue = ""
            LatitudeBox.stringValue = ""
            LongitudeBox.stringValue = ""
            EnableRegionSwitch.state = .off
        }
        QuakeSetSegment.selectedSegment = Settings.GetBool(.QuakeSetAll) ? 0 : 1
    }
    
    @IBAction func HandleOKButton(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent?.endSheet(Window!, returnCode: .OK)
    }

    @IBAction func HandleCancelButton(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent?.endSheet(Window!, returnCode: .cancel)
    }
    
    func RemoveNonNumerals(From: String) -> String
    {
        var Results = ""
        for Char in From
        {
            if ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "+", "-"].contains(String(Char))
            {
                Results.append(String(Char))
            }
        }
        return Results
    }
    
    func ParseDistance(_ Raw: String, Changed: inout Bool) -> Double
    {
        Changed = false
        if Raw.count < 1
        {
            Changed = true
            return 0.0
        }
        if let Converted = Double(Raw)
        {
            if Converted > (PhysicalConstants.EarthCircumference.rawValue / 2.0)
            {
                Changed = true
                return PhysicalConstants.EarthCircumference.rawValue / 2.0
            }
            return Converted
        }
        let Stripped = RemoveNonNumerals(From: Raw)
        return ParseDistance(Stripped, Changed: &Changed)
    }
    
    func ParseCoordinate(_ Raw: String, IsLatitude: Bool, Changed: inout Bool) -> Double
    {
        Changed = false
        if Raw.count < 1
        {
            Changed = true
            return 0.0
        }
        if let Converted = Double(Raw)
        {
            if IsLatitude
            {
                if Converted < -90.0
                {
                    Changed = true
                    return -90.0
                }
                if Converted > 90.0
                {
                    Changed = true
                    return 90.0
                }
                return Converted
            }
            else
            {
                if Converted < -180.0
                {
                    Changed = true
                    return -180.0
                }
                if Converted > 180.0
                {
                    Changed = true
                    return 180.0
                }
            }
            return Converted
        }
        var ChangedAgain = false
        if IsLatitude
        {
        if Raw.contains("N")
        {
            let Removed = RemoveNonNumerals(From: Raw)
            let Again = ParseCoordinate(Removed, IsLatitude: true, Changed: &ChangedAgain)
            Changed = true
            return Again
        }
        if Raw.contains("S")
        {
            let Removed = RemoveNonNumerals(From: Raw)
            let Again = ParseCoordinate(Removed, IsLatitude: true, Changed: &ChangedAgain) * -1.0
            Changed = true
            return Again
        }
        }
        else
        {
            if Raw.contains("E")
            {
                let Removed = RemoveNonNumerals(From: Raw)
                let Again = ParseCoordinate(Removed, IsLatitude: false, Changed: &ChangedAgain)
                Changed = true
                return Again
            }
            if Raw.contains("W")
            {
                let Removed = RemoveNonNumerals(From: Raw)
                let Again = ParseCoordinate(Removed, IsLatitude: false, Changed: &ChangedAgain) * -1.0
                Changed = true
                return Again
            }
        }
        return 0.0
    }
    
    func controlTextDidEndEditing(_ obj: Notification)
    {
        if let TextField = obj.object as? NSTextField
        {
            var ChangedValue = false
            let Raw = TextField.stringValue
            switch TextField
            {
                case LatitudeBox:
                    let Latitude = ParseCoordinate(Raw, IsLatitude: true, Changed: &ChangedValue)
                    if ChangedValue
                    {
                        LatitudeBox.stringValue = "\(Latitude)"
                    }
                    Settings.SetDoubleNil(.QuakeRegionLatitude, Latitude)
                    
                case LongitudeBox:
                    let Longitude = ParseCoordinate(Raw, IsLatitude: false, Changed: &ChangedValue)
                    if ChangedValue
                    {
                        LongitudeBox.stringValue = "\(Longitude)"
                    }
                    Settings.SetDoubleNil(.QuakeRegionLongitude, Longitude)
                    
                case DistanceBox:
                    let Distance = ParseDistance(Raw, Changed: &ChangedValue)
                    if ChangedValue
                    {
                        DistanceBox.stringValue = "\(Distance)"
                    }
                    Settings.SetDoubleNil(.QuakeRegionRadius, Distance)
                    
                default:
                    return
            }
        }
    }
    
    @IBAction func HandleEnableRegionChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.QuakeRegionEnable, Switch.state == .on)
        }
    }
    
    @IBAction func HandleQuakeSetSegmentChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            Settings.SetBool(.QuakeSetAll, Segment.selectedSegment == 0 ? true : false)
        }
    }
    
    @IBOutlet weak var QuakeSetSegment: NSSegmentedControl!
    @IBOutlet weak var EnableRegionSwitch: NSSwitch!
    @IBOutlet weak var LatitudeBox: NSTextField!
    @IBOutlet weak var LongitudeBox: NSTextField!
    @IBOutlet weak var DistanceBox: NSTextField!
}
