//
//  Debug3DPanel.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/20/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class Debug3DPanel: PanelController, NSTableViewDelegate, NSTableViewDataSource 
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        FlagTable.delegate = self
        FlagTable.dataSource = self
    }
    
    let FlagData: [(Category: String, Name: String, Key: SettingKeys, Tag: Int)] =
    [
        ("Geometry", "Show bounding boxes", .ShowBoundingBoxes, 0),
        ("Geometry", "Show wireframe", .ShowWireframes, 1),
        ("Geometry", "Render as wireframe", .RenderAsWireframe, 2),
        ("Geometry", "Show skeletons", .ShowSkeletons, 3),
        ("Geometry", "Show creases", .ShowCreases, 4),
        ("Geometry", "Show constraints", .ShowConstraints, 5),
        ("Camera", "Show cameras", .ShowCamera, 10),
        ("Camera", "Show light influences", .ShowLightInfluences, 11),
        ("Camera", "Show light extents", .ShowLightExtents, 12),
        ("Physics", "Show physics shapes", .ShowPhysicsShapes, 20),
        ("Physics", "Show physics fields", .ShowPhysicsFields, 21)
    ]
    
    override func viewDidLayout()
    {
        FlagTable.reloadData()
        ShowAxesSwitch.state = Settings.GetBool(.ShowAxes) ? .on : .off
        EnableSwitch.state = Settings.GetBool(.Enable3DDebugging) ? .on : .off
        let MapType = Settings.GetEnum(ForKey: .Debug3DMap, EnumType: Debug_MapTypes.self, Default: .Globe)
        switch MapType
        {
            case .Globe:
                MapSegment.selectedSegment = 2
                
            case .Rectangular:
                MapSegment.selectedSegment = 0
                
            case .Round:
                MapSegment.selectedSegment = 1
        }
    }
    
    @IBAction func HandleEnableChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.Enable3DDebugging, Switch.state == .on)
        }
    }
    
    @IBAction func HandleMapTypeChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            var WhichMap: Debug_MapTypes = .Globe
            switch Segment.selectedSegment
            {
                case 0:
                    WhichMap = .Rectangular
                    
                case 1:
                    WhichMap = .Round
                    
                case 2:
                    WhichMap = .Globe
                    
                default:
                    return
            }
            Settings.SetEnum(WhichMap, EnumType: Debug_MapTypes.self, ForKey: .Debug3DMap)
        }
    }
    
    // MARK: - Table handling
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        let Count = FlagData.count
        return Count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat
    {
        return 30.0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        
        if tableColumn == tableView.tableColumns[0]
        {
            CellContents = FlagData[row].Category
            CellIdentifier = "CategoryColumn"
        }
        if tableColumn == tableView.tableColumns[1]
        {
            CellContents = FlagData[row].Name
            CellIdentifier = "NameColumn"
        }
        if tableColumn == tableView.tableColumns[2]
        {
            let Switch = NSSwitch()
            Switch.state = Settings.GetBool(FlagData[row].Key) ? .on : .off
            Switch.tag = FlagData[row].Tag
            Switch.target = self
            Switch.action = #selector(Handle3DFlagChanged)
            return Switch
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    func GetSettingKey(For TagValue: Int) -> SettingKeys?
    {
        for (_, _, Key, Tag) in FlagData
        {
            if Tag == TagValue
            {
                return Key
            }
        }
        return nil
    }
    
    @objc func Handle3DFlagChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            let SwitchTag = Switch.tag
            if let SettingKey = GetSettingKey(For: SwitchTag)
            {
                Settings.SetBool(SettingKey, Switch.state == .on)
            }
        }
    }
    @IBAction func HandleShowAxesChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.ShowAxes, Switch.state == .on)
        }
    }
    
    @IBOutlet weak var ShowAxesSwitch: NSSwitch!
    @IBOutlet weak var MapSegment: NSSegmentedControl!
    @IBOutlet weak var EnableSwitch: NSSwitch!
    @IBOutlet weak var FlagTable: NSTableView!
}
