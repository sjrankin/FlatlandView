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
    
    var Regions = [EarthquakeRegion]()
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent?.endSheet(Window!, returnCode: .OK)
    }
    
    @IBAction func HandleTableAction(_ sender: Any)
    {
    }

    @IBAction func HandleAddButton(_ sender: Any)
    {
    }
    
    @IBAction func HandleDeleteButton(_ sender: Any)
    {
    }
    
    @IBAction func HandleBorderWidthChanged(_ sender: Any)
    {
    }
    
    @IBAction func HandleMinMagnitudeChanged(_ sender: Any)
    {
    }
    
    @IBAction func HandleMaxMagnitudeChanged(_ sender: Any)
    {
    }
    
    @IBAction func HandleAgeComboChanged(_ sender: Any)
    {
    }
    
    @IBAction func HandleRegionBorderWellChanged(_ sender: Any)
    {
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
    
    func controlTextDidEndEditing(_ obj: Notification)
    {
        if let TextField = obj.object as? NSTextField
        {
            switch TextField
            {
                case LRLatitudeField:
                    break
                    
                case LRLongitudeField:
                    break
                    
                case ULLatitudeField:
                    break
                    
                case ULLongitudeField:
                    break
                    
                case RegionNameBox:
                    break
                    
                default:
                    return
            }
        }
    }
    
    @IBAction func HandleSetButton(_ sender: Any)
    {
    }
    
    @IBOutlet weak var DeleteButton: NSButton!
    @IBOutlet weak var SetButton: NSButton!
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
