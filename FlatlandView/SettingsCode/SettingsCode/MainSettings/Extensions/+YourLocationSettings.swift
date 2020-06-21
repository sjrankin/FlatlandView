//
//  +YourLocationSettings.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainSettings
{
    func InitializeUserLocationUI()
    {
        UserLocations = Settings.GetLocations()
        UserLocationTable.reloadData()
        UserLocationLatitudeBox.delegate = self
        UserLocationLongitudeBox.delegate = self
        ShowUserLocationsCheck.state = Settings.GetBool(.ShowUserLocations) ? .on : .off
        UserTimeZoneOffsetCombo.removeAllItems()
        for Offset in -12 ... 14
        {
            var OffsetValue = "\(Offset)"
            if Offset > 0
            {
                OffsetValue = "+" + OffsetValue
            }
            UserTimeZoneOffsetCombo.addItem(withObjectValue: OffsetValue)
        }
        if Settings.HaveLocalLocation()
        {
            let UserLat = Settings.GetDoubleNil(.LocalLatitude, 0.0)!
            let UserLon = Settings.GetDoubleNil(.LocalLongitude, 0.0)!
            UserLocationLatitudeBox.stringValue = "\(UserLat.RoundedTo(4))"
            UserLocationLongitudeBox.stringValue = "\(UserLon.RoundedTo(4))"
            let ZoneOffset = Int(Settings.GetDoubleNil(.LocalTimeZoneOffset, 0.0)!)
            var ZoneOffsetString = "\(ZoneOffset)"
            if ZoneOffset > 0
            {
                ZoneOffsetString = "+" + ZoneOffsetString
            }
            UserTimeZoneOffsetCombo.selectItem(withObjectValue: ZoneOffsetString)
        }
        else
        {
            UserLocationLongitudeBox.stringValue = ""
            UserLocationLatitudeBox.stringValue = ""
            UserTimeZoneOffsetCombo.selectItem(withObjectValue: nil)
        }
        HomeShapeCombo.removeAllItems()
        for SomeShape in HomeShapes.allCases
        {
            HomeShapeCombo.addItem(withObjectValue: SomeShape.rawValue)
        }
        let LocalShape = Settings.GetEnum(ForKey: .HomeShape, EnumType: HomeShapes.self, Default: .Hide)
        HomeShapeCombo.selectItem(withObjectValue: LocalShape.rawValue)
    }
    
    @IBAction func HandleDeleteCurrentUserLocation(_ sender: Any)
    {
        if CurrentUserLocationIndex < 0
        {
            return
        }
        UserLocations.remove(at: CurrentUserLocationIndex)
        UserLocationTable.reloadData()
        Settings.SetLocations(UserLocations)
        MainDelegate?.Refresh("MainSettings.HandleDeleteCurrentUserLocation")
    }
    
    @IBAction func HandleEditUserLocation(_ sender: Any)
    {
        if CurrentUserLocationIndex < 0
        {
            return
        }
        let Storyboard = NSStoryboard(name: "Settings", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "UserLocationEditorWindow") as? UserLocationEditorWindow
        {
            AddNewUserLocation = false
            let Window = WindowController.window
            if let Controller = Window?.contentViewController as? UserLocationEditorController
            {
                Controller.Delegate = self
                self.view.window?.beginSheet(Window!)
                {
                    Response in
                    if Response == .OK
                    {
                        self.UserLocationTable.reloadData()
                        self.MainDelegate?.Refresh("MainSettings.HandleEditUserLocation")
                    }
                }
            }
        }
    }
    
    @IBAction func HandleAddUserLocation(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "Settings", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "UserLocationEditorWindow") as? UserLocationEditorWindow
        {
            AddNewUserLocation = true
            let Window = WindowController.window
            if let Controller = Window?.contentViewController as? UserLocationEditorController
            {
                Controller.Delegate = self
                self.view.window?.beginSheet(Window!)
                {
                    Response in
                    if Response == .OK
                    {
                        self.UserLocationTable.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func HandleUseCurrentLocation(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "Settings", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "GetLocationWindow") as? GetLocationWindow
        {
            let Window = WindowController.window
            if let Controller = Window?.contentViewController as? GetLocationCode
            {
                Controller.LocationDelegate = self
                self.view.window?.beginSheet(Window!, completionHandler: nil)
            }
        }
    }
    
    func HaveNewLocation()
    {
        if let Lat = Settings.GetDoubleNil(.LocalLatitude)
        {
            UserLocationLatitudeBox.stringValue = "\(Lat)"
        }
        if let Lon = Settings.GetDoubleNil(.LocalLongitude)
        {
            UserLocationLongitudeBox.stringValue = "\(Lon)"
        }
    }
    
    @IBAction func HandleClearUserLocations(_ sender: Any)
    {
        ConfirmMessage = "Do you really want to delete all of your locations?"
        let Storyboard = NSStoryboard(name: "Settings", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "ConfirmDialogWindowCode") as? ConfirmDialogWindow
        {
            let Window = WindowController.window
            if let Controller = Window?.contentViewController as? ConfirmDialogCode
            {
                Controller.ConfirmDelegate = self
                self.view.window?.beginSheet(Window!)
                {
                    Response in
                    if Response == .OK
                    {
                        self.UserLocations.removeAll()
                        self.UserLocationTable.reloadData()
                        Settings.SetLocations(self.UserLocations)
                        self.MainDelegate?.Refresh("MainSettings.HandleClearUserLocations")
                    }
                }
            }
            else
            {
                fatalError("Error getting contentViewController")
            }
        }
    }
    
    @IBAction func HandleShowUserLocationsCheckChanged(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            Settings.SetBool(.ShowUserLocations, Button.state == .on ? true : false)
            MainDelegate?.Refresh("MainSettings.HandleShowUserLocationsCheckChanged")
        }
    }
    
    @IBAction func HandleClearHomeLocation(_ sender: Any)
    {
        UserLocationLongitudeBox.stringValue = ""
        UserLocationLatitudeBox.stringValue = ""
        UserTimeZoneOffsetCombo.selectItem(withObjectValue: nil)
        Settings.SetDoubleNil(.LocalLatitude, nil)
        Settings.SetDoubleNil(.LocalLongitude, nil)
        Settings.SetDoubleNil(.LocalTimeZoneOffset, nil)
        MainDelegate?.Refresh("MainSettings.HandleClearUserLocations")
    }
    
    @IBAction func HandleUserTimeZoneOffsetChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            if let Raw = Combo.objectValueOfSelectedItem as? String
            {
                if let ActualValue = Int(Raw)
                {
                    let DVal = Double(ActualValue)
                    Settings.SetDoubleNil(.LocalTimeZoneOffset, DVal)
                    MainDelegate?.Refresh("MainSettings.HandleUsertimeZoneOffsetChanged")
                }
            }
        }
    }
    
    @IBAction func HomeShapeChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            if let ItemValue = Combo.objectValueOfSelectedItem as? String
            {
                if let HomeShape = HomeShapes(rawValue: ItemValue)
                {
                    Settings.SetEnum(HomeShape, EnumType: HomeShapes.self, ForKey: .HomeShape)
                    MainDelegate?.Refresh("MainSettings.HomeShapeChanged")
                }
            }
        }
    }
}
