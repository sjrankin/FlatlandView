//
//  UserLocationEditorController.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/1/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class UserLocationEditorController: NSViewController, NSTextFieldDelegate
{
    public weak var Delegate: LocationEditingProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        LatitudeTextBox.delegate = self
        LongitudeTextBox.delegate = self
    }
    
    override func viewDidLayout()
    {
        if Delegate == nil
        {
            fatalError("Delegate is nil in UserLocationEditorController")
        }
        if (Delegate?.AddNewLocation())!
        {
            NameTextBox.stringValue = ""
            LatitudeTextBox.stringValue = ""
            LongitudeTextBox.stringValue = ""
            POIColorWell.color = NSColor.systemYellow
        }
        else
        {
            let (Name, Latitude, Longitude, Color) = (Delegate?.GetLocationToEdit())!
            NameTextBox.stringValue = Name
            LatitudeTextBox.stringValue = "\(Latitude.RoundedTo(4))"
            LongitudeTextBox.stringValue = "\(Longitude.RoundedTo(4))"
            POIColorWell.color = Color
        }
    }
    
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        var ValidData = true
        let Color = POIColorWell.color
        let PlaceName = NameTextBox.stringValue
        if PlaceName.isEmpty
        {
            ValidData = false
        }
        let Lat = LatitudeTextBox.stringValue
        let Lon = LongitudeTextBox.stringValue
        var FinalLonVal: Double = 0.0
        var FinalLatVal: Double = 0.0
        if let LatVal = Double(Lat)
        {
            FinalLatVal = LatVal
            if let LonVal = Double(Lon)
            {
                FinalLonVal = LonVal
            }
            else
            {
                ValidData = false
            }
        }
        else
        {
            ValidData = false
        }
        
        Delegate?.SetEditedLocation(Name: PlaceName, Latitude: FinalLatVal, Longitude: FinalLonVal, Color: Color, IsValid: ValidData)
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent!.endSheet(Window!, returnCode: .OK)
    }
    
    func controlTextDidEndEditing(_ obj: Notification)
    {
        if let TextField = obj.object as? NSTextField
        {
            switch TextField
            {
                case LongitudeTextBox:
                    if !IsValidLongitude(TextField.stringValue)
                    {
                        TextField.stringValue = ""
                }
                
                case LatitudeTextBox:
                    if !IsValidLatitude(TextField.stringValue)
                    {
                        TextField.stringValue = ""
                }
                
                default:
                    return
            }
        }
    }
    
    func IsValidLongitude(_ Raw: String) -> Bool
    {
        if let RawValue = Double(Raw)
        {
            if RawValue < -180.0 || RawValue > 180.0
            {
                return false
            }
            return true
        }
        else
        {
            return false
        }
    }
    
    func IsValidLatitude(_ Raw: String) -> Bool
    {
        if let RawValue = Double(Raw)
        {
            if RawValue < -90.0 || RawValue > 90.0
            {
                return false
            }
            return true
        }
        else
        {
            return false
        }
    }
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        Delegate?.CancelEditing()
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent!.endSheet(Window!, returnCode: .cancel)
    }
    
    @IBAction func HandlePOIColorWellChanged(_ sender: Any)
    {
        //Placeholder.
    }
    
    @IBOutlet weak var POIColorWell: NSColorWell!
    @IBOutlet weak var LongitudeTextBox: NSTextField!
    @IBOutlet weak var LatitudeTextBox: NSTextField!
    @IBOutlet weak var NameTextBox: NSTextField!
}
