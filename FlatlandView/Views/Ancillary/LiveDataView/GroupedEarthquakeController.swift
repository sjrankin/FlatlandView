//
//  GroupedEarthquakeController.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/20/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class GroupedEarthquakeController: NSViewController, NSTableViewDelegate, NSTableViewDataSource,
                                   NSWindowDelegate, AsynchronousDataProtocol, WindowManagement
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        StartWaitingRing()
        
        /// For default values if none exist.
        let _ = Settings.GetInt(.EarthquakeDisplayMagnitude, IfZero: 4)
        let _ = Settings.GetInt(.GroupEarthquakeDisplayMagnitude, IfZero: 4)
        
        USGSSource = USGS()
        USGSSource?.Delegate = self
        USGSSource?.GetEarthquakes(Every: 60.0)
        
        GroupTable.doubleAction = #selector(HandleDoubleClick)
        ParentTable.doubleAction = #selector(HandleDoubleClick)
        
        DoDecorateCoordinates = Settings.GetBool(.DecorateEarthquakeCoordinates)
        DecorateButton.state = DoDecorateCoordinates ? .on : .off
    }
    
    override func viewDidAppear()
    {
        self.view.window?.delegate = self
    }
    
    override func viewDidLayout()
    {
        ParentMagnitudeFilter.removeAllItems()
        GroupMagnitudeFilter.removeAllItems()
        ParentAgeFilter.removeAllItems()
        GroupAgeFilter.removeAllItems()
        
        for Age in EarthquakeAges.allCases
        {
            ParentAgeFilter.addItem(withObjectValue: Age.rawValue)
            GroupAgeFilter.addItem(withObjectValue: Age.rawValue)
        }
        let ParentPreviousAge = Settings.GetEnum(ForKey: .EarthquakeListAge, EnumType: EarthquakeAges.self, Default: .Age5)
        if let Index = EarthquakeAges.allCases.firstIndex(of: ParentPreviousAge)
        {
            ParentAgeFilter.selectItem(at: Index)
        }
        else
        {
            ParentAgeFilter.selectItem(at: EarthquakeAges.allCases.count - 1)
        }
        let GroupPreviousAge = Settings.GetEnum(ForKey: .GroupEarthquakeListAge, EnumType: EarthquakeAges.self, Default: .Age5)
        if let Index = EarthquakeAges.allCases.firstIndex(of: GroupPreviousAge)
        {
            GroupAgeFilter.selectItem(at: Index)
        }
        else
        {
            GroupAgeFilter.selectItem(at: EarthquakeAges.allCases.count - 1)
        }
        
        for Mag in stride(from: 10, through: 4, by: -1)
        {
            ParentMagnitudeFilter.addItem(withObjectValue: "\(Mag)")
            GroupMagnitudeFilter.addItem(withObjectValue: "\(Mag)")
        }
        let PreviousParentMag = Settings.GetInt(.EarthquakeDisplayMagnitude, IfZero: 4)
        ParentMagnitudeFilter.selectItem(withObjectValue: "\(PreviousParentMag)")
        let PreviousGroupMag = Settings.GetInt(.GroupEarthquakeDisplayMagnitude, IfZero: 4)
        GroupMagnitudeFilter.selectItem(withObjectValue: "\(PreviousGroupMag)")
    }
    
    func StartWaitingRing()
    {
        WaitingRing.startAnimation(self)
        let ColorFilter = CIFilter(name: "CIFalseColor")
        ColorFilter?.setDefaults()
        ColorFilter?.setValue(CIColor(cgColor: NSColor.systemBlue.cgColor), forKey: "inputColor0")
        ColorFilter?.setValue(CIColor(cgColor: NSColor.black.cgColor), forKey: "inputColor1")
        WaitingRing.contentFilters = [ColorFilter!]
    }
    
    @objc func HandleDoubleClick(_ sender: Any)
    {
        if let Table = sender as? NSTableView
        {
            if Table == GroupTable
            {
                let Index = Table.selectedRow
                if Index < 0
                {
                    return
                }
                if let Quake = ParentData[CurrentParent].Related?[Index]
                {
                    let Storyboard = NSStoryboard(name: "LiveData", bundle: nil)
                    if let WindowController = Storyboard.instantiateController(withIdentifier: "EarthquakeDetailWindow") as? EarthquakeDetailWindow
                    {
                        let Window = WindowController.window
                        if let Controller = Window?.contentViewController as? EarthquakeDetailController
                        {
                            Controller.DisplayEarthquake(Quake)
                        }
                        self.view.window?.beginSheet(Window!, completionHandler: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func HandleCloseButtonPressed(_ sender: Any)
    {
        if let Frame = self.view.window?.frame
        {
            Settings.SetRect(.EarthquakeViewWindowFrame, Frame)
        }
        self.view.window?.close()
    }
    
    func MainClosing()
    {
        self.view.window?.close()
    }
    
    @IBAction func HandleComboBoxChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            switch Combo
            {
                case ParentAgeFilter:
                    if let Raw = Combo.objectValueOfSelectedItem as? String
                    {
                        if let Age = EarthquakeAges(rawValue: Raw)
                        {
                            Settings.SetEnum(Age, EnumType: EarthquakeAges.self, ForKey: .EarthquakeListAge)
                            UpdateTable(ParentTable)
                        }
                    }
                    
                case ParentMagnitudeFilter:
                    if let Raw = Combo.objectValueOfSelectedItem as? String
                    {
                        if let Mag = Int(Raw)
                        {
                            if Mag >= 4 && Mag <= 10
                            {
                                Settings.SetInt(.EarthquakeDisplayMagnitude, Mag)
                                UpdateTable(ParentTable)
                            }
                        }
                    }
                    
                case GroupAgeFilter:
                    if let Raw = Combo.objectValueOfSelectedItem as? String
                    {
                        if let Age = EarthquakeAges(rawValue: Raw)
                        {
                            Settings.SetEnum(Age, EnumType: EarthquakeAges.self, ForKey: .GroupEarthquakeListAge)
                            UpdateTable(GroupTable)
                        }
                    }
                    
                case GroupMagnitudeFilter:
                    if let Raw = Combo.objectValueOfSelectedItem as? String
                    {
                        if let Mag = Int(Raw)
                        {
                            if Mag >= 4 && Mag <= 10
                            {
                                Settings.SetInt(.GroupEarthquakeDisplayMagnitude, Mag)
                                UpdateTable(GroupTable)
                            }
                        }
                    }
                    
                default:
                    return
            }
        }
    }
    
    func HandleNewWindowSize()
    {
        
    }
    
    func windowDidResize(_ notification: Notification)
    {
        HandleNewWindowSize()
    }
    
    func DoSortEarthquakes()
    {
        
    }
    
    func LoadData(DataType: AsynchronousDataCategories, Raw: Any)
    {
        switch DataType
        {
            case .Earthquakes:
                if let RawData = Raw as? [Earthquake]
                {
                    SourceData = USGS.CombineEarthquakes(RawData)
                    ParentData = SourceData
                    UpdateTable(ParentTable)
                }
                
            default:
                break
        }
    }
    
    var SourceData = [Earthquake]()
    
    func AsynchronousDataAvailable(CategoryType: AsynchronousDataCategories, Actual: Any?)
    {
        WaitingRing.stopAnimation(self)
        if Actual != nil
        {
            LoadData(DataType: CategoryType, Raw: Actual!)
            DoSortEarthquakes()
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        switch tableView
        {
            case ParentTable:
                return ParentData.count
                
            case GroupTable:
                if ParentData.count < 1
                {
                    return 0
                }
                if CurrentParent < 0
                {
                    return 0
                }
                if ParentData[CurrentParent].IsCluster
                {
                    return ParentData[CurrentParent].ClusterCount
                }
                else
                {
                    return 1
                }
                
            default:
                return 0
        }
    }
    
    var CurrentParent: Int = 0
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        var CellToolTip: String? = nil
        
        switch tableView
        {
            case ParentTable:
                if tableColumn == tableView.tableColumns[0]
                {
                    CellIdentifier = "DateColumn"
                    let Raw = ParentData[row].Time.PrettyDateTime()
                    let Parts = Raw.split(separator: "+", omittingEmptySubsequences: true)
                    let Useful = String(Parts[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                    CellContents = Useful
                    CellToolTip = Useful
                }
                if tableColumn == tableView.tableColumns[1]
                {
                    CellIdentifier = "MagColumn"
                    CellContents = "\(ParentData[row].GreatestMagnitude)"
                }
                if tableColumn == tableView.tableColumns[2]
                {
                    CellIdentifier = "CountColumn"
                    let Count = ParentData[row].ClusterCount
                    if Count == 0
                    {
                        CellContents = "Ø"
                    }
                    else
                    {
                        CellContents = "\(Count)"
                    }
                }
                
            case GroupTable:
                if tableColumn == tableView.tableColumns[0]
                {
                    CellIdentifier = "CodeColumn"
                    CellContents = GroupData[row].Code
                }
                if tableColumn == tableView.tableColumns[1]
                {
                    CellIdentifier = "LocationColumn"
                    CellContents = GroupData[row].Place
                    CellToolTip = CellContents
                }
                if tableColumn == tableView.tableColumns[2]
                {
                    CellIdentifier = "MagnitudeColumn"
                    CellContents = "\(GroupData[row].Magnitude)"
                }
                if tableColumn == tableView.tableColumns[3]
                {
                    CellIdentifier = "DateColumn"
                    let Raw = GroupData[row].Time.PrettyDateTime()
                    let Parts = Raw.split(separator: "+", omittingEmptySubsequences: true)
                    let Useful = String(Parts[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                    CellContents = Useful
                    CellToolTip = Useful
                }
                if tableColumn == tableView.tableColumns[4]
                {
                    CellIdentifier = "CoordinateColumn"
                    if DoDecorateCoordinates
                    {
                        var Latitude = GroupData[row].Latitude.RoundedTo(3)
                        var Longitude = GroupData[row].Longitude.RoundedTo(3)
                        let LatIndicator = Latitude >= 0.0 ? "N" : "S"
                        let LonIndicator = Longitude < 0.0 ? "W" : "E"
                        Latitude = abs(Latitude)
                        Longitude = abs(Longitude)
                        CellContents = "\(Latitude)\(LatIndicator)\t\t\(Longitude)\(LonIndicator)"
                    }
                    else
                    {
                        CellContents = "\(GroupData[row].Latitude.RoundedTo(3))\t\t\(GroupData[row].Longitude.RoundedTo(3))"
                    }
                }
                
            default:
                return nil
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        if let ToolTip = CellToolTip
        {
            Cell?.toolTip = ToolTip
        }
        return Cell
    }
    
    func UpdateTable(_ Table: NSTableView)
    {
        switch Table
        {
            case ParentTable:
                let Seconds = Double(AgeFilterValue(From: ParentAgeFilter))
                ParentData.removeAll()
                for Quake in SourceData
                {
                    let IsInAgeRange = Quake.GetAge() <= Seconds
                    let IsInMagRange = Quake.GreatestMagnitude >= Double(Settings.GetInt(.EarthquakeDisplayMagnitude, IfZero: 4))
                    if IsInAgeRange && IsInMagRange
                    {
                        ParentData.append(Quake)
                    }
                }
                ParentTable.reloadData()
                
            case GroupTable:
                let Seconds = Double(AgeFilterValue(From: GroupAgeFilter))
                GroupData.removeAll()
                if let Children = ParentData[CurrentParent].Related
                {
                    for Quake in Children
                    {
                        let IsInAgeRange = Quake.GetAge() <= Seconds
                        let IsInMagRange = Quake.GreatestMagnitude >= Double(Settings.GetInt(.GroupEarthquakeDisplayMagnitude, IfZero: 4))
                        if IsInAgeRange && IsInMagRange
                        {
                            GroupData.append(Quake)
                        }
                    }
                    GroupTable.reloadData()
                }
                
            default:
                return
        }
    }
    
    func AgeFilterValue(From: NSComboBox) -> Int
    {
        if let Current = From.objectValueOfSelectedItem as? String
        {
            if let Age = EarthquakeAges(rawValue: Current)
            {
                if let Index = EarthquakeAges.allCases.firstIndex(of: Age)
                {
                    let FinalAge = 24 * 60 * 60 * Index
                    return FinalAge
                }
            }
        }
        return 30 * 24 * 60 * 60
    }
    
    @IBAction func HandleDecorateButtonPressed(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            DoDecorateCoordinates = Button.state == .on ? true : false
            GroupTable.reloadData()
            Settings.SetBool(.DecorateEarthquakeCoordinates, DoDecorateCoordinates)
        }
    }
    
    @IBAction func HandleParentAction(_ sender: Any)
    {
        if let Table = sender as? NSTableView
        {
            switch Table
            {
                case ParentTable:
                    CurrentParent = Table.selectedRow
                    if CurrentParent < 0
                    {
                        return
                    }
                    GroupData.removeAll()
                    if ParentData[CurrentParent].IsCluster
                    {
                        GroupData = ParentData[CurrentParent].Related!
                    }
                    else
                    {
                        GroupData.append(ParentData[CurrentParent])
                    }
                    UpdateTable(GroupTable)
                    
                case GroupTable:
                    break
                    
                default:
                    return
            }
        }
    }
    
    var GroupData = [Earthquake]()
    var DoDecorateCoordinates: Bool = false
    var USGSSource: USGS? = nil
    var ParentData = [Earthquake]()
    
    @IBOutlet weak var DecorateButton: NSButton!
    @IBOutlet weak var ParentMagnitudeFilter: NSComboBox!
    @IBOutlet weak var ParentAgeFilter: NSComboBox!
    @IBOutlet weak var GroupMagnitudeFilter: NSComboBox!
    @IBOutlet weak var GroupAgeFilter: NSComboBox!
    @IBOutlet weak var WaitingRing: NSProgressIndicator!
    @IBOutlet weak var ParentTable: NSTableView!
    @IBOutlet weak var GroupTable: NSTableView!
}
