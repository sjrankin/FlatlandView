//
//  UserLocationEditorController.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/1/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class UserLocationEditorController: NSViewController, NSTableViewDelegate, NSTableViewDataSource,
    NSTextFieldDelegate
{
    public weak var Delegate: LocationEditingProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        LatitudeTextBox.delegate = self
        ColorSwatchTable.reloadData()
        if (Delegate?.AddNewLocation())!
        {
            NameTextBox.stringValue = ""
            LatitudeTextBox.stringValue = ""
            LongitudeTextBox.stringValue = ""
            let ISet = IndexSet(integer: 0)
            ColorSwatchTable.selectRowIndexes(ISet, byExtendingSelection: false)
        }
        else
        {
            let (Name, Latitude, Longitude, Color) = (Delegate?.GetLocationToEdit())!
            NameTextBox.stringValue = Name
            LatitudeTextBox.stringValue = "\(Latitude.RoundedTo(4))"
            LongitudeTextBox.stringValue = "\(Longitude.RoundedTo(4))"
            if let Index = IndexOf(Color)
            {
                let ISet = IndexSet(integer: Index)
                ColorSwatchTable.selectRowIndexes(ISet, byExtendingSelection: false)
            }
            else
            {
                let ISet = IndexSet(integer: 0)
                ColorSwatchTable.selectRowIndexes(ISet, byExtendingSelection: false)
            }
        }
    }
    
    func IndexOf(_ Color: NSColor) -> Int?
    {
        var Index = 0
        for SomeColor in ColorList.Colors
        {
            if SomeColor.Color == Color
            {
                return Index
            }
            Index = Index + 1
        }
        return nil
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return ColorList.Colors.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellIdentifier = ""
        
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "ColorNameColumn"
            let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
            Cell?.textField?.stringValue = ColorList.Colors[row].Name
            return Cell
        }
        if tableColumn == tableView.tableColumns[1]
        {
            CellIdentifier = "ColorSwatchColumn"
            let Color = ColorList.Colors[row].Color
            let Swatch = NSView(frame: NSRect(x: 5, y: 2, width: 40, height: 20))
            Swatch.wantsLayer = true
            Swatch.layer?.backgroundColor = Color.cgColor
            Swatch.layer?.borderColor = NSColor.black.cgColor
            Swatch.layer?.borderWidth = 0.5
            Swatch.layer?.cornerRadius = 5.0
            return Swatch
        }
        return nil
    }
    
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        var ValidData = true
        let ColorIndex = ColorSwatchTable.selectedRow
        let Color = ColorList.Colors[ColorIndex].Color
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
    
    @IBOutlet weak var ColorSwatchTable: NSTableView!
    @IBOutlet weak var LongitudeTextBox: NSTextField!
    @IBOutlet weak var LatitudeTextBox: NSTextField!
    @IBOutlet weak var NameTextBox: NSTextField!
}
