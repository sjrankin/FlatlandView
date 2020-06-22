//
//  UserLocation.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class UserLocationWindow: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate,
    LocationEditingProtocol, AutoLocationProtocol, ConfirmProtocol
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InitializeUserLocationUI()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    var UserLocations = [(ID: UUID, Coordinates: GeoPoint2, Name: String, Color: NSColor)]()
    var AddNewUserLocation = false
    var CurrentUserLocationIndex = -1
    var ConfirmMessage = ""
    
    func InitializeUserLocationUI()
    {
        UserLocations = Settings.GetLocations()
        UserLocationTable.reloadData()
        UserLocationLatitudeBox.delegate = self
        UserLocationLongitudeBox.delegate = self
        ShowUserLocationsSwitch.state = Settings.GetBool(.ShowUserLocations) ? .on : .off
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
                    }
                }
            }
            else
            {
                fatalError("Error getting contentViewController")
            }
        }
    }
    
    @IBAction func HandleShowUserLocationsSwitchChanged(_ sender: Any)
    {
        if let Button = sender as? NSSwitch
        {
            Settings.SetBool(.ShowUserLocations, Button.state == .on ? true : false)
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
                }
            }
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "NameColumn"
            CellContents = UserLocations[row].Name
        }
        if tableColumn == tableView.tableColumns[1]
        {
            CellIdentifier = "LocationColumn"
            let Loc = "\(UserLocations[row].Coordinates.Latitude.RoundedTo(3)), \(UserLocations[row].Coordinates.Longitude.RoundedTo(3))"
            CellContents = Loc
        }
        if tableColumn == tableView.tableColumns[2]
        {
            let Color = UserLocations[row].Color
            let Swatch = NSView(frame: NSRect(x: 5, y: 2, width: 40, height: 20))
            Swatch.wantsLayer = true
            Swatch.layer?.backgroundColor = Color.cgColor
            Swatch.layer?.borderColor = NSColor.black.cgColor
            Swatch.layer?.borderWidth = 0.5
            Swatch.layer?.cornerRadius = 5.0
            return Swatch
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return UserLocations.count
    }
    
    @IBAction func HandleTableClicked(_ sender: Any)
    {
        if let Table = sender as? NSTableView
        {
            CurrentUserLocationIndex = Table.selectedRow
        }
    }
    
    func ValidateText(_ Raw: String, IsLongitude: Bool, GoodValue: inout Double) -> Bool
    {
        if let RawValue = Double(Raw)
        {
            if IsLongitude
            {
                if RawValue < -180.0 || RawValue > 180.0
                {
                    return false
                }
                GoodValue = RawValue
                return true
            }
            else
            {
                if RawValue < -90.0 || RawValue > 90.0
                {
                    return false
                }
                GoodValue = RawValue
                return true
            }
        }
        GoodValue = 0.0
        return false
    }
    
    func controlTextDidEndEditing(_ obj: Notification)
    {
        if let TextField = obj.object as? NSTextField
        {
            let TextValue = TextField.stringValue
            var GoodValue: Double = 0.0
            switch TextField
            {
                case UserLocationLongitudeBox:
                    if ValidateText(TextValue, IsLongitude: true, GoodValue: &GoodValue)
                    {
                        Settings.SetDoubleNil(.LocalLongitude, GoodValue)
                    }
                    else
                    {
                        TextField.stringValue = ""
                }
                
                case UserLocationLatitudeBox:
                    if ValidateText(TextValue, IsLongitude: false, GoodValue: &GoodValue)
                    {
                        Settings.SetDoubleNil(.LocalLatitude, GoodValue)
                    }
                    else
                    {
                        TextField.stringValue = ""
                }
                
                default:
                    return
            }
        }
    }
    
    func AddNewLocation() -> Bool
    {
        return AddNewUserLocation
    }
    
    func GetLocationToEdit() -> (Name: String, Latitude: Double, Longitude: Double, Color: NSColor)
    {
        if CurrentUserLocationIndex < 0
        {
            return ("", 0.0, 0.0, NSColor.black)
        }
        return (UserLocations[CurrentUserLocationIndex].Name,
                UserLocations[CurrentUserLocationIndex].Coordinates.Latitude,
                UserLocations[CurrentUserLocationIndex].Coordinates.Longitude,
                UserLocations[CurrentUserLocationIndex].Color)
    }
    
    func SetEditedLocation(Name: String, Latitude: Double, Longitude: Double, Color: NSColor, IsValid: Bool)
    {
        if IsValid
        {
            if AddNewUserLocation
            {
                UserLocations.append((UUID(), GeoPoint2(Latitude, Longitude), Name, Color))
            }
            else
            {
                if CurrentUserLocationIndex >= 0
                {
                    UserLocations[CurrentUserLocationIndex].Name = Name
                    UserLocations[CurrentUserLocationIndex].Coordinates.Latitude = Latitude
                    UserLocations[CurrentUserLocationIndex].Coordinates.Longitude = Longitude
                    UserLocations[CurrentUserLocationIndex].Color = Color
                }
            }
            Settings.SetLocations(UserLocations)
        }
    }
    
    func CancelEditing()
    {
    }
    
    func GetConfirmationMessage(ID: UUID) -> String
    {
        return ConfirmMessage
    }
    
    func GetButtonTitle(_ ForButton: ConfirmationButtons, ID: UUID) -> String?
    {
        switch ForButton
        {
            case .LeftButton:
                return "OK"
            
            case .RightButton:
                return "No"
        }
    }
    
    func GetInstanceID() -> UUID
    {
        return UUID()
    }
    
    func HandleButtonPressed(PressedButton: ConfirmationButtons, ID: UUID)
    {
    }
    
    @IBOutlet weak var ShowUserLocationsSwitch: NSSwitch!
    @IBOutlet weak var UserTimeZoneOffsetCombo: NSComboBox!
    @IBOutlet weak var HomeShapeCombo: NSComboBox!
    @IBOutlet weak var UserLocationLongitudeBox: NSTextField!
    @IBOutlet weak var UserLocationLatitudeBox: NSTextField!
    @IBOutlet weak var UserLocationTable: NSTableView!
}
