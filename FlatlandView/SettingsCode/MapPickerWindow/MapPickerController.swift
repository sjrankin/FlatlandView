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
    public weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        SampleType = Settings.GetEnum(ForKey: .SampleViewType, EnumType: ViewTypes.self, Default: .Globe3D)
        MapSampleView.image = nil
        LastMap = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Standard)
        var LastCategory = MapManager.CategoryFor(Map: LastMap)
        if LastCategory == nil
        {
            LastCategory = .Standard
        }
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
        
        var CatIndex = MapCategoryList.firstIndex(of: LastCategory!)
        if CatIndex == nil
        {
            CatIndex = 0
        }
        MapTypeTable.selectRowIndexes(IndexSet(integer: CatIndex!), byExtendingSelection: false)
        var MapIndex = MapManager.GetMapsInCategory(LastCategory!).firstIndex(of: LastMap)
        if MapIndex == nil
        {
            MapIndex = 0
        }
        MapListTable.selectRowIndexes(IndexSet(integer: MapIndex!), byExtendingSelection: false)
    }
    
    var SampleType = ViewTypes.Globe3D
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
        if let Image = MapManager.ImageFor(MapType: Current, ViewType: SampleType)
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
    
    /// This function does nothing but is required for `#selector(HandleMapListClicked)` to function.
    @IBAction func MapListAction(_ sender: Any)
    {
    }
    
    /// This function does nothing but is required for `#selector(HandleMapCategoryClicked)` to function.
    @IBAction func MapTypeAction(_ sender: Any)
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
            Settings.SetEnum(LastMap, EnumType: MapTypes.self, ForKey: .MapType)
            MainDelegate?.Refresh("MapPickerController.HandleOKPressed")
        }
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent!.endSheet(Window!, returnCode: .OK)
    }
    
    @IBAction func HandleApplyPressed(_ sender: Any)
    {
        Settings.SetEnum(LastMap, EnumType: MapTypes.self, ForKey: .MapType)
        MainDelegate?.Refresh("MapPickerController.HandleApplyPressed")
    }
    
    @IBAction func HandleSampleViewChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            switch Segment.selectedSegment
            {
                case 0:
                    SampleType = .FlatNorthCenter
                
                case 1:
                    SampleType = .FlatSouthCenter
                
                case 2:
                    SampleType = .Globe3D
                
                default:
                    return
            }
            Settings.SetEnum(SampleType, EnumType: ViewTypes.self, ForKey: .SampleViewType)
            DisplayCurrentMap(LastMap)
        }
    }
    
    @IBOutlet weak var SampleViewType: NSSegmentedControl!
    @IBOutlet weak var LastSelectedLabel: NSTextField!
    @IBOutlet weak var MapSampleView: NSImageView!
    @IBOutlet weak var MapTypeTable: NSTableView!
    @IBOutlet weak var MapListTable: NSTableView!
}
