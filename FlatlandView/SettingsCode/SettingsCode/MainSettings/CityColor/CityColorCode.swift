//
//  CityColorCode.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/2/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class CityColorCode: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    public weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        for CityGroup in CityGroups.allCases
        {
            switch CityGroup
            {
                case .AfricanCities:
                    Cities.append((CityGroup, Settings.GetColor(.AfricanCityColor)!))
                
                case .AsianCities:
                    Cities.append((CityGroup, Settings.GetColor(.AsianCityColor)!))
                
                case .CapitalCities:
                    Cities.append((CityGroup, Settings.GetColor(.CapitalCityColor)!))
                
                case .EuropeanCities:
                    Cities.append((CityGroup, Settings.GetColor(.EuropeanCityColor)!))
                
                case .NorthAmericanCities:
                    Cities.append((CityGroup, Settings.GetColor(.NorthAmericanCityColor)!))
                
                case .SouthAmericanCities:
                    Cities.append((CityGroup, Settings.GetColor(.SouthAmericanCityColor)!))
                
                case .WorldCities:
                    Cities.append((CityGroup, Settings.GetColor(.WorldCityColor)!))
            }
        }
    }
    
    let GroupMap: [CityGroups: SettingTypes] =
        [
            .AfricanCities: .AfricanCityColor,
            .AsianCities: .AsianCityColor,
            .CapitalCities: .CapitalCityColor,
            .EuropeanCities: .EuropeanCityColor,
            .NorthAmericanCities: .NorthAmericanCityColor,
            .SouthAmericanCities: .SouthAmericanCityColor,
            .WorldCities: .WorldCityColor
    ]
    
    var Cities = [(CityGroups, NSColor)]()
    
    func IndexOf(_ Color: NSColor) -> Int?
    {
        var Index = 0
        for SomeColor in ColorList.Colors
        {
            if SomeColor.Color.SameAs(Color)
            {
                return Index
            }
            Index = Index + 1
        }
        return nil
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        switch tableView
        {
            case ColorTable:
                return ColorList.Colors.count
            
            case CityTable:
                return Cities.count
            
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellIdentifier = ""
        switch tableView
        {
            case ColorTable:
                if tableColumn == tableView.tableColumns[0]
                {
                    CellIdentifier = "ColorNameColumn"
                    let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
                    Cell?.textField?.stringValue = ColorList.Colors[row].Name
                    return Cell
                }
                if tableColumn == tableView.tableColumns[1]
                {
                    CellIdentifier = "ColorSwatchColumn"
                    let Color = ColorList.Colors[row].Color
                    let Swatch = NSView(frame: NSRect(x: 5, y: 2, width: 40, height: 20))
                    Swatch.wantsLayer = true
                    Swatch.layer?.backgroundColor = Color.cgColor
                    Swatch.layer?.borderColor = NSColor.black.cgColor
                    Swatch.layer?.borderWidth = 0.5
                    Swatch.layer?.cornerRadius = 5.0
                    return Swatch
            }
            
            case CityTable:
                if tableColumn == tableView.tableColumns[0]
                {
                    CellIdentifier = "CityTypeColumn"
                    let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
                    Cell?.textField?.stringValue = Cities[row].0.rawValue
                    return Cell
                }
                if tableColumn == tableView.tableColumns[1]
                {
                    CellIdentifier = "CityColorColumn"
                    let Color = Cities[row].1
                    let Swatch = NSView(frame: NSRect(x: 5, y: 2, width: 40, height: 20))
                    Swatch.wantsLayer = true
                    Swatch.layer?.backgroundColor = Color.cgColor
                    Swatch.layer?.borderColor = NSColor.black.cgColor
                    Swatch.layer?.borderWidth = 0.5
                    Swatch.layer?.cornerRadius = 5.0
                    return Swatch
            }
            
            default:
                return nil
        }
        
        return nil
    }
    
    @IBAction func HandleTableAction(_ sender: Any)
    {
        if let Table = sender as? NSTableView
        {
            switch Table
            {
                case ColorTable:
                    let ColorIndex = Table.selectedRow
                    let CityIndex = CityTable.selectedRow
                    let (GroupName, _) = Cities[CityIndex]
                    Cities[CityIndex] = (GroupName, ColorList.Colors[ColorIndex].Color)
                    CityTable.reloadData()
                
                case CityTable:
                    let CityIndex = Table.selectedRow
                    CityTable.scrollRowToVisible(CityIndex)
                    if let ColorIndex = IndexOf(Cities[CityIndex].1)
                    {
                        let ISet = IndexSet(integer: ColorIndex)
                        ColorTable.selectRowIndexes(ISet, byExtendingSelection: false)
                        ColorTable.scrollRowToVisible(ColorIndex)
                    }
                    else
                    {
                        let ISet = IndexSet(integer: 0)
                        ColorTable.selectRowIndexes(ISet, byExtendingSelection: false)
                        ColorTable.scrollRowToVisible(0)
                }
                
                default:
                    return
            }
        }
    }
    
    func SaveColors()
    {
        for (Group, Color) in Cities
        {
            if let GroupSetting = GroupMap[Group]
            {
                Settings.SetColor(GroupSetting, Color)
            }
        }
        MainDelegate?.Refresh("CityColorCode.SaveColors")
    }
    
    @IBAction func HandleOKButton(_ sender: Any)
    {
        SaveColors()
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent?.endSheet(Window!, returnCode: .OK)
    }
    
    @IBAction func HandleCancelButton(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent?.endSheet(Window!, returnCode: .cancel)
    }
    
    @IBAction func HandleResetButton(_ sender: Any)
    {
        Cities.removeAll()
        for CityGroup in CityGroups.allCases
        {
            Cities.append((CityGroup, Settings.DefaultCityGroupColor(For: CityGroup)))
        }
        CityTable.reloadData()
    }
    
    @IBOutlet weak var ColorTable: NSTableView!
    @IBOutlet weak var CityTable: NSTableView!
}
