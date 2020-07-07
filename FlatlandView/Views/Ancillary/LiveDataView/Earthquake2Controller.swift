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
        #if true
        UpdateTable()
        #else
        EqIndex = 1
        EqTable.reloadData()
        #endif
        USGSSource = USGS()
        USGSSource?.Delegate = self
        USGSSource?.GetEarthquakes(Every: 60.0)
    }
    
    override func viewDidLayout()
    {
        let Window = view.window
        if let WindowController = Window?.windowController as? Earthquake2Window
        {
            let ListStyle = Settings.GetEnum(ForKey: .EarthquakeListStyle, EnumType: EarthquakeListStyles.self, Default: .Individual)
            if let Index = [EarthquakeListStyles.Clustered, EarthquakeListStyles.Individual].firstIndex(of: ListStyle)
            {
                WindowController.ListSegment.selectedSegment = Index
            }
            else
            {
                WindowController.ListSegment.selectedSegment = 0
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
    
    func UpdateTable()
    {
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
            #if true
            CellContents = "\(row + 1)"
            #else
            CellContents = "\(EqIndex)"
            EqIndex = EqIndex + 1
            #endif
        }
        if tableColumn == tableView.tableColumns[1]
        {
            CellIdentifier = "LocationColumn"
            CellContents = EarthquakeList[row].Place
        }
        if tableColumn == tableView.tableColumns[2]
        {
            CellIdentifier = "MagnitudeColumn"
            CellContents = "\(EarthquakeList[row].Magnitude)"
        }
        if tableColumn == tableView.tableColumns[3]
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
        if tableColumn == tableView.tableColumns[4]
        {
            CellIdentifier = "DateColumn"
            CellContents = EarthquakeList[row].Time.PrettyDateTime()
        }
        if tableColumn == tableView.tableColumns[5]
        {
            CellIdentifier = "CoordinatesColumn"
            CellContents = "\(EarthquakeList[row].Latitude.RoundedTo(3)), \(EarthquakeList[row].Longitude.RoundedTo(3))"
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    func SetEarthquakeType(_ List: [Earthquake2]) -> [Earthquake2]
    {
        if Settings.GetEnum(ForKey: .EarthquakeListStyle, EnumType: EarthquakeListStyles.self, Default: .Individual) == .Individual
        {
            return Earthquake2.FlatList(List)
        }
        else
        {
            return Earthquake2.Combined(List)
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
                    #if true
                    UpdateTable()
                    #else
                    EqIndex = 1
                    EqTable.reloadData()
                    #endif
                }
                
            default:
                break
        }
    }
    
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
//            EarthquakeList = SetEarthquakeType(EarthquakeList)
            #if true
            UpdateTable()
            #else
            EqIndex = 1
            EqTable.reloadData()
            #endif
        }
    }
    
    let LocationDescriptor = NSSortDescriptor(key: EarthquakeDescriptors.Location.rawValue, ascending: true)
    let MagnitudeDescriptor = NSSortDescriptor(key: EarthquakeDescriptors.Magnitude.rawValue, ascending: false)
    let DateDescriptor = NSSortDescriptor(key: EarthquakeDescriptors.Date.rawValue, ascending: false)
    let CountDescriptor = NSSortDescriptor(key: EarthquakeDescriptors.Count.rawValue, ascending: false)
    @IBOutlet weak var EqTable: NSTableView!
    
    enum EarthquakeDescriptors: String
    {
        case Location = "Location"
        case Magnitude = "Magnitude"
        case Date = "Date"
        case Count = "Count"
    }
}
