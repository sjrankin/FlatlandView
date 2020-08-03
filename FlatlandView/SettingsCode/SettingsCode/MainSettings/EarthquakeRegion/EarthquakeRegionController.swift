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
        
        Regions = Settings.GetEarthquakeRegions()
        if Regions.count == 0
        {
            Regions.append(EarthquakeRegion(FallBack: true))
            Settings.SetEarthquakeRegions(Regions)
        }
        RegionTable.reloadData()
        CurrentRegionIndex = 0
        
        MinMagCombo.removeAllItems()
        MinMagCombo.addItem(withObjectValue: "4")
        MinMagCombo.addItem(withObjectValue: "5")
        MinMagCombo.addItem(withObjectValue: "6")
        MinMagCombo.addItem(withObjectValue: "7")
        MinMagCombo.addItem(withObjectValue: "8")
        MinMagCombo.addItem(withObjectValue: "9")
        MinMagCombo.addItem(withObjectValue: "10")
        MaxMagCombo.removeAllItems()
        MaxMagCombo.addItem(withObjectValue: "4")
        MaxMagCombo.addItem(withObjectValue: "5")
        MaxMagCombo.addItem(withObjectValue: "6")
        MaxMagCombo.addItem(withObjectValue: "7")
        MaxMagCombo.addItem(withObjectValue: "8")
        MaxMagCombo.addItem(withObjectValue: "9")
        MaxMagCombo.addItem(withObjectValue: "10")
        AgeCombo.removeAllItems()
        for Days in 1 ... 30
        {
            AgeCombo.addItem(withObjectValue: "\(Days)")
        }
    }
    
    var CurrentRegionIndex: Int = 0
    var Regions = [EarthquakeRegion]()
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        GetLastMinuteChanges()
        Settings.SetEarthquakeRegions(Regions)
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
        RegionBorderColorWell.color = Regions[Row].BorderColor
        ULLatitudeField.stringValue = "\(Regions[Row].UpperLeft.Latitude.RoundedTo(3))"
        ULLongitudeField.stringValue = "\(Regions[Row].UpperLeft.Longitude.RoundedTo(3))"
        LRLatitudeField.stringValue = "\(Regions[Row].LowerRight.Latitude.RoundedTo(3))"
        LRLongitudeField.stringValue = "\(Regions[Row].LowerRight.Longitude.RoundedTo(3))"
        MinMagCombo.selectItem(at: Int(Regions[Row].MinimumMagnitude - 4))
        MaxMagCombo.selectItem(at: Int(Regions[Row].MaximumMagnitude - 4))
        AgeCombo.selectItem(at: Regions[Row].Age - 1)
        if let Index = WidthMap[Int(Regions[Row].BorderWidth)]
        {
            BorderWidthSegment.selectedSegment = Index
        }
        else
        {
            BorderWidthSegment.selectedSegment = 5
        }
    }
    
    let WidthMap = [0: 0, 1: 1, 2: 2, 4: 3, 8: 4, 16: 5, 21: 6]
    
    @IBAction func HandleAddButton(_ sender: Any)
    {
        let NewRegion = EarthquakeRegion()
        NewRegion.RegionName = "New Region"
        Regions.append(NewRegion)
        RegionTable.reloadData()
        let ISet = IndexSet(integer: CurrentRegionIndex)
        RegionTable.selectRowIndexes(ISet, byExtendingSelection: false)
    }
    
    @IBAction func HandleDeleteButton(_ sender: Any)
    {
        let Selected = RegionTable.selectedRow
        if Selected < 0
        {
            return
        }
    }
    
    @IBAction func HandleBorderWidthChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            let Index = Segment.selectedSegment
            for (Value, ValueIndex) in WidthMap
            {
                if ValueIndex == Index
                {
                    Regions[CurrentRegionIndex].BorderWidth = Double(Value)
                    return
                }
            }
        }
    }
    
    func ReloadTable()
    {
        RegionTable.reloadData()
        let ISet = IndexSet(integer: CurrentRegionIndex)
        RegionTable.selectRowIndexes(ISet, byExtendingSelection: false)
    }
    
    @IBAction func HandleMinMagnitudeChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            let Index = Combo.indexOfSelectedItem
            Regions[CurrentRegionIndex].MinimumMagnitude = Double(Index + 4)
            let MaxIndex = MaxMagCombo.indexOfSelectedItem
            if Index > MaxIndex
            {
                MaxMagCombo.selectItem(at: Index)
            }
            ReloadTable()
        }
    }
    
    @IBAction func HandleMaxMagnitudeChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            let Index = Combo.indexOfSelectedItem
            Regions[CurrentRegionIndex].MaximumMagnitude = Double(Index + 4)
            let MinIndex = MinMagCombo.indexOfSelectedItem
            if Index > MinIndex
            {
                MinMagCombo.selectItem(at: Index)
                ReloadTable()
            }
        }
    }
    
    @IBAction func HandleAgeComboChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            let Index = Combo.indexOfSelectedItem
            Regions[CurrentRegionIndex].Age = Index + 1
            ReloadTable()
        }
    }
    
    @IBAction func HandleRegionBorderWellChanged(_ sender: Any)
    {
        if let Well = sender as? NSColorWell
        {
            Regions[CurrentRegionIndex].BorderColor = Well.color
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
    
    func UpdateFromTextField(_ Field: NSTextField)
    {
        switch Field
        {
            case LRLatitudeField:
                Regions[CurrentRegionIndex].LowerRight.Latitude = ValidateLatitude(Field.stringValue)
                
            case LRLongitudeField:
                Regions[CurrentRegionIndex].LowerRight.Longitude = ValidateLongitude(Field.stringValue)
                
            case ULLatitudeField:
                Regions[CurrentRegionIndex].UpperLeft.Latitude = ValidateLatitude(Field.stringValue)
                
            case ULLongitudeField:
                Regions[CurrentRegionIndex].UpperLeft.Longitude = ValidateLongitude(Field.stringValue)
                
            case RegionNameBox:
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
    
    @IBOutlet weak var DeleteButton: NSButton!
    @IBOutlet weak var LRLatitudeField: NSTextField!
    @IBOutlet weak var LRLongitudeField: NSTextField!
    @IBOutlet weak var ULLongitudeField: NSTextField!
    @IBOutlet weak var ULLatitudeField: NSTextField!
    @IBOutlet weak var RegionBorderColorWell: NSColorWell!
    @IBOutlet weak var AgeCombo: NSComboBox!
    @IBOutlet weak var MaxMagCombo: NSComboBox!
    @IBOutlet weak var MinMagCombo: NSComboBox!
    @IBOutlet weak var BorderWidthSegment: NSSegmentedControl!
    @IBOutlet weak var RegionNameBox: NSTextField!
    @IBOutlet weak var RegionTable: NSTableView!
}
