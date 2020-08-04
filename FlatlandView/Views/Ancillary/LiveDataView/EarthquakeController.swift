//
//  EarthquakeController.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class EarthquakeController: NSViewController, NSTableViewDelegate, NSTableViewDataSource,
                             AsynchronousDataProtocol
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let _ = Settings.GetInt(.EarthquakeDisplayMagnitude, IfZero: 4)
        EqTable.tableColumns[1].sortDescriptorPrototype = LocationDescriptor
        EqTable.tableColumns[2].sortDescriptorPrototype = MagnitudeDescriptor
        EqTable.tableColumns[3].sortDescriptorPrototype = CountDescriptor
        EqTable.tableColumns[4].sortDescriptorPrototype = DateDescriptor
        USGSSource = USGS()
        USGSSource?.Delegate = self
        USGSSource?.GetEarthquakes(Every: 60.0)
        EqTable.doubleAction = #selector(HandleDoubleClick)
    }
    
    override func viewDidLayout()
    {
        UpdateTable()
        
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
        MagCombo.removeAllItems()
        for Mag in stride(from: 10, through: 4, by: -1)
        {
            MagCombo.addItem(withObjectValue: "\(Mag)")
        }
        let DisplayMag = Settings.GetInt(.EarthquakeDisplayMagnitude, IfZero: 4)
        MagCombo.selectItem(withObjectValue: "\(DisplayMag)")
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
    var EarthquakeList = [Earthquake]()
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
    
    func UpdateTable()
    {
        let SecondsFilter = Double(AgeFilterValue())
        EarthquakeList.removeAll()
        for Quake in SourceData
        {
            let IsInAgeRange = Quake.GetAge() <= SecondsFilter
            let IsInMagRange = Quake.Magnitude >= Double(Settings.GetInt(.EarthquakeDisplayMagnitude, IfZero: 4))
            if IsInAgeRange && IsInMagRange
            {
                EarthquakeList.append(Quake)
            }
        }
        EarthquakeList.sort(by: {$0.GetAge() < $1.GetAge()})
        EqIndex = 1
        EqTable.reloadData()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        var CellToolTip: String? = nil
        
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
            CellToolTip = EarthquakeList[row].Place
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
        if let ToolTip = CellToolTip
        {
            Cell?.toolTip = ToolTip
        }
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
    
    func LoadData(DataType: AsynchronousDataTypes, Raw: Any)
    {
        switch DataType
        {
            case .Earthquakes:
                if let RawEarthquakes = Raw as? [Earthquake]
                {
                    EarthquakeList = RawEarthquakes
                    SourceData = EarthquakeList
                    UpdateTable()
                }
                
            default:
                break
        }
    }
    
    var SourceData = [Earthquake]()
    
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
            UpdateTable()
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
    
    @IBAction func HandleAgeComboChanged(_ sender: Any)
    {
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
    
    @IBAction func HandleMagComboChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            if let Raw = Combo.objectValueOfSelectedItem as? String
            {
                if let Mag = Int(Raw)
                {
                    if Mag >= 4 && Mag <= 10
                    {
                        Settings.SetInt(.EarthquakeDisplayMagnitude, Mag)
                        UpdateTable()
                    }
                }
            }
        }
    }
    
    @IBOutlet weak var MagCombo: NSComboBox!
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
