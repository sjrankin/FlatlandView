//
//  GroupedEarthquakeController.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/20/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

class GroupedEarthquakeController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, 
                                   NSWindowDelegate, AsynchronousDataProtocol, WindowManagement
{
    public weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
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
        
        RefreshButton.toolTip = "Press to refresh earthquakes immediately."
        
        QuakeTypeSegment.selectedSegment = 0
        
        ParentTable.tableColumns[0].sortDescriptorPrototype = ParentDateDescriptor
        ParentTable.tableColumns[1].sortDescriptorPrototype = ParentMagnitudeDescriptor
        ParentTable.tableColumns[2].sortDescriptorPrototype = ParentCountDescriptor
        GroupTable.tableColumns[1].sortDescriptorPrototype = GroupCodeDescriptor
        GroupTable.tableColumns[2].sortDescriptorPrototype = GroupLocationDescriptor
        GroupTable.tableColumns[3].sortDescriptorPrototype = GroupMagnitudeDescriptor
        GroupTable.tableColumns[4].sortDescriptorPrototype = GroupDateDescriptor
        
        RoundTextView.RotateClockwise = false
        RoundTextView.TextFont = NSFont.boldSystemFont(ofSize: 80.0)
        RoundTextView.TextRadius = 7.0
        RoundTextView.RotationOffset = 0.33
        RoundTextView.AnimationDuration = 0.01
        RoundTextView.ShowText("Please Wait")
    }
    
    let ParentCountDescriptor = NSSortDescriptor(key: ParentTableDescriptors.Count.rawValue, ascending: true)
    let ParentMagnitudeDescriptor = NSSortDescriptor(key: ParentTableDescriptors.Magnitude.rawValue, ascending: false)
    let ParentDateDescriptor = NSSortDescriptor(key: ParentTableDescriptors.Date.rawValue, ascending: false)
    
    let GroupCodeDescriptor = NSSortDescriptor(key: GroupTableDescriptors.Code.rawValue, ascending: true)
    let GroupLocationDescriptor = NSSortDescriptor(key: GroupTableDescriptors.Location.rawValue, ascending: true)
    let GroupMagnitudeDescriptor = NSSortDescriptor(key: GroupTableDescriptors.Magnitude.rawValue, ascending: true)
    let GroupDateDescriptor = NSSortDescriptor(key: GroupTableDescriptors.Date.rawValue, ascending: true)
    
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
                    AllQuakes = RawData
                    SourceAllQuakes = RawData
                    SourceData = USGS.CombineEarthquakes2(RawData)
                    ParentData = SourceData
                    UpdateTable(ParentTable)
                }
                
            default:
                break
        }
    }
    
    var SourceAllQuakes = [Earthquake]()
    var AllQuakes = [Earthquake]()
    var SourceData = [Earthquake]()
    
    func AsynchronousDataAvailable(CategoryType: AsynchronousDataCategories, Actual: Any?, StartTime: Double,
                                   Description: String?)
    {
        RoundTextView.Hide()
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
                if ViewingGroupedQuakes
                {
                    return GroupData.count
                }
                else
                {
                    return AllQuakes.count
                }
                
            default:
                return 0
        }
    }
    
    var CurrentParent: Int = 0
    var GroupIndex: Int = 1
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        var CellToolTip: String? = nil
        var RightJustify = false
        var IsEnabled = true
        
        switch tableView
        {
            case ParentTable:
                IsEnabled = ViewingGroupedQuakes
                CellToolTip = "\(ParentData[row].Code): \(ParentData[row].Place) \(ParentData[row].GreatestMagnitude)"
                if tableColumn == tableView.tableColumns[0]
                {
                    CellIdentifier = "DateColumn"
                    let Raw = ParentData[row].Time.PrettyDateTime()
                    let Parts = Raw.split(separator: "+", omittingEmptySubsequences: true)
                    let Useful = String(Parts[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                    CellContents = Useful
                }
                if tableColumn == tableView.tableColumns[1]
                {
                    CellIdentifier = "MagColumn"
                    CellContents = "\(ParentData[row].GreatestMagnitude)"
                    RightJustify = true
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
                    CellIdentifier = "IndexColumn"
                    CellContents = "\(GroupIndex)"
                    RightJustify = true
                    GroupIndex = GroupIndex + 1
                }
                if tableColumn == tableView.tableColumns[1]
                {
                    CellIdentifier = "CodeColumn"
                    if ViewingGroupedQuakes
                    {
                        CellContents = GroupData[row].Code
                    }
                    else
                    {
                        CellContents = AllQuakes[row].Code
                    }
                    CellToolTip = CellContents
                }
                if tableColumn == tableView.tableColumns[2]
                {
                    CellIdentifier = "LocationColumn"
                    if ViewingGroupedQuakes
                    {
                        CellContents = GroupData[row].Place
                    }
                    else
                    {
                        CellContents = AllQuakes[row].Place
                    }
                    CellToolTip = CellContents
                }
                if tableColumn == tableView.tableColumns[3]
                {
                    CellIdentifier = "MagnitudeColumn"
                    if ViewingGroupedQuakes
                    {
                        CellContents = "\(GroupData[row].Magnitude)"
                    }
                    else
                    {
                        CellContents = "\(AllQuakes[row].Magnitude)"
                    }
                    RightJustify = true
                }
                if tableColumn == tableView.tableColumns[4]
                {
                    CellIdentifier = "DateColumn"
                    var Raw = ""
                    if ViewingGroupedQuakes
                    {
                        Raw = GroupData[row].Time.PrettyDateTime()
                    }
                    else
                    {
                        Raw = AllQuakes[row].Time.PrettyDateTime()
                    }
                    let Parts = Raw.split(separator: "+", omittingEmptySubsequences: true)
                    let Useful = String(Parts[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                    CellContents = Useful
                    CellToolTip = CellContents
                }
                if tableColumn == tableView.tableColumns[5]
                {
                    CellIdentifier = "CoordinateColumn"
                    if DoDecorateCoordinates
                    {
                        var Latitude: Double = 0.0
                        var Longitude: Double = 0.0
                        if ViewingGroupedQuakes
                        {
                            Latitude = GroupData[row].Latitude.RoundedTo(3)
                            Longitude = GroupData[row].Longitude.RoundedTo(3)
                        }
                        else
                        {
                            Latitude = AllQuakes[row].Latitude.RoundedTo(3)
                            Longitude = AllQuakes[row].Longitude.RoundedTo(3)
                        }
                        let LatIndicator = Latitude >= 0.0 ? "N" : "S"
                        let LonIndicator = Longitude < 0.0 ? "W" : "E"
                        Latitude = abs(Latitude)
                        Longitude = abs(Longitude)
                        CellContents = "\(Latitude)\(LatIndicator)\t\t\(Longitude)\(LonIndicator)"
                    }
                    else
                    {
                        if ViewingGroupedQuakes
                        {
                            CellContents = "\(GroupData[row].Latitude.RoundedTo(3))\t\t\(GroupData[row].Longitude.RoundedTo(3))"
                        }
                        else
                        {
                            CellContents = "\(AllQuakes[row].Latitude.RoundedTo(3))\t\t\(AllQuakes[row].Longitude.RoundedTo(3))"
                        }
                    }
                    CellToolTip = CellContents
                }
                
            default:
                return nil
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        if IsEnabled
        {
            Cell?.textField?.textColor = NSColor.black
        }
        else
        {
            Cell?.textField?.textColor = NSColor.systemGray
        }
        if RightJustify
        {
            Cell?.textField?.alignment = .right
        }
        else
        {
            Cell?.textField?.alignment = .left
        }
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
                GroupIndex = 1
                if ViewingGroupedQuakes
                {
                    if CurrentParent < 0
                    {
                        return
                    }
                    let Seconds = Double(AgeFilterValue(From: GroupAgeFilter))
                    GroupData.removeAll()
                    if ParentData[CurrentParent].IsCluster
                    {
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
                        }
                    }
                }
                else
                {
                    let Seconds = Double(AgeFilterValue(From: GroupAgeFilter))
                    AllQuakes.removeAll()
                    for Quake in SourceAllQuakes
                    {
                        let IsInAgeRange = Quake.GetAge() <= Seconds
                        let IsInMagRange = Quake.Magnitude >= Double(Settings.GetInt(.GroupEarthquakeDisplayMagnitude, IfZero: 4))
                        if IsInAgeRange && IsInMagRange
                        {
                            AllQuakes.append(Quake)
                        }
                    }
                }
                GroupTable.reloadData()
                
            default:
                return
        }
    }
    
    //https://www.raywenderlich.com/830-macos-nstableview-tutorial
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor])
    {
        guard let SortDescriptor = tableView.sortDescriptors.first else
        {
            return
        }
        switch tableView
        {
            case ParentTable:
                if let Order = ParentTableDescriptors(rawValue: SortDescriptor.key!)
                {
                    SortParentTable(By: Order, Ascending: SortDescriptor.ascending)
                }
                
            case GroupTable:
                if let Order = GroupTableDescriptors(rawValue: SortDescriptor.key!)
                {
                    SortGroupedTable(By: Order, Ascending: SortDescriptor.ascending)
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
                    UpdateTable(GroupTable)
                    
                case GroupTable:
                    break
                    
                default:
                    return
            }
        }
    }
    
    @IBAction func HandleRefreshButtonPressed(_ sender: Any)
    {
        RoundTextView.RotateClockwise = false
        RoundTextView.TextFont = NSFont.boldSystemFont(ofSize: 80.0)
        RoundTextView.TextRadius = 7.0
        RoundTextView.RotationOffset = 0.33
        RoundTextView.AnimationDuration = 0.01
        RoundTextView.ShowText("Please Wait")
        RoundTextView.Show()
        
        USGSSource?.ForceFetch()
    }
    
    func DoSortParentEarthquakes()
    {
        if let Field = LastParentSortField
        {
            switch Field
            {
                case .Count:
                    if LastParentSortWasAscending
                    {
                        ParentData.sort
                        {
                            $0.ClusterCount < $1.ClusterCount
                        }
                    }
                    else
                    {
                        ParentData.sort
                        {
                            $0.ClusterCount > $1.ClusterCount
                        }
                    }
                    
                case .Date:
                    if LastParentSortWasAscending
                    {
                        ParentData.sort
                        {
                            $0.Time < $1.Time
                        }
                    }
                    else
                    {
                        ParentData.sort
                        {
                            $0.Time > $1.Time
                        }
                    }
                    
                case .Magnitude:
                    if LastParentSortWasAscending
                    {
                        ParentData.sort
                        {
                            $0.Magnitude < $1.Magnitude
                        }
                    }
                    else
                    {
                        ParentData.sort
                        {
                            $0.Magnitude > $1.Magnitude
                        }
                    }
            }
        }
    }
    
    var LastParentSortField: ParentTableDescriptors? = nil
    var LastParentSortWasAscending: Bool = true
    
    func DoSortGroupedEarthquakes()
    {
        if let Field = LastGroupedSortField
        {
            switch Field
            {
                case .Code:
                    if LastGroupedSortWasAscending
                    {
                        if ViewingGroupedQuakes
                        {
                            GroupData.sort
                            {
                                $0.Code < $1.Code
                            }
                        }
                        else
                        {
                            AllQuakes.sort
                            {
                                $0.Code < $1.Code
                            }
                        }
                    }
                    else
                    {
                        if ViewingGroupedQuakes
                        {
                            GroupData.sort
                            {
                                $0.Code > $1.Code
                            }
                        }
                        else
                        {
                            AllQuakes.sort
                            {
                                $0.Code > $1.Code
                            }
                        }
                    }
                    
                case .Date:
                    if LastGroupedSortWasAscending
                    {
                        if ViewingGroupedQuakes
                        {
                            GroupData.sort
                            {
                                $0.Time < $1.Time
                            }
                        }
                        else
                        {
                            AllQuakes.sort
                            {
                                $0.Time < $1.Time
                            }
                        }
                    }
                    else
                    {
                        if ViewingGroupedQuakes
                        {
                            GroupData.sort
                            {
                                $0.Time > $1.Time
                            }
                        }
                        else
                        {
                            AllQuakes.sort
                            {
                                $0.Time > $1.Time
                            }
                        }
                    }
                    
                case .Location:
                    if LastGroupedSortWasAscending
                    {
                        if ViewingGroupedQuakes
                        {
                            GroupData.sort
                            {
                                $0.Place < $1.Place
                            }
                        }
                        else
                        {
                            AllQuakes.sort
                            {
                                $0.Place < $1.Place
                            }
                        }
                    }
                    else
                    {
                        if ViewingGroupedQuakes
                        {
                            GroupData.sort
                            {
                                $0.Place > $1.Place
                            }
                        }
                        else
                        {
                            AllQuakes.sort
                            {
                                $0.Place > $1.Place
                            }
                        }
                    }
                    
                case .Magnitude:
                    if LastGroupedSortWasAscending
                    {
                        if ViewingGroupedQuakes
                        {
                            GroupData.sort
                            {
                                $0.Magnitude < $1.Magnitude
                            }
                        }
                        else
                        {
                            AllQuakes.sort
                            {
                                $0.Magnitude < $1.Magnitude
                            }
                        }
                    }
                    else
                    {
                        if ViewingGroupedQuakes
                        {
                            GroupData.sort
                            {
                                $0.Magnitude > $1.Magnitude
                            }
                        }
                        else
                        {
                            AllQuakes.sort
                            {
                                $0.Magnitude > $1.Magnitude
                            }
                        }
                    }
            }
        }
    }
    
    var LastGroupedSortField: GroupTableDescriptors? = nil
    var LastGroupedSortWasAscending: Bool = true
    
    func SortParentTable(By: ParentTableDescriptors, Ascending: Bool)
    {
        LastParentSortWasAscending = Ascending
        LastParentSortField = By
        DoSortParentEarthquakes()
        ParentTable.reloadData()
    }
    
    func SortGroupedTable(By: GroupTableDescriptors, Ascending: Bool)
    {
        LastGroupedSortWasAscending = Ascending
        LastGroupedSortField = By
        DoSortGroupedEarthquakes()
        GroupTable.reloadData()
    }
    
    var GroupData = [Earthquake]()
    var DoDecorateCoordinates: Bool = false
    var USGSSource: USGS? = nil
    var ParentData = [Earthquake]()
    
    var ViewingGroupedQuakes = true
    
    func SetTextState(To Enabled: Bool, Text: NSTextField)
    {
        Text.isEnabled = Enabled
        Text.textColor = Enabled ? NSColor.black : NSColor.systemGray
    }
    
    func UpdateView(AsGrouped: Bool = true)
    {
        ViewingGroupedQuakes = AsGrouped
        SetTextState(To: AsGrouped, Text: ParentQuakeLabel)
        SetTextState(To: AsGrouped, Text: ParentAgeFilterLabel)
        SetTextState(To: AsGrouped, Text: ParentMagnitudeFilterLabel)
        if AsGrouped
        {
            ChildQuakeLabel.stringValue = "Earthquakes in Group"
            ParentTable.isEnabled = true
            ParentMagnitudeFilter.isEnabled = true
            ParentAgeFilter.isEnabled = true
        }
        else
        {
            ChildQuakeLabel.stringValue = "All Earthquakes"
            ParentTable.isEnabled = false
            ParentMagnitudeFilter.isEnabled = false
            ParentAgeFilter.isEnabled = false
        }
        ParentTable.reloadData()
        GroupTable.reloadData()
    }
    
    @IBAction func HandleQuakeTypeSegmentChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            UpdateView(AsGrouped: Segment.selectedSegment == 0)
        }
    }
    
    @IBOutlet weak var ParentMagnitudeFilterLabel: NSTextField!
    @IBOutlet weak var ParentAgeFilterLabel: NSTextField!
    @IBOutlet weak var ChildQuakeLabel: NSTextField!
    @IBOutlet weak var ParentQuakeLabel: NSTextField!
    @IBOutlet weak var QuakeTypeSegment: NSSegmentedControl!
    @IBOutlet weak var RefreshButton: NSButton!
    @IBOutlet weak var RoundTextView: RoundTextIndicator!
    @IBOutlet weak var DecorateButton: NSButton!
    @IBOutlet weak var ParentMagnitudeFilter: NSComboBox!
    @IBOutlet weak var ParentAgeFilter: NSComboBox!
    @IBOutlet weak var GroupMagnitudeFilter: NSComboBox!
    @IBOutlet weak var GroupAgeFilter: NSComboBox!
    @IBOutlet weak var ParentTable: NSTableView!
    @IBOutlet weak var GroupTable: NSTableView!
}


enum ParentTableDescriptors: String
{
    case Date = "Date"
    case Magnitude = "Magnitude"
    case Count = "Count"
}

enum GroupTableDescriptors: String
{
    case Code = "Code"
    case Location = "Location"
    case Magnitude = "Magnitude"
    case Date = "Date"
}
