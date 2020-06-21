//
//  +CommonCode.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainSettings: NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate 
{
    func ValidateText(_ Raw: String, IsLongitude: Bool, GoodValue: inout Double) -> Bool
    {
        if let RawValue = Double(Raw)
        {
            if IsLongitude
            {
                if RawValue < -180.0 || RawValue > 180.0
                {
                    return false
                }
                GoodValue = RawValue
                return true
            }
            else
            {
                if RawValue < -90.0 || RawValue > 90.0
                {
                    return false
                }
                GoodValue = RawValue
                return true
            }
        }
        GoodValue = 0.0
        return false
    }
    
    func controlTextDidEndEditing(_ obj: Notification)
    {
        if let TextField = obj.object as? NSTextField
        {
            let TextValue = TextField.stringValue
            var GoodValue: Double = 0.0
            switch TextField
            {
                case UserLocationLongitudeBox:
                    if ValidateText(TextValue, IsLongitude: true, GoodValue: &GoodValue)
                    {
                        Settings.SetDoubleNil(.LocalLongitude, GoodValue)
                        MainDelegate?.Refresh("MainSettings.controlTextDidEndEditing")
                    }
                    else
                    {
                        TextField.stringValue = ""
                }
                
                case UserLocationLatitudeBox:
                    if ValidateText(TextValue, IsLongitude: false, GoodValue: &GoodValue)
                    {
                        Settings.SetDoubleNil(.LocalLatitude, GoodValue)
                        MainDelegate?.Refresh("MainSettings.controlTextDidEndEditing")
                    }
                    else
                    {
                        TextField.stringValue = ""
                }
                
                default:
                    return
            }
        }
    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        if OriginalMap != LastMap
        {
            Settings.SetEnum(LastMap, EnumType: MapTypes.self, ForKey: .MapType)
        }
        MainDelegate?.Refresh("MainSettings")
        self.view.window?.close()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        switch tableView
        {
            case UserLocationTable:
                return UserLocations.count
            
            case SunSelector:
                return SunImageList.count
            
            case MapTypeTable:
                return MapCategoryList.count
            
            case MapListTable:
                return MapList.count
            
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat
    {
        switch tableView
        {
            case SunSelector:
                return 65.0
            
            default:
                return 22.0
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
            
            case UserLocationTable:
                if tableColumn == tableView.tableColumns[0]
                {
                    CellIdentifier = "NameColumn"
                    CellContents = UserLocations[row].Name
                }
                if tableColumn == tableView.tableColumns[1]
                {
                    CellIdentifier = "LocationColumn"
                    let Loc = "\(UserLocations[row].Coordinates.Latitude.RoundedTo(3)), \(UserLocations[row].Coordinates.Longitude.RoundedTo(3))"
                    CellContents = Loc
                }
                if tableColumn == tableView.tableColumns[2]
                {
                    let Color = UserLocations[row].Color
                    let Swatch = NSView(frame: NSRect(x: 5, y: 2, width: 40, height: 20))
                    Swatch.wantsLayer = true
                    Swatch.layer?.backgroundColor = Color.cgColor
                    Swatch.layer?.borderColor = NSColor.black.cgColor
                    Swatch.layer?.borderWidth = 0.5
                    Swatch.layer?.cornerRadius = 5.0
                    return Swatch
            }
            
            case SunSelector:
                if tableColumn == tableView.tableColumns[0]
                {
                    CellIdentifier = "SunNameColumn"
                    CellContents = SunImageList[row].0.rawValue
                }
                if tableColumn == tableView.tableColumns[1]
                {
                    let SunView = NSImageView(image: SunImageList[row].1)
                    return SunView
            }
            
            default:
                return nil
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    @IBAction func HandleTableClicked(_ sender: Any)
    {
        if let Table = sender as? NSTableView
        {
            switch Table
            {
                case UserLocationTable:
                    CurrentUserLocationIndex = Table.selectedRow
                
                case SunSelector:
                    let SelectedSun = SunImageList[Table.selectedRow].0
                    Settings.SetEnum(SelectedSun, EnumType: SunNames.self, ForKey: .SunType)
                    MainDelegate?.Refresh("MainSettings.HandleTableClicked")
                
                default:
                    return
            }
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return SunImageList.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem
    {
        return NSCollectionViewItem()
    }
}
