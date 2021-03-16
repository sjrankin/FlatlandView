//
//  BuiltInPOIController.swift
//  Flatland
//
//  Created by Stuart Rankin on 2/7/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class BuiltInPOIController: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    var Parent: NSWindow? = nil
    var Window: NSWindow? = nil
    
    override func viewDidLoad()
    {
    }
    
    override func viewDidLayout()
    {
        super.viewDidLayout()
        Window = self.view.window
        Parent = Window?.sheetParent
//        POIData = MainController.BuiltInPOIs
        POIData = Settings.GetPOIs()
        POITable.reloadData()
    }
    
    var POIData = [POI2]()
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return POIData.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        var ToolTip = ""
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "NameColumn"
            CellContents = POIData[row].Name
            ToolTip = POIData[row].Description
        }
        if tableColumn == tableView.tableColumns[1]
        {
            CellIdentifier = "TypeColumn"
            if let POIType = POITypes2(rawValue: POIData[row].POIType)
            {
                CellContents = Locations.POITypeToName(POIType)
            }
            else
            {
                CellContents = "\(POIData[row].POIType)"
            }
        }
        if tableColumn == tableView.tableColumns[2]
        {
            CellIdentifier = "LatitudeColumn"
            CellContents = Utility.PrettyLatitude(POIData[row].Latitude)
        }
        if tableColumn == tableView.tableColumns[3]
        {
            CellIdentifier = "LongitudeColumn"
            CellContents = Utility.PrettyLongitude(POIData[row].Longitude)
        }
        if tableColumn == tableView.tableColumns[4]
        {
            let ShowSwitch = NSSwitch()
            ShowSwitch.alignment = .left
            ShowSwitch.tag = row
            ShowSwitch.state = POIData[row].Show ? .on : .off
            ShowSwitch.action = #selector(HandlePOIShowStateChanged)
            ShowSwitch.target = self
            return ShowSwitch
        }
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        if !ToolTip.isEmpty
        {
            Cell?.textField?.toolTip = ToolTip
        }
        return Cell
    }
    
    @objc func HandlePOIShowStateChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            let Tag: Int = Switch.tag
            let IsOn = Switch.state == .on ? true : false
            POIData[Tag].Show = IsOn
        }
    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        Parent?.endSheet(Window!, returnCode: .OK)
    }
    
    @IBOutlet weak var POITable: NSTableView!
}
