//
//  MapSelector.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class MapSelector: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InitializeMaps()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    var OriginalMap = MapTypes.BlackWhite
    var SampleType = ViewTypes.Globe3D
    var LastMap: MapTypes = .Standard
    var MapList = [MapTypes]()
    var MapCategoryList = [MapCategories]()
    var Updated = false
    var LastCategory: MapCategories? = nil
    
    func InitializeMaps()
    {
        SampleType = Settings.GetEnum(ForKey: .SampleViewType, EnumType: ViewTypes.self, Default: .Globe3D)
        switch SampleType
        {
            case .Globe3D, .CubicWorld:
                MapSampleViewSegment.selectedSegment = 2
            
            case .FlatNorthCenter:
                MapSampleViewSegment.selectedSegment = 0
            
            case .FlatSouthCenter:
                MapSampleViewSegment.selectedSegment = 1
                
            case .Rectangular:
                MapSampleViewSegment.selectedSegment = 3
        }
        MapSampleView.image = nil
        LastMap = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Standard)
        OriginalMap = LastMap
        LastCategory = MapManager.CategoryFor(Map: LastMap)
        if LastCategory == nil
        {
            LastCategory = .Standard
        }
        LastSelectedLabel.stringValue = LastMap.rawValue
        DisplayCurrentMap(LastMap)
        MapCategoryList = MapManager.GetMapCategories()
        if !Settings.GetBool(.EnableNASATiles)
        {
            if let SatelliteIndex = MapCategoryList.firstIndex(of: .Satellite)
            {
                MapCategoryList.remove(at: SatelliteIndex)
            }
        }
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
        else
        {
            if LastCategory! == .Satellite
            {
                TransparentMapCheck.isHidden = false
            }
            else
            {
                TransparentMapCheck.isHidden = true
            }
        }
        MapTypeTable.selectRowIndexes(IndexSet(integer: CatIndex!), byExtendingSelection: false)
        var MapIndex = MapManager.GetMapsInCategory(LastCategory!).firstIndex(of: LastMap)
        if MapIndex == nil
        {
            MapIndex = 0
        }
        MapListTable.selectRowIndexes(IndexSet(integer: MapIndex!), byExtendingSelection: false)
        NotesField.stringValue = ""
    }
    
    func DisplayCurrentMap(_ Current: MapTypes)
    {
        if let Image = MapManager.ImageFor(MapType: Current, ViewType: SampleType)
        {
            MapSampleView.image = Image
        }
    }
    
    @objc func HandleMapCategoryClicked()
    {
        let NewCategory = MapCategoryList[MapTypeTable.clickedRow]
        MapList = MapManager.GetMapsInCategory(NewCategory)
        MapListTable.reloadData()
        if NewCategory == .Satellite
        {
            TransparentMapCheck.isHidden = false
            NotesField.stringValue = "Maps in this category are downloaded from NASA and will take time to assemble and use your bandwidth."
        }
        else
        {
            TransparentMapCheck.isHidden = true
            NotesField.stringValue = ""
        }
    }
    
    @objc func HandleMapListClicked()
    {
        let ListIndex = MapListTable.clickedRow
        if ListIndex < 0
        {
            return
        }
        LastMap = MapList[ListIndex]
        LastSelectedLabel.stringValue = LastMap.rawValue
        DisplayCurrentMap(LastMap)
        Updated = true
    }
    
    /// This function does nothing but is required for `#selector(HandleMapListClicked)` to function.
    @IBAction func MapListAction(_ sender: Any)
    {
    }
    
    /// This function does nothing but is required for `#selector(HandleMapCategoryClicked)` to function.
    @IBAction func MapTypeAction(_ sender: Any)
    {
    }
    
    @IBAction func HandleApplyPressed(_ sender: Any)
    {
        //Set the updated flag to false. This way, if the user pressed the OK button, the map won't
        //be reloaded.
        if LastCategory == .Satellite
        {
            let Storyboard = NSStoryboard(name: "Settings", bundle: nil)
            if let WindowController = Storyboard.instantiateController(withIdentifier: "NASAMapConfirmWindow") as? NASAMapConfirmWindow
            {
                let Window = WindowController.window
                self.view.window?.beginSheet(Window!)
                {
                    Result in
                    if Result == .cancel
                    {
                        return
                    }
                }
            }
        }
        Updated = false
        Settings.SetEnum(LastMap, EnumType: MapTypes.self, ForKey: .MapType)
        OriginalMap = LastMap
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
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat
    {
        return 22.0
    }
    
    @IBAction func HandleTransparentMapCheckChanged(_ sender: Any)
    {
    }
    
    @IBOutlet weak var TransparentMapCheck: NSButton!
    @IBOutlet weak var NotesField: NSTextField!
    @IBOutlet weak var MapSampleViewSegment: NSSegmentedControl!
    @IBOutlet weak var MapListTable: NSTableView!
    @IBOutlet weak var MapTypeTable: NSTableView!
    @IBOutlet weak var LastSelectedLabel: NSTextField!
    @IBOutlet weak var MapSampleView: NSImageView!
}
