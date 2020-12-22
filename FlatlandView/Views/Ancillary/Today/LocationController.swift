//
//  LocationController.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/26/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class LocationController: NSViewController, NSTextFieldDelegate
{
    override func viewDidLoad()
    {
        LocationNameField.stringValue = ""
        LongitudeField.stringValue = ""
        LatitudeField.stringValue = ""
        LongitudeField.wantsLayer = true
        LongitudeField.isBezeled = false
        LongitudeField.drawsBackground = false
        LongitudeField.layer?.zPosition = 500
        LongitudeField.backgroundColor = NSColor.clear
        LongitudeField.layer?.backgroundColor = NSColor.clear.cgColor
        LatitudeField.wantsLayer = true
        LatitudeField.isBezeled = false
        LatitudeField.drawsBackground = false
        LatitudeField.layer?.zPosition = 500
        LatitudeField.backgroundColor = NSColor.clear
        LatitudeField.layer?.backgroundColor = NSColor.clear.cgColor
        LongitudeBackground.wantsLayer = true
        LongitudeBackground.layer?.backgroundColor = NSColor(HexString: "#e0e0e0")!.cgColor
        LongitudeBackground.layer?.zPosition = 100
        LatitudeBackground.wantsLayer = true
        LatitudeBackground.layer?.backgroundColor = NSColor(HexString: "#e0e0e0")!.cgColor
        LatitudeBackground.layer?.zPosition = 100
    }
    
    public var IsForHomeLocation: Bool = false
    {
        didSet
        {
            if IsForHomeLocation
            {
                ExplanatoryText.stringValue = """
Enter/edit your home location name and coordinates.
"""
                let Where = Settings.GetString(.UserHomeName, "")
                let Lat = Settings.GetDoubleNil(.UserHomeLatitude)
                let Lon = Settings.GetDoubleNil(.UserHomeLongitude)
                if Lat == nil || Lon == nil
                {
                    return
                }
                LocationNameField.stringValue = Where
                LatitudeField.stringValue = "\(Lat!.RoundedTo(4))"
                LongitudeField.stringValue = "\(Lon!.RoundedTo(4))"
            }
            else
            {
                ExplanatoryText.stringValue = """
Enter the location where you want to see current values.
"""
                let Where = Settings.GetString(.DailyLocationName, "")
                let Lat = Settings.GetDoubleNil(.DailyLocationLatitude)
                let Lon = Settings.GetDoubleNil(.DailyLocationLongitude)
                if Lat == nil || Lon == nil
                {
                    return
                }
                LocationNameField.stringValue = Where
                LatitudeField.stringValue = "\(Lat!.RoundedTo(4))"
                LongitudeField.stringValue = "\(Lon!.RoundedTo(4))"
            }
        }
    }
    
    func LatitudeIsOK(_ Raw: String) -> Bool
    {
        if let Value = Double(Raw)
        {
            if Value >= -90.0 && Value <= 90.0
            {
                return true
            }
        }
        return false
    }
    
    func LongitudeIsOK(_ Raw: String) -> Bool
    {
        if let Value = Double(Raw)
        {
            if Value >= -180.0 && Value <= 180.0
            {
                return true
            }
        }
        return false
    }
    
    func ShowBadData(In Field: NSTextField)
    {
        let Backing = Field == LongitudeField ? LongitudeBackground : LatitudeBackground
        Field.stringValue = "0.0"
        Backing?.layer?.backgroundColor = NSColor(HexString: "#ffe0e0")!.cgColor
        let ErrorAnimation = CABasicAnimation(keyPath: "backgroundColor")
        ErrorAnimation.fromValue = NSColor(HexString: "#ffe0e0")!.cgColor
        ErrorAnimation.toValue = NSColor(HexString: "#e0e0e0")!.cgColor
        ErrorAnimation.duration = 2.0
        ErrorAnimation.isRemovedOnCompletion = false
        ErrorAnimation.fillMode = CAMediaTimingFillMode.forwards
        Backing?.layer?.add(ErrorAnimation, forKey: "backgroundColor")
    }
    
    func controlTextDidEndEditing(_ obj: Notification)
    {
        if let TextField = obj.object as? NSTextField
        {
            let Raw = TextField.stringValue
            switch TextField
            {
                case LocationNameField:
                    //Any text is OK.
                    break
                    
                case LatitudeField:
                    if LatitudeIsOK(Raw)
                    {
                        return
                    }
                    ShowBadData(In: TextField)
                    
                case LongitudeField:
                    if LongitudeIsOK(Raw)
                    {
                        return
                    }
                    ShowBadData(In: TextField)
                    
                default:
                    return
            }
        }
    }
    
    func SaveData()
    {
        if IsForHomeLocation
        {
            Settings.SetString(.UserHomeName, LocationNameField.stringValue)
            let Lat = Double(LatitudeField.stringValue)
            Settings.SetDoubleNil(.UserHomeLatitude, Lat)
            let Lon = Double(LongitudeField.stringValue)
            Settings.SetDoubleNil(.UserHomeLongitude, Lon)
        }
        else
        {
            Settings.SetString(.DailyLocationName, LocationNameField.stringValue)
            let Lat = Double(LatitudeField.stringValue)
            Settings.SetDoubleNil(.DailyLocationLatitude, Lat)
            let Lon = Double(LongitudeField.stringValue)
            Settings.SetDoubleNil(.DailyLocationLongitude, Lon)
        }
    }
    
    @IBAction func HandleOKButton(_ sender: Any)
    {
        SaveData()
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent!.endSheet(Window!, returnCode: .OK)
    }
    
    @IBAction func HandleCancelButton(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent!.endSheet(Window!, returnCode: .cancel)
    }
    
    @IBOutlet weak var LongitudeBackground: NSView!
    @IBOutlet weak var LatitudeBackground: NSView!
    @IBOutlet weak var LongitudeField: NSTextField!
    @IBOutlet weak var LatitudeField: NSTextField!
    @IBOutlet weak var LocationNameField: NSTextField!
    @IBOutlet weak var ExplanatoryText: NSTextField!
}
