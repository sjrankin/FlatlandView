//
//  MainSettingsBase.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class MainSettingsBase: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    public weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InitializeSideBar()
        let LastViewed = Settings.GetEnum(ForKey: .LastSettingsViewed, EnumType: SettingGroups.self, Default: .Maps)
        ShowOptionsDialog(LastViewed)
        if let Index = SettingGroups.allCases.firstIndex(of: LastViewed)
        {
            let TableIndex = IndexSet(integer: Index)
            SideBar.selectRowIndexes(TableIndex, byExtendingSelection: false)
            DialogBox.title = SettingGroups.allCases[Index].rawValue
        }
    }
    
    func InitializeSideBar()
    {
        SideBar.reloadData()
        CreateOptionsWindows()
    }
    
    func CreateOptionsWindows()
    {
        SettingMap[.Maps] = SettingEntry(CreateSettingDialog("MapSelector"))
        SettingMap[.Map2D] = SettingEntry(CreateSettingDialog("Settings2DMap"))
        SettingMap[.Map3D] = SettingEntry(CreateSettingDialog("Settings3DMap"))
        SettingMap[.Cities] = SettingEntry(CreateSettingDialog("CitiesSettings"))
        SettingMap[.UserLocation] = SettingEntry(CreateSettingDialog("UserLocations"))
        SettingMap[.OtherLocations] = SettingEntry(CreateSettingDialog("OtherLocations"))
        SettingMap[.Other] = SettingEntry(CreateSettingDialog("OtherSettings"))
        SettingMap[.Earthquakes] = SettingEntry(CreateSettingDialog("EarthquakeSettings"))
    }
    
    var SettingMap = [SettingGroups: SettingEntry]()
    
    func CreateSettingDialog(_ IDName: String) -> NSViewController?
    {
        if let Controller = NSStoryboard(name: "Settings", bundle: nil).instantiateController(withIdentifier: IDName) as? NSViewController
        {
            return Controller
        }
        fatalError("Error creating \(IDName)")
    }
    
    func ShowOptionsDialog(_ Options: SettingGroups)
    {
        for SomeView in OptionsContainer.subviews
        {
            SomeView.removeFromSuperview()
        }
        switch Options
        {
            case .Maps:
                break
            case .Map2D:
                break
            case .Map3D:
                break
            case .Cities:
                break
            case .UserLocation:
                break
            case .OtherLocations:
                break
            case .Other:
                break
            case .Earthquakes:
                (SettingMap[Options]!.Controller as! EarthquakeSettingsWindow).LoadData(DataType: .Earthquakes, Raw: LiveEarthquakes as Any)
        }
        SettingMap[Options]!.Controller?.view.frame = OptionsContainer.bounds
        OptionsContainer.addSubview(SettingMap[Options]!.Controller!.view)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return SettingGroups.allCases.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "OptionColumn"
            CellContents =  SettingGroups.allCases[row].rawValue
        }
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    @IBAction func HandleTableClicked(_ sender: Any)
    {
        if let Table = sender as? NSTableView
        {
            let Row = Table.selectedRow
            if Row >= 0
            {
                DialogBox.title = SettingGroups.allCases[Row].rawValue
                ShowOptionsDialog(SettingGroups.allCases[Row])
                Settings.SetEnum(SettingGroups.allCases[Row], EnumType: SettingGroups.self, ForKey: .LastSettingsViewed)
            }
        }
    }
    
    @IBAction func HandleCloseClicked(_ sender: Any)
    {
        MainDelegate?.Refresh("MainSettings")
        self.view.window?.close()
    }
    
    func LoadData(DataType: AsynchronousDataTypes, Raw: Any?)
    {
        switch DataType
        {
            case .Earthquakes:
            if let Quakes = Raw as? [Earthquake]
            {
                LiveEarthquakes = Quakes
            }
            
            case .Earthquakes2:
            if let Quakes = Raw as? [Earthquake2]
            {
                LiveEarthquakes2 = Quakes
            }
        }
    }
    
    var LiveEarthquakes = [Earthquake]()
    var LiveEarthquakes2 = [Earthquake2]()
    
    @IBOutlet weak var DialogBox: NSBox!
    @IBOutlet weak var OptionsContainer: ContainerController!
    @IBOutlet weak var SideBar: NSTableView!
}

class SettingEntry
{
    init(_ Controller: NSViewController?)
    {
        self.Controller = Controller
    }
    
    public var Controller: NSViewController? = nil
}
