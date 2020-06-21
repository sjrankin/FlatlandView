//
//  +MapSelection.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainSettings
{
    func InitializeMaps()
    {
        SampleType = Settings.GetEnum(ForKey: .SampleViewType, EnumType: ViewTypes.self, Default: .Globe3D)
        MapSampleView.image = nil
        LastMap = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Standard)
        OriginalMap = LastMap
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
    }
    
    @objc func HandleMapListClicked()
    {
        let ListIndex = MapListTable.clickedRow
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
        Updated = false
        Settings.SetEnum(LastMap, EnumType: MapTypes.self, ForKey: .MapType)
        OriginalMap = LastMap
        MainDelegate?.Refresh(#function)
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
}
