//
//  GetLocationCode.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import CoreLocation

class GetLocationCode: NSViewController, NSTextFieldDelegate, CLLocationManagerDelegate
{
    public weak var LocationDelegate: AutoLocationProtocol? = nil
    
    let LocationMan = CLLocationManager()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        MainLabel.stringValue = "Flatland will attempt to find your current location. Accuracy will vary depending on current internet routing."
        if let LocalLon = Settings.GetDoubleNil(.UserHomeLongitude)
        {
            LongitudeBox.stringValue = "\(LocalLon)"
        }
        else
        {
            LongitudeBox.stringValue = ""
        }
        if let LocalLat = Settings.GetDoubleNil(.UserHomeLatitude)
        {
            LatitudeBox.stringValue = "\(LocalLat)"
        }
        else
        {
            LatitudeBox.stringValue = ""
        }
        LocationMan.startUpdatingLocation()
    }
    
    func controlTextDidEndEditing(_ obj: Notification)
    {
        if let TextField = obj.object as? NSTextField
        {
            switch TextField
            {
                case LongitudeBox:
                    if !IsValidLongitude(TextField.stringValue)
                    {
                        TextField.stringValue = ""
                }
                
                case LatitudeBox:
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
    
    @IBAction func HandlediscardButton(_ sender: Any)
    {
        LocationMan.stopUpdatingLocation()
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent!.endSheet(Window!, returnCode: .cancel)
    }
    
    @IBAction func HandleUseButton(_ sender: Any)
    {
                LocationMan.stopUpdatingLocation()
        let Window = self.view.window
        let Parent = Window?.sheetParent
        var ValidData = true
        let RawLat = LatitudeBox.stringValue
        if !RawLat.isEmpty
        {
            if let LatVal = Double(RawLat)
            {
                Settings.SetDoubleNil(.UserHomeLatitude, LatVal)
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
        let RawLon = LongitudeBox.stringValue
        if !RawLon.isEmpty
        {
            if let LonVal = Double(RawLon)
            {
                Settings.SetDoubleNil(.UserHomeLongitude, LonVal)
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
        if ValidData
        {
            LocationDelegate?.HaveNewLocation()
        }
        Parent!.endSheet(Window!, returnCode: ValidData ? .OK : .cancel)
    }
    
    func DoGeoLookup(_ FromLocation: CLLocation) -> String
    {
        let Geocoder = CLGeocoder()
        Geocoder.reverseGeocodeLocation(FromLocation)
        {
            PlaceMarks, Error in
            if PlaceMarks == nil
            {
                self.MainLabel.stringValue = "Error getting address of coordinates."
                return
            }
            let Result = Utility.ConstructAddress(From: PlaceMarks![0])
            self.MainLabel.stringValue = Result
            self.LastAddress = Result
        }
        return LastAddress
    }
    
    var LastAddress = ""
    
    @IBAction func HandleGeoLookup(_ sender: Any)
    {
        let RawLat = LatitudeBox.stringValue
        if RawLat.isEmpty
        {
            return
        }
        let RawLon = LongitudeBox.stringValue
        if RawLon.isEmpty
        {
            return
        }
        if let LatVal = Double(RawLat)
        {
            if let LonVal = Double(RawLon)
            {
                let Loc = CLLocation(latitude: LatVal, longitude: LonVal)
                let _ = DoGeoLookup(Loc)
            }
        }
    }
    
    func PopulateFromLocation(_ Where: CLLocation?)
    {
        if let Final = Where
        {
            let Address = DoGeoLookup(Final)
            MainLabel.stringValue = Address
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus)
    {
        switch status
        {
            case .restricted:
                MainLabel.stringValue = "Your system has restricted access to the location manager. Unable to complete."
            
            case .denied:
                MainLabel.stringValue = "Your system denied access to the location manager. Unable to complete."
            
            case .authorized:
                if let CurrentLocation = LocationMan.location
                {
                    PopulateFromLocation(CurrentLocation)
            }
            
            case .notDetermined:
                MainLabel.stringValue = "Indeterminate access returned. Unable to complete."
            
            default:
                MainLabel.stringValue = "Unknown location manager state: \(status)"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        MainLabel.stringValue = "Location manager failed with error \(error.localizedDescription)."
    }
    
    @IBOutlet weak var UseButton: NSButton!
    @IBOutlet weak var LongitudeBox: NSTextField!
    @IBOutlet weak var LatitudeBox: NSTextField!
    @IBOutlet weak var MainLabel: NSTextField!
}
