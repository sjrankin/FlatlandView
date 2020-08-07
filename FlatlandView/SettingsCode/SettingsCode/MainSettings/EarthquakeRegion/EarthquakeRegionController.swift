//
//  EarthquakeRegionController.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/1/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class EarthquakeRegionController: NSViewController, NSTableViewDelegate, NSTableViewDataSource,
                                  NSTextFieldDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        RegionNameLabel.textColor = NSColor.black
        Regions = Settings.GetEarthquakeRegions()
        if Regions.count == 0
        {
            Regions.append(EarthquakeRegion(FallBack: true))
            Settings.SetEarthquakeRegions(Regions)
        }
        RegionTable.reloadData()
        CurrentRegionIndex = 0
        MinMagField.stringValue = ""
        MaxMagField.stringValue = ""
        AgeCombo.removeAllItems()
        for Days in 1 ... 30
        {
            AgeCombo.addItem(withObjectValue: "\(Days)")
        }
        EnabledSwitch.state = .on
    }
    
    var IsDirty = false
    var CurrentRegionIndex: Int = 0
    var Regions = [EarthquakeRegion]()
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        if IsDirty
        {
        GetLastMinuteChanges()
        Settings.SetEarthquakeRegions(Regions)
        }
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent?.endSheet(Window!, returnCode: .OK)
    }
    
    @IBAction func HandleTableAction(_ sender: Any)
    {
        Populate(Row: RegionTable.selectedRow)
    }
    
    func Populate(Row: Int)
    {
        CurrentRegionIndex = Row
        RegionNameBox.stringValue = Regions[Row].RegionName
        RegionBorderColorWell.color = Regions[Row].RegionColor
        ULLatitudeField.stringValue = "\(Regions[Row].UpperLeft.Latitude.RoundedTo(3))"
        ULLongitudeField.stringValue = "\(Regions[Row].UpperLeft.Longitude.RoundedTo(3))"
        LRLatitudeField.stringValue = "\(Regions[Row].LowerRight.Latitude.RoundedTo(3))"
        LRLongitudeField.stringValue = "\(Regions[Row].LowerRight.Longitude.RoundedTo(3))"
        MinMagField.stringValue = "\(Regions[Row].MinimumMagnitude.RoundedTo(3))"
        MaxMagField.stringValue = "\(Regions[Row].MaximumMagnitude.RoundedTo(3))"
        AgeCombo.selectItem(at: Regions[Row].Age - 1)
        EnabledSwitch.state = Regions[Row].IsEnabled ? .on : .off
        if Regions[Row].IsFallback
        {
            RegionNameLabel.textColor = NSColor.systemBlue
            RegionNameBox.isEnabled = false
            RegionBorderColorWell.isEnabled = false
            ULLatitudeField.isEnabled = false
            ULLongitudeField.isEnabled = false
            LRLatitudeField.isEnabled = false
            LRLongitudeField.isEnabled = false
            EnabledSwitch.isEnabled = false
        }
        else
        {
            RegionNameLabel.textColor = NSColor.black
            RegionNameBox.isEnabled = true
            RegionBorderColorWell.isEnabled = true
            ULLatitudeField.isEnabled = true
            ULLongitudeField.isEnabled = true
            LRLatitudeField.isEnabled = true
            LRLongitudeField.isEnabled = true
            EnabledSwitch.isEnabled = true
        }
    }
    
    @IBAction func HandleAddButton(_ sender: Any)
    {
        let NewRegion = EarthquakeRegion()
        NewRegion.RegionName = "New Region"
        Regions.append(NewRegion)
        RegionTable.reloadData()
        let ISet = IndexSet(integer: CurrentRegionIndex)
        RegionTable.selectRowIndexes(ISet, byExtendingSelection: false)
        IsDirty = true
    }
    
    @IBAction func HandleDeleteButton(_ sender: Any)
    {
        let Selected = RegionTable.selectedRow
        if Selected < 0
        {
            return
        }
    }

    func ReloadTable()
    {
        RegionTable.reloadData()
        let ISet = IndexSet(integer: CurrentRegionIndex)
        RegionTable.selectRowIndexes(ISet, byExtendingSelection: false)
    }
    
    @IBAction func HandleAgeComboChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            let Index = Combo.indexOfSelectedItem
            Regions[CurrentRegionIndex].Age = Index + 1
            IsDirty = true
            ReloadTable()
        }
    }
    
    @IBAction func HandleRegionBorderWellChanged(_ sender: Any)
    {
        if let Well = sender as? NSColorWell
        {
            IsDirty = true
            Regions[CurrentRegionIndex].RegionColor = Well.color
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return Regions.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "RegionNameColumn"
            CellContents = Regions[row].RegionName
        }
        if tableColumn == tableView.tableColumns[1]
        {
            CellIdentifier = "MinMagColumn"
            CellContents = "\(Regions[row].MinimumMagnitude)"
        }
        if tableColumn == tableView.tableColumns[2]
        {
            CellIdentifier = "AgeColumn"
            CellContents = "\(Regions[row].Age)"
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        if Regions[row].IsEnabled
        {
            Cell?.textField?.textColor = NSColor.black
        }
        else
        {
            Cell?.textField?.textColor = NSColor.gray
        }
        return Cell
    }
    
    func ValidateLatitude(_ Value: String, Default: Double = 0.0) -> Double
    {
        if let DValue = Double(Value)
        {
            if DValue < -90.0
            {
                return Default
            }
            if DValue > 90.0
            {
                return Default
            }
            return DValue
        }
        return Default
    }
    
    func ValidateLongitude(_ Value: String, Default: Double = 0.0) -> Double
    {
        if let DValue = Double(Value)
        {
            if DValue < -180.0
            {
                return Default
            }
            if DValue > 180.0
            {
                return Default
            }
            return DValue
        }
        return Default
    }
    
    func ValidateMagnitudes(_ Value: String, Default: Double = 5.0) -> Double
    {
        if let Actual = Double(Value)
        {
            if Actual < 0.0 || Actual > 10.0
            {
                return Default
            }
            return Actual
        }
        return Default
    }
    
    func UpdateFromTextField(_ Field: NSTextField)
    {
        switch Field
        {
            case LRLatitudeField:
                IsDirty = true
                Regions[CurrentRegionIndex].LowerRight.Latitude = ValidateLatitude(Field.stringValue)
                
            case LRLongitudeField:
                IsDirty = true
                Regions[CurrentRegionIndex].LowerRight.Longitude = ValidateLongitude(Field.stringValue)
                
            case ULLatitudeField:
                IsDirty = true
                Regions[CurrentRegionIndex].UpperLeft.Latitude = ValidateLatitude(Field.stringValue)
                
            case ULLongitudeField:
                IsDirty = true
                Regions[CurrentRegionIndex].UpperLeft.Longitude = ValidateLongitude(Field.stringValue)
                
            case MinMagField:
                IsDirty = true
                let NewMin = ValidateMagnitudes(Field.stringValue)
                Regions[CurrentRegionIndex].MinimumMagnitude = NewMin
                let OldMax = ValidateMagnitudes(MaxMagField.stringValue)
                if NewMin > OldMax
                {
                    MaxMagField.stringValue = "\(NewMin)"
                    Regions[CurrentRegionIndex].MaximumMagnitude = NewMin
                }
                
            case MaxMagField:
                IsDirty = true
                let NewMax = ValidateMagnitudes(Field.stringValue)
                Regions[CurrentRegionIndex].MaximumMagnitude = NewMax
                let OldMin = ValidateMagnitudes(MinMagField.stringValue)
                if NewMax < OldMin
                {
                    MinMagField.stringValue = "\(NewMax)"
                    Regions[CurrentRegionIndex].MinimumMagnitude = NewMax
                }
                
            case RegionNameBox:
                IsDirty = true
                Regions[CurrentRegionIndex].RegionName = Field.stringValue
                ReloadTable()
                
            default:
                return
        }
    }
    
    func controlTextDidEndEditing(_ obj: Notification)
    {
        if let TextField = obj.object as? NSTextField
        {
            UpdateFromTextField(TextField)
        }
    }
    
    /// Called when the dialog is closing. Get any last minute changes that may not be reflected in events
    /// that didn't fire for whatever reason.
    func GetLastMinuteChanges()
    {
        UpdateFromTextField(LRLatitudeField)
        UpdateFromTextField(LRLongitudeField)
        UpdateFromTextField(ULLatitudeField)
        UpdateFromTextField(ULLongitudeField)
        UpdateFromTextField(RegionNameBox)
    }
    
    @IBAction func HandleEnabledSwitchChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            IsDirty = true
            Regions[CurrentRegionIndex].IsEnabled = Switch.state == .on ? true : false
            ReloadTable()
        }
    }
    
    @IBAction func HandleResetButton(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "Settings", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "ResetConfirmWindow") as? ResetConfirmWindow
        {
            let Window = WindowController.window
            self.view.window?.beginSheet(Window!)
            {
                Result in
                if Result == .OK
                {
                    self.Regions.removeAll()
                    self.Regions.append(EarthquakeRegion(FallBack: true))
                    Settings.SetEarthquakeRegions(self.Regions)
                    self.ReloadTable()
                    self.Populate(Row: 0)
                    self.IsDirty = true
                }
            }
        }
    }
    
    @IBOutlet weak var EnabledSwitch: NSSwitch!
    @IBOutlet weak var RegionNameLabel: NSTextField!
    @IBOutlet weak var DeleteButton: NSButton!
    @IBOutlet weak var LRLatitudeField: NSTextField!
    @IBOutlet weak var LRLongitudeField: NSTextField!
    @IBOutlet weak var ULLongitudeField: NSTextField!
    @IBOutlet weak var ULLatitudeField: NSTextField!
    @IBOutlet weak var RegionBorderColorWell: NSColorWell!
    @IBOutlet weak var AgeCombo: NSComboBox!
    @IBOutlet weak var MaxMagField: NSTextField!
    @IBOutlet weak var MinMagField: NSTextField!
    @IBOutlet weak var RegionNameBox: NSTextField!
    @IBOutlet weak var RegionTable: NSTableView!
}
