//
//  MapPickerController.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class MapPickerController: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        MapSampleView.image = nil
        LastMap = Settings.GetEnum(ForKey: .CurrentMap, EnumType: MapTypes.self, Default: .Standard)
        LastSelectedLabel.stringValue = LastMap.rawValue
        DisplayCurrentMap(LastMap)
        MapCategoryList = MapManager.GetMapCategories()
        if let CurrentCategory = MapManager.CategoryFor(Map: LastMap)
        {
            MapList = MapManager.GetMapsInCategory(CurrentCategory)
        }
        else
        {
            MapList.removeAll()
        }
        MapTypeTable.reloadData()
        MapListTable.reloadData()
        MapTypeTable.action = #selector(HandleMapCategoryClicked)
        MapListTable.action = #selector(HandleMapListClicked)
    }
    
    var LastMap: MapTypes = .Standard
    var MapList = [MapTypes]()
    var MapCategoryList = [MapCategories]()
    var Updated = false
    
    // MARK: - Table handling.
    
    @objc func HandleMapCategoryClicked()
    {
        let NewCategory = MapCategoryList[MapTypeTable.clickedRow]
        MapList = MapManager.GetMapsInCategory(NewCategory)
        MapListTable.reloadData()
    }
    
    @objc func HandleMapListClicked()
    {
        let ListIndex = MapListTable.clickedRow
        LastMap = MapList[ListIndex]
        LastSelectedLabel.stringValue = LastMap.rawValue
        DisplayCurrentMap(LastMap)
        Updated = true
    }
    
    func DisplayCurrentMap(_ Current: MapTypes)
    {
        if let Image = MapManager.ImageFor(MapType: Current, ViewType: .Globe3D)
        {
        MapSampleView.image = Image
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        switch tableView
        {
            case MapTypeTable:
                return MapCategoryList.count
            
            case MapListTable:
                return MapList.count
            
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        switch tableView
        {
            case MapTypeTable:
                if tableColumn == tableView.tableColumns[0]
                {
                    CellIdentifier = "MapTypeColumn"
                    CellContents = MapCategoryList[row].rawValue
                }
                else
                {
                    return nil
            }
            
            case MapListTable:
                if tableColumn == tableView.tableColumns[0]
                {
                    CellIdentifier = "MapNameColumn"
                    CellContents = MapList[row].rawValue
                }
                else
                {
                    return nil
            }
            
            default:
                return nil
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    @IBAction func HandleMapTypeAction(_ sender: Any)
    {
    }
    
    @IBAction func HandleMapListAction(_ sender: Any)
    {
    }
    
    // MARK: - Button handling.
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent!.endSheet(Window!, returnCode: .cancel)
    }
    
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        if Updated
        {
            Settings.SetEnum(LastMap, EnumType: MapTypes.self, ForKey: .CurrentMap)
        }
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent!.endSheet(Window!, returnCode: .OK)
    }
    
    @IBOutlet weak var LastSelectedLabel: NSTextField!
    @IBOutlet weak var MapSampleView: NSImageView!
    @IBOutlet weak var MapTypeTable: NSTableView!
    @IBOutlet weak var MapListTable: NSTableView!
}
