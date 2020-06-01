//
//  MainSettings.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/1/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class MainSettings: NSViewController, NSTableViewDataSource, NSTableViewDelegate,
    NSTextFieldDelegate, LocationEditingProtocol
{
    public weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InitializeUI()
    }
    
    func InitializeUI()
    {
        Initialize2DMap()
        InitializeUserLocationUI()
        InitializeOtherLocationUI()
        InitializeCitySettingsUI()
    }
    
    // MARK: - 2D Map settings.
    
    func Initialize2DMap()
    {
        Show2DNight.state = Settings.GetBool(.ShowNight) ? .on : .off
        Show2DPolarCircles.state = Settings.GetBool(.Show2DPolarCircles) ? .on : .off
        Show2DPrimeMeridians.state = Settings.GetBool(.Show2DPrimeMeridians) ? .on : .off
        Show2DNoonMeridians.state = Settings.GetBool(.Show2DNoonMeridians) ? .on : .off
        Show2DEquator.state = Settings.GetBool(.Show2DEquator) ? .on : .off
        Show2DTropics.state = Settings.GetBool(.Show2DTropics) ? .on : .off
    }
    
    @IBAction func HandleShow2DNightChanged(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            Settings.SetBool(.ShowNight, Button.state == .on ? true : false)
        }
    }
    
    @IBAction func Handle2DGridLinesChanged(_ sender: Any)
    {
        if let Check = sender as? NSButton
        {
            let IsChecked = Check.state == .on ? true: false
            switch Check
            {
                case Show2DEquator:
                    Settings.SetBool(.Show2DEquator, IsChecked)
                
                case Show2DTropics:
                    Settings.SetBool(.Show2DTropics, IsChecked)
                
                case Show2DNoonMeridians:
                    Settings.SetBool(.Show2DNoonMeridians, IsChecked)
                
                case Show2DPrimeMeridians:
                    Settings.SetBool(.Show2DPrimeMeridians, IsChecked)
                
                case Show2DPolarCircles:
                    Settings.SetBool(.Show2DPolarCircles, IsChecked)
                
                default:
                return
            }
            MainDelegate?.Refresh("MainSettings.Handle2DGridLinesChanged")
        }
    }
    
    @IBOutlet weak var Show2DNoonMeridians: NSButton!
    @IBOutlet weak var Show2DPrimeMeridians: NSButton!
    @IBOutlet weak var Show2DPolarCircles: NSButton!
    @IBOutlet weak var Show2DTropics: NSButton!
    @IBOutlet weak var Show2DEquator: NSButton!
    @IBOutlet weak var Show2DNight: NSButton!
    
    // MARK: - 3D Map settings.
    
    // MARK: - Locations settings.
    
    // MARK: - City settings.
    
    func InitializeCitySettingsUI()
    {
        
    }
    
    @IBAction func ShowCitiesChanged(_ sender: Any)
    {
    }
    
    @IBAction func HandleCityShapeChanged(_ sender: Any)
    {
    }
    
    @IBAction func HandlePopulationTypeChanged(_ sender: Any)
    {
    }
    
    @IBAction func HandleCityColorsPressed(_ sender: Any)
    {
    }
    
    @IBAction func HandleShowWorldCitiesChanged(_ sender: Any)
    {
    }
    
    @IBAction func HandleShowAfricanCitiesChanged(_ sender: Any)
    {
    }
    
    @IBAction func HandleShowAsianCitiesChanged(_ sender: Any)
    {
    }
    
    @IBAction func HandleShowEuropeanCitiesChanged(_ sender: Any)
    {
    }
    
    @IBAction func HandleShowNorthAmericanCitiesChanged(_ sender: Any)
    {
    }
    
    @IBAction func HandleShowSouthAmericanCitiesChanged(_ sender: Any)
    {
    }
    
    @IBAction func HandleShowCapitalCitiesChanged(_ sender: Any)
    {
    }
    
    @IBOutlet weak var ShowCapitalCitiesSwitch: NSSwitch!
    @IBOutlet weak var ShowSouthAmericanCitiesSwitch: NSSwitch!
    @IBOutlet weak var ShowNorthAmericanCitiesSwitch: NSSwitch!
    @IBOutlet weak var ShowEuropeanCitiesSwitch: NSSwitch!
    @IBOutlet weak var ShowAsianCitiesSwitch: NSSwitch!
    @IBOutlet weak var ShowAfricanCitiesSwitch: NSSwitch!
    @IBOutlet weak var ShowWorldCitiesSwitch: NSSwitch!
    @IBOutlet weak var PopulationTypeCombo: NSComboBox!
    @IBOutlet weak var CityShapeCombo: NSComboBox!
    @IBOutlet weak var ShowCitiesCheck: NSButton!
    
    // MARK: - Your location settings.
    
    func InitializeUserLocationUI()
    {
        UserLocationLatitudeBox.delegate = self
        UserLocationLongitudeBox.delegate = self
    }
    
    @IBAction func HandleEditUserLocation(_ sender: Any)
    {
    }
    
    @IBAction func HandleAddUserLocation(_ sender: Any)
    {
    }
    
    @IBAction func HandleClearUserLocations(_ sender: Any)
    {
    }
    
    @IBAction func HandleShowUserLocationsCheckChanged(_ sender: Any)
    {
    }
    
    @IBAction func HandleClearHomeLocation(_ sender: Any)
    {
    }
    
    @IBAction func HandleUserTimeZoneOffsetChanged(_ sender: Any)
    {
    }
    
    @IBAction func HandleHomeLocationShapeChanged(_ sender: Any)
    {
    }
    
    @IBOutlet weak var HomeLocationShapeSegment: NSSegmentedControl!
    @IBOutlet weak var UserTimeZoneOffsetCombo: NSComboBox!
    @IBOutlet weak var UserLocationTable: NSTableView!
    @IBOutlet weak var UserLocationLongitudeBox: NSTextField!
    @IBOutlet weak var UserLocationLatitudeBox: NSTextField!
    @IBOutlet weak var ShowUserLocationsCheck: NSButton!
    
    // MARK: - Other location settings.
    
    func InitializeOtherLocationUI()
    {
        
    }
    
    @IBAction func HandleShowHeritageSiteChanged(_ sender: Any)
    {
    }
    
    @IBAction func HandleHeritageSiteTypeChanged(_ sender: Any)
    {
    }
    
    @IBOutlet weak var ShowHeritageSiteCheck: NSButton!
    @IBOutlet weak var HeritageSiteSegment: NSSegmentedControl!
    
    // MARK: - Other settings.
    
    // MARK: - Common code.
    
    func controlTextDidEndEditing(_ obj: Notification)
    {
        if let TextField = obj.object as? NSTextField
        {
            switch TextField
            {
                default:
                return
            }
        }
    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        MainDelegate?.Refresh("MainSettings")
        self.view.window?.close()
    }
    
    // MARK: - Location delegate protocol functions.
    
    func AddNewLocation() -> Bool
    {
        return false
    }
    
    func GetLocationToEdit() -> (Name: String, Latitude: Double, Longitude: Double, Color: NSColor)
    {
        return ("", 0.0, 0.0, NSColor.black)
    }
    
    func SetEditedLocation(Name: String, Latitude: Double, Longitude: Double, Color: NSColor, IsValid: Bool)
    {
    }
    
    func CancelEditing()
    {
    }
}
