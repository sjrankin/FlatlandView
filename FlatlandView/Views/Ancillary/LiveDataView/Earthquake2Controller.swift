//
//  Earthquake2Controller.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class Earthquake2Controller: NSViewController, NSTableViewDelegate, NSTableViewDataSource,
                             AsynchronousDataProtocol
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        EqTable.tableColumns[1].sortDescriptorPrototype = LocationDescriptor
        EqTable.tableColumns[2].sortDescriptorPrototype = MagnitudeDescriptor
        EqTable.tableColumns[3].sortDescriptorPrototype = CountDescriptor
        EqTable.tableColumns[4].sortDescriptorPrototype = DateDescriptor
        //UpdateTable()
        USGSSource = USGS()
        USGSSource?.Delegate = self
        USGSSource?.GetEarthquakes(Every: 60.0)
        
        EqTable.doubleAction = #selector(HandleDoubleClick)
    }
    
    override func viewDidLayout()
    {
        let Window = view.window
        if let WindowController = Window?.windowController as? Earthquake2Window
        {
            UpdateTable()
            let ListStyle = Settings.GetEnum(ForKey: .EarthquakeListStyle, EnumType: EarthquakeListStyles.self, Default: .Individual)
            if let Index = [EarthquakeListStyles.Clustered, EarthquakeListStyles.Individual].firstIndex(of: ListStyle)
            {
                WindowController.ListSegment.selectedSegment = Index
            }
            else
            {
                WindowController.ListSegment.selectedSegment = 0
            }
            
            AgeCombo.removeAllItems()
            for Age in EarthquakeAges.allCases
            {
                AgeCombo.addItem(withObjectValue: Age.rawValue)
            }
            let PreviousAge = Settings.GetEnum(ForKey: .EarthquakeListAge, EnumType: EarthquakeAges.self, Default: .Age5)
            if let Index = EarthquakeAges.allCases.firstIndex(of: PreviousAge)
            {
                AgeCombo.selectItem(at: Index)
            }
            else
            {
                AgeCombo.selectItem(at: EarthquakeAges.allCases.count - 1)
            }
        }
    }
    
    @objc func HandleDoubleClick(_ sender: Any)
    {
        if let Table = sender as? NSTableView
        {
            let Index = Table.selectedRow
            let Storyboard = NSStoryboard(name: "LiveData", bundle: nil)
            if let WindowController = Storyboard.instantiateController(withIdentifier: "EarthquakeDetailWindow") as? EarthquakeDetailWindow
            {
                let Window = WindowController.window
                if let Controller = Window?.contentViewController as? EarthquakeDetailController
                {
                    Controller.DisplayEarthquake(EarthquakeList[Index])
                }
                self.view.window?.beginSheet(Window!, completionHandler: nil)
            }
        }
    }
    
    var USGSSource: USGS? = nil
    var EarthquakeList = [Earthquake2]()
    var EqIndex = 1
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return EarthquakeList.count
    }
    
    func AgeFilterValue() -> Int
    {
        if let Current = AgeCombo.objectValueOfSelectedItem as? String
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
    
    func CombineQuakes()
    {
        var Used = [String]()
        for Quake in EarthquakeList
        {
            for Other in SourceData
            {
                if Used.contains(Other.Code)
                {
                    continue
                }
                let Distance = Quake.DistanceTo(Other)
                //print("Distance = \(Distance)")
                if Distance < 500
                {
                    Quake.AddRelated(Other)
                    Used.append(Other.Code)
                }
            }
        }
    }
    
    func UpdateTable()
    {
        let SecondsFilter = Double(AgeFilterValue())
        print("Seconds Filter=\(SecondsFilter)")
        EarthquakeList.removeAll()
        for Quake in SourceData
        {
            if Quake.GetAge() <= SecondsFilter
            {
                EarthquakeList.append(Quake)
            }
        }
        EarthquakeList.sort(by: {$0.GetAge() < $1.GetAge()})
        CombineQuakes()
        EqIndex = 1
        EqTable.reloadData()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "IndexColumn"
            CellContents = "\(row + 1)"
        }
        if tableColumn == tableView.tableColumns[1]
        {
            CellIdentifier = "CodeColumn"
            CellContents = EarthquakeList[row].Code
        }
        if tableColumn == tableView.tableColumns[2]
        {
            CellIdentifier = "LocationColumn"
            CellContents = EarthquakeList[row].Place
        }
        if tableColumn == tableView.tableColumns[3]
        {
            CellIdentifier = "MagnitudeColumn"
            CellContents = "\(EarthquakeList[row].Magnitude)"
        }
        if tableColumn == tableView.tableColumns[4]
        {
            CellIdentifier = "CountColumn"
            if EarthquakeList[row].ClusterCount > 0
            {
                CellContents = "\(EarthquakeList[row].ClusterCount)"
            }
            else
            {
                CellContents = "Ø"
            }
        }
        if tableColumn == tableView.tableColumns[5]
        {
            CellIdentifier = "DateColumn"
            CellContents = EarthquakeList[row].Time.PrettyDateTime()
        }
        if tableColumn == tableView.tableColumns[6]
        {
            CellIdentifier = "CoordinatesColumn"
            CellContents = "\(EarthquakeList[row].Latitude.RoundedTo(3)), \(EarthquakeList[row].Longitude.RoundedTo(3))"
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    @IBAction func HandleEarthquakeClicked(_ sender: Any)
    {
        if let Table = sender as? NSTableView
        {
            let Index = Table.selectedRow
            if Index > -1
            {
                print("Selected \(EarthquakeList[Index].Place)")
            }
        }
    }
    
    func SetEarthquakeType(_ List: [Earthquake2]) -> [Earthquake2]
    {
        if Settings.GetEnum(ForKey: .EarthquakeListStyle, EnumType: EarthquakeListStyles.self, Default: .Individual) == .Individual
        {
            return USGS.CombineEarthquakes(List)
        }
        else
        {
            return USGS.FlattenEarthquakes(List)
        }
    }
    
    func LoadData(DataType: AsynchronousDataTypes, Raw: Any)
    {
        switch DataType
        {
            case .Earthquakes2:
                if let RawEarthquakes = Raw as? [Earthquake2]
                {
                    EarthquakeList = SetEarthquakeType(RawEarthquakes)
                    SourceData = EarthquakeList
                    UpdateTable()
                }
                
            default:
                break
        }
    }
    
    var SourceData = [Earthquake2]()
    
    func AsynchronousDataAvailable(DataType: AsynchronousDataTypes, Actual: Any?)
    {
        if Actual != nil
        {
            LoadData(DataType: DataType, Raw: Actual!)
        }
    }
    
    //https://www.raywenderlich.com/830-macos-nstableview-tutorial
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor])
    {
        guard let SortDescriptor = tableView.sortDescriptors.first else
        {
            return
        }
        if let Order = EarthquakeDescriptors(rawValue: SortDescriptor.key!)
        {
            SortEarthquakes(By: Order, Ascending: SortDescriptor.ascending)
            #if true
            UpdateTable()
            #else
            EqIndex = 1
            EqTable.reloadData()
            #endif
        }
    }
    
    func SortEarthquakes(By: EarthquakeDescriptors, Ascending: Bool)
    {
        switch By
        {
            case .Location:
                if Ascending
                {
                    EarthquakeList.sort
                    {
                        $0.Place < $1.Place
                    }
                }
                else
                {
                    EarthquakeList.sort
                    {
                        $0.Place > $1.Place
                    }
                }
                
            case .Magnitude:
                if Ascending
                {
                    EarthquakeList.sort
                    {
                        $0.Magnitude < $1.Magnitude
                    }
                }
                else
                {
                    EarthquakeList.sort
                    {
                        $0.Magnitude > $1.Magnitude
                    }
                }
                
            case .Date:
                if Ascending
                {
                    EarthquakeList.sort
                    {
                        $0.Time < $1.Time
                    }
                }
                else
                {
                    EarthquakeList.sort
                    {
                        $0.Time > $1.Time
                    }
                }
                
            case .Count:
                if Ascending
                {
                    EarthquakeList.sort
                    {
                        $0.ClusterCount < $1.ClusterCount
                    }
                }
                else
                {
                    EarthquakeList.sort
                    {
                        $0.ClusterCount > $1.ClusterCount
                    }
                }
        }
    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        if let Frame = self.view.window?.frame
        {
            Settings.SetRect(.EarthquakeViewWindowFrame, Frame)
        }
        self.view.window?.close()
    }
    
    @IBAction func HandleListTypeChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            if Segment.selectedSegment > 1
            {
                fatalError("Unexpected segment index: \(Segment.selectedSegment)")
            }
            let NewStyle = [EarthquakeListStyles.Clustered, EarthquakeListStyles.Individual][Segment.selectedSegment]
            Settings.SetEnum(NewStyle, EnumType: EarthquakeListStyles.self, ForKey: .EarthquakeListStyle)
            if NewStyle == .Clustered
            {
                EarthquakeList = USGS.CombineEarthquakes(EarthquakeList)
            }
            else
            {
                EarthquakeList = USGS.FlattenEarthquakes(EarthquakeList)
            }
            UpdateTable()
        }
    }
    
    @IBAction func HandleAgeComboChanged(_ sender: Any)
    {
        print("At HandleAgeComboChanged")
        if let Combo = sender as? NSComboBox
        {
            if let Raw = Combo.objectValueOfSelectedItem as? String
            {
                if let MagAge = EarthquakeAges(rawValue: Raw)
                {
                    Settings.SetEnum(MagAge, EnumType: EarthquakeAges.self, ForKey: .EarthquakeListAge)
                }
            }
            UpdateTable()
        }
    }
    
    let LocationDescriptor = NSSortDescriptor(key: EarthquakeDescriptors.Location.rawValue, ascending: true)
    let MagnitudeDescriptor = NSSortDescriptor(key: EarthquakeDescriptors.Magnitude.rawValue, ascending: false)
    let DateDescriptor = NSSortDescriptor(key: EarthquakeDescriptors.Date.rawValue, ascending: false)
    let CountDescriptor = NSSortDescriptor(key: EarthquakeDescriptors.Count.rawValue, ascending: false)
    
    @IBOutlet weak var EqTable: NSTableView!
    @IBOutlet weak var AgeCombo: NSComboBox!
    
    enum EarthquakeDescriptors: String
    {
        case Location = "Location"
        case Magnitude = "Magnitude"
        case Date = "Date"
        case Count = "Count"
    }
}
