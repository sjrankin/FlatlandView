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
                             AsynchronousDataProtocol, WindowManagement, NSWindowDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let _ = Settings.GetInt(.EarthquakeDisplayMagnitude, IfZero: 4)
        EqTable.tableColumns[2].sortDescriptorPrototype = LocationDescriptor
        EqTable.tableColumns[3].sortDescriptorPrototype = MagnitudeDescriptor
        EqTable.tableColumns[4].sortDescriptorPrototype = CountDescriptor
        EqTable.tableColumns[5].sortDescriptorPrototype = DateDescriptor
        USGSSource = USGS()
        USGSSource?.Delegate = self
        USGSSource?.GetEarthquakes(Every: 60.0)
        EqTable.doubleAction = #selector(HandleDoubleClick)
        ProgressRing.startAnimation(self)
        let ColorFilter = CIFilter(name: "CIFalseColor")
        ColorFilter?.setDefaults()
        ColorFilter?.setValue(CIColor(cgColor: NSColor.systemBlue.cgColor), forKey: "inputColor0")
        ColorFilter?.setValue(CIColor(cgColor: NSColor.black.cgColor), forKey: "inputColor1")
        ProgressRing.contentFilters = [ColorFilter!]
        DoDecorateCoordinates = Settings.GetBool(.DecorateEarthquakeCoordinates)
        DecorateCheck.state = DoDecorateCoordinates ? .on : .off
    }
    
    override func viewDidAppear()
    {
        self.view.window?.delegate = self
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
            if Index < 0
            {
                return
            }
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
            let IsInMagRange = Quake.GreatestMagnitude >= Double(Settings.GetInt(.EarthquakeDisplayMagnitude, IfZero: 4))
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
            CellContents = "\(EarthquakeList[row].GreatestMagnitude)"
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
            var Contents = ""
            if DoDecorateCoordinates
            {
                var Latitude = EarthquakeList[row].Latitude.RoundedTo(3)
                var Longitude = EarthquakeList[row].Longitude.RoundedTo(3)
                let LatIndicator = Latitude >= 0.0 ? "N" : "S"
                let LonIndicator = Longitude < 0.0 ? "W" : "E"
                Latitude = abs(Latitude)
                Longitude = abs(Longitude)
                Contents = "\(Latitude)\(LatIndicator)\t\t\(Longitude)\(LonIndicator)"
            }
            else
            {
                Contents = "\(EarthquakeList[row].Latitude.RoundedTo(3))\t\t\(EarthquakeList[row].Longitude.RoundedTo(3))"
            }
            CellContents = Contents
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
    
    func LoadData(DataType: AsynchronousDataCategories, Raw: Any)
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
    
    func AsynchronousDataAvailable(CategoryType: AsynchronousDataCategories, Actual: Any?)
    {
        ProgressRing.stopAnimation(self)
        if Actual != nil
        {
            LoadData(DataType: CategoryType, Raw: Actual!)
            DoSortEarthquakes()
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
        }
    }
    
    func DoSortEarthquakes()
    {
        if let Field = LastSortField
        {
            switch Field
            {
                case .Location:
                    if LastSortWasAscending
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
                    
                case .Date:
                    if LastSortWasAscending
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
                    
                case .Magnitude:
                    if LastSortWasAscending
                    {
                        EarthquakeList.sort
                        {
                            $0.GreatestMagnitude < $1.GreatestMagnitude
                        }
                    }
                    else
                    {
                        EarthquakeList.sort
                        {
                            $0.GreatestMagnitude > $1.GreatestMagnitude
                        }
                    }
                    
                case .Count:
                    if LastSortWasAscending
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
    }
    
    var LastSortField: EarthquakeDescriptors? = nil
    var LastSortWasAscending: Bool = true
    
    func SortEarthquakes(By: EarthquakeDescriptors, Ascending: Bool)
    {
        LastSortField = By
        LastSortWasAscending = Ascending
        DoSortEarthquakes()
        EqTable.reloadData()
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
    
    @IBAction func HandleDecorateCheckChanged(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            DoDecorateCoordinates = Button.state == .on ? true : false
            EqTable.reloadData()
            Settings.SetBool(.DecorateEarthquakeCoordinates, DoDecorateCoordinates)
        }
    }
    
    var DoDecorateCoordinates: Bool = false
    
    func HandleNewWindowSize()
    {
        DoSortEarthquakes()
        EqTable.reloadData()
    }
    
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize
    {
        return frameSize
    }
    
    func windowDidResize(_ notification: Notification)
    {
        HandleNewWindowSize()
    }
    
    @IBOutlet weak var DecorateCheck: NSButton!
    @IBOutlet weak var ProgressRing: NSProgressIndicator!
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
    
    func MainClosing()
    {
        self.view.window?.close()
    }
}
