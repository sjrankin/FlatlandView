//
//  CustomCityController.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/13/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class CustomCityController: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        CustomCities = Settings.GetCustomCities()
        UpdateCities()
        UpdateTables()
    }
    
    var CityDictionary = [UUID: City2]()
    var CustomCities = [UUID]()
    var CurrentAllCities = [UUID]()
    
    func MakeCityDictionary()
    {
        for City in CityManager.AllCities!
        {
            CityDictionary[City.CityID] = City
        }
    }
    
    func UpdateCities()
    {
        if CustomCities.count == 0
        {
            for (ID, _) in CityDictionary
            {
                CityDictionary[ID]?.IsCustomCity = false
            }
            RemoveButton.isEnabled = false
            return
        }
        RemoveButton.isEnabled = true
        CurrentAllCities.removeAll()
        
    }
    
    @IBAction func HandleAddButtonPressed(_ sender: Any)
    {
    }
    
    @IBAction func HandleRemoveButtonPressed(_ sender: Any)
    {
    }
    
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent?.endSheet(Window!, returnCode: .OK)
    }
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent?.endSheet(Window!, returnCode: .cancel)
    }
    
    @IBAction func HandleTableAction(_ sender: Any)
    {
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        switch tableView
        {
            case CustomCityTable:
                return CustomCities.count
                
            case AvailableCityTable:
                return FinalAvailable.count
                
            default:
                return 0
        }
    }
    
    func UpdateTables()
    {
        FinalAvailable.removeAll()
        for (_, SomeCity) in CityDictionary
        {
            if !SomeCity.IsCustomCity
            {
                FinalAvailable.append(SomeCity)
            }
        }
        FinalAvailable.sort(by: {$0.Name < $1.Name})
        AvailableCityTable.reloadData()
        CustomCityTable.reloadData()
    }
    
    var FinalAvailable = [City2]()
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        
        switch tableView
        {
            case CustomCityTable:
                let CityID = CustomCities[row]
                let TheCity = CityDictionary[CityID]!
                let Population = TheCity.GetPopulation(true)
                if tableColumn == tableView.tableColumns[0]
                {
                    CellIdentifier = "CustomCityNameColumn"
                    CellContents = TheCity.Name
                }
                if tableColumn == tableView.tableColumns[1]
                {
                    CellIdentifier = "CustomCityPopulationColumn"
                    CellContents = "\(Population)"
                }
                
            case AvailableCityTable:
                if tableColumn == tableView.tableColumns[0]
                {
                    CellIdentifier = "AvailableCityNameColumn"
                    CellContents = FinalAvailable[row].Name
                }
                if tableColumn == tableView.tableColumns[1]
                {
                    CellIdentifier = "AvailableCityPopulationColumn"
                    CellContents = "\(FinalAvailable[row].GetPopulation(true))"
                }
            
            default:
                return nil
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    @IBOutlet weak var CustomCityTable: NSTableView!
    @IBOutlet weak var AvailableCityTable: NSTableView!
    @IBOutlet weak var RemoveButton: NSButton!
    @IBOutlet weak var AddButton: NSButton!
}
