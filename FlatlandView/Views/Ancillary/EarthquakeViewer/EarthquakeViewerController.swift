//
//  EarthquakeViewerController.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/31/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class EarthquakeViewerController: NSViewController, NSTableViewDelegate, NSTableViewDataSource,
                                  NSWindowDelegate, AsynchronousDataProtocol, WindowManagement,
                                  NSMenuItemValidation
{
    var ParentWindow: EarthquakeViewerWindow!
    public weak var MainDelegate: MainProtocol? = nil
    {
        didSet
        {
            if !LoadedInitialQuakes
            {
                LoadedInitialQuakes = true
                AllQuakes = (MainDelegate?.GetEarthquakes())!
                LoadData(DataType: .Earthquakes, Raw: AllQuakes)
            }
        }
    }
    
    var LoadedInitialQuakes = false
    
    override func viewDidLoad()
    {
        USGSSource = USGS()
        USGSSource?.Delegate = self
        
        QuakeTable.doubleAction = #selector(HandleDoubleClick)
        
        QuakeTable.tableColumns[0].sortDescriptorPrototype = CodeDescriptor
        QuakeTable.tableColumns[2].sortDescriptorPrototype = MagnitudeDescriptor
        QuakeTable.tableColumns[3].sortDescriptorPrototype = DateDescriptor
        QuakeTable.tableColumns[5].sortDescriptorPrototype = RegionDescriptor
        
        ShowDistance = Settings.GetBool(.QuakeRegionEnable)
        
        HandleDecorateCoordinatesChanged(true)
    }
    
    let CodeDescriptor = NSSortDescriptor(key: ColumnDescriptors.Code.rawValue, ascending: true)
    let MagnitudeDescriptor = NSSortDescriptor(key: ColumnDescriptors.Magnitude.rawValue, ascending: true)
    let DateDescriptor = NSSortDescriptor(key: ColumnDescriptors.Date.rawValue, ascending: true)
    let RegionDescriptor = NSSortDescriptor(key: ColumnDescriptors.Region.rawValue, ascending: true)
    var AlreadyLaidOut: Bool = false
    
    override func viewDidLayout()
    {
        if !AlreadyLaidOut
        {
            AlreadyLaidOut = true
            if let Win = self.view.window?.windowController as? EarthquakeViewerWindow
            {
                ParentWindow = Win
            }
            else
            {
                fatalError("Error obtaining window in \(#function)")
            }
            AgeFilterCombo.removeAllItems()
            for Age in EarthquakeAges.allCases
            {
                AgeFilterCombo.addItem(withObjectValue: Age.rawValue)
            }
            let Age = Settings.GetEnum(ForKey: .EarthquakeListAge, EnumType: EarthquakeAges.self, Default: .Age5)
            if let Index = EarthquakeAges.allCases.firstIndex(of: Age)
            {
                FilterAge = Index
                AgeFilterCombo.selectItem(at: Index)
            }
            MagFilterCombo.removeAllItems()
            for Mag in stride(from: 10, through: 4, by: -1)
            {
                MagFilterCombo.addItem(withObjectValue: "\(Mag)")
            }
            FilterMag = Settings.GetInt(.EarthquakeDisplayMagnitude, IfZero: 4)
            MagFilterCombo.selectItem(withObjectValue: "\(FilterMag)")
            
            MainApp = NSApplication.shared.delegate as? AppDelegate
            if MainApp == nil
            {
                fatalError("MainApp is nil")
            }
            
            RegionCombo.removeAllItems()
            RegionCombo.addItem(withObjectValue: "All Regions")
            var RegionNames = Set<String>()
            for Region in Settings.GetEarthquakeRegions()
            {
                RegionNames.insert(Region.RegionName)
            }
            let FinalRegions = Array(RegionNames).sorted()
            for Region in FinalRegions
            {
                RegionCombo.addItem(withObjectValue: Region)
            }
            RegionCombo.selectItem(at: 0)
            
            AddMenu()
            ParentWindow.UpdateRegionalQuakeIcon(Enabled: Settings.GetBool(.QuakeRegionEnable))
            
            if let PrettyDownload = MainDelegate?.GetLastEarthquakeDownload()
            {
                let PrettyTime = PrettyDownload.PrettyDateTime()
                UpdatedLabel.stringValue = "Updated: \(PrettyTime)"
            }
            else
            {
                UpdatedLabel.stringValue = "Updated: Previously cached"
            }
            ParentWindow.HidePleaseWait()
            ParentWindow.HideNextIndicator()
            SetQRButton(With: nil)
            GetQuakes()
            RunGetQuakes()
        }
    }
    
    func RunGetQuakes()
    {
        ParentWindow.HidePleaseWait()
        GetQuakeTimer = Timer.scheduledTimer(timeInterval: 300.0,
                                             target: self,
                                             selector: #selector(GetQuakes),
                                             userInfo: nil,
                                             repeats: true)
        ParentWindow.ShowNextIndicator(For: 300.0)
    }
    
    var GetQuakeTimer: Timer? = nil
    
    @objc func GetQuakes()
    {
        ParentWindow.HideNextIndicator()
        ParentWindow.ShowPleaseWait()
        USGSSource?.ForceFetch()
    }
    
    var FilterAge: Int = 5
    var FilterMag: Int = 5
    var ShowDistance = false
    
    var MainApp: AppDelegate!
    
    func HandleRefreshPressed()
    {
        GetQuakes()
    }
    
    func HandleDecorateCoordinatesChanged(_ NewValue: Bool)
    {
        Settings.SetBool(.DecorateEarthquakeCoordinates, NewValue)
        DecorateMenuItem?.state = NewValue ? .on : .off
        UpdateTable()
    }
    
    func AgeFromAgeEnum(_ Age: EarthquakeAges) -> Int
    {
        let Raw = Age.rawValue
        let Parts = Raw.split(separator: " ", omittingEmptySubsequences: true)
        let RawNum = String(Parts[0])
        if let Final = Int(RawNum)
        {
            return Final
        }
        return 1
    }
    
    func HandleNewAgeFilter(_ Raw: String)
    {
        if let Age = EarthquakeAges(rawValue: Raw)
        {
            Settings.SetEnum(Age, EnumType: EarthquakeAges.self, ForKey: .EarthquakeListAge)
            let ActualAge = AgeFromAgeEnum(Age)
            for Item in AgeMenu!.submenu!.items
            {
                Item.state = Item.tag == ActualAge ? .on : .off
            }
            UpdateTable()
        }
    }
    
    func HandleNewMagnitudeFilter(_ Raw: String)
    {
        if let Mag = Int(Raw)
        {
            if Mag >= 4 && Mag <= 10
            {
                Settings.SetInt(.EarthquakeDisplayMagnitude, Mag)
                for Item in MagMenu!.submenu!.items
                {
                    Item.state = Item.tag == Mag ? .on : .off
                }
                UpdateTable()
            }
        }
    }
    
    func HandleNewRegionFilter(_ Raw: String)
    {
        UpdateTable()
    }
    
    // MARK: - Asynchronous data handling
    
    func LoadData(DataType: AsynchronousDataCategories, Raw: Any)
    {
        switch DataType
        {
            case .Earthquakes:
                if let RawData = Raw as? [Earthquake]
                {
                    for Quake in RawData
                    {
                        Quake.RegionName = USGS.InRegion(Quake)
                    }
                    let PrettyNow = Date().PrettyDateTime()
                    UpdatedLabel.stringValue = "Updated: \(PrettyNow)"
                    AllQuakes = RawData
                    SourceAllEarthquakes = RawData
                    Debug.Print("Received \(AllQuakes.count) earthquakes")
                    UpdateTable()
                }
                
            default:
                break
        }
    }
    
    func AsynchronousDataAvailable(CategoryType: AsynchronousDataCategories, Actual: Any?,
                                   StartTime: Double, Context: Any?)
    {
        ParentWindow.HidePleaseWait()
        if Actual != nil
        {
            ParentWindow.HidePleaseWait()
            LoadData(DataType: CategoryType, Raw: Actual!)
            RunGetQuakes()
            ParentWindow.ShowNextIndicator(For: 300.0)
        }
    }
    
    var SourceAllEarthquakes = [Earthquake]()
    var AllQuakes = [Earthquake]()
    var Filtered = [Earthquake]()
    var USGSSource: USGS? = nil
    
    // MARK: - Window management functions
    
    func MainClosing()
    {
        RemoveMenu()
        self.view.window?.close()
    }
    
    @IBAction func HandleCloseButton(_ sender: Any)
    {
        RemoveMenu()
        self.view.window?.close()
    }
    
    override func viewWillDisappear()
    {
        RemoveMenu()
    }
    
    // MARK: - Table handling
    
    func tableViewSelectionDidChange(_ notification: Notification)
    {
        let Index = QuakeTable.selectedRow
        guard Index >= 0 else
        {
            return
        }
        let Quake = Filtered[Index]
        SetQRButton(With: Quake)
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
    
    func FilterQuakeList(_ Source: [Earthquake]) -> [Earthquake]
    {
        var Results = [Earthquake]()
        let Seconds = Double(AgeFilterValue(From: AgeFilterCombo))
        for Quake in Source
        {
            let IsInAgeRange = Quake.GetAge() <= Seconds
            let IsInMagRange = Quake.Magnitude >= Double(Settings.GetInt(.EarthquakeDisplayMagnitude, IfZero: 4))
            if IsInAgeRange && IsInMagRange
            {
                Quake.ContextDistance = -1.0
                Results.append(Quake)
            }
        }
        Results.sort{$0.Magnitude > $1.Magnitude}
        return Results
    }
    
    #if false
    func FilterQuakesByRegion(_ Source: [Earthquake]) -> [Earthquake]
    {
        LinkColumn.headerCell.stringValue = "Distance"
        var Results = [Earthquake]()
        let PointLatitude = Settings.GetDoubleNil(.QuakeRegionLatitude, 0.0)
        let PointLongitude = Settings.GetDoubleNil(.QuakeRegionLongitude,  0.0)
        let MaxDistance = Settings.GetDoubleNil(.QuakeRegionRadius,  0.0)
        for Quake in Source
        {
            var Distance = Geometry.HaversineDistance(Latitude1: Quake.Latitude, Longitude1: Quake.Longitude,
                                                      Latitude2: PointLatitude!, Longitude2: PointLongitude!)
            Distance = Distance / 1000.0
            if Distance <= MaxDistance!
            {
                Quake.ContextDistance = Distance
                Results.append(Quake)
            }
        }
        Results.sort{$0.ContextDistance < $1.ContextDistance}
        return Results
    }
    #endif
    
    func UpdateTable()
    {
        Filtered.removeAll()
        Filtered = FilterQuakeList(AllQuakes)
        
        if let RegionValue = RegionCombo.objectValueOfSelectedItem as? String
        {
            if RegionValue.lowercased() != "all regions"
            {
                Filtered = Filtered.filter({$0.RegionName == RegionValue})
            }
        }
        
        FilteredQuakeLabel.stringValue = "Filtered quakes: \(Filtered.count)"
        QuakeTable.reloadData()
        if !Filtered.isEmpty
        {
            let Selected = IndexSet(integer: 0)
            QuakeTable.selectRowIndexes(Selected, byExtendingSelection: false)
            SetQRButton(With: Filtered[0])
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        switch tableView
        {
            case QuakeTable:
                return Filtered.count
                
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        var RightJustify = false
        var ToolTipText = ""
        
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "CodeColumn"
            CellContents = Filtered[row].Code
        }
        if tableColumn == tableView.tableColumns[1]
        {
            CellIdentifier = "LocationColumn"
            CellContents = Filtered[row].Place
            ToolTipText = Filtered[row].Place
        }
        if tableColumn == tableView.tableColumns[2]
        {
            CellIdentifier = "MagnitudeColumn"
            CellContents = "\(Filtered[row].Magnitude)"
            RightJustify = true
        }
        if tableColumn == tableView.tableColumns[3]
        {
            CellIdentifier = "DateColumn"
            let Raw = Filtered[row].Time.PrettyDateTime()
            CellContents = Raw
            RightJustify = false
        }
        if tableColumn == tableView.tableColumns[4]
        {
            CellIdentifier = "CoordinatesColumn"
            var Latitude = Filtered[row].Latitude
            var Longitude = Filtered[row].Longitude
            let LatIndicator = Latitude >= 0.0 ? "N" : "S"
            let LonIndicator = Longitude < 0.0 ? "W" : "E"
            Latitude = abs(Latitude)
            Longitude = abs(Longitude)
            CellContents = "  \(Latitude.RoundedTo(2, PadTo: 2))\(LatIndicator)\t\t\(Longitude.RoundedTo(2, PadTo: 2))\(LonIndicator)"
        }
        if tableColumn == tableView.tableColumns[5]
        {
            CellIdentifier = "RegionColumn"
            CellContents = Filtered[row].RegionName
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        Cell?.textField?.toolTip = ToolTipText
        if RightJustify
        {
            Cell?.textField?.alignment = .right
        }
        else
        {
            Cell?.textField?.alignment = .left
        }
        return Cell
    }
    
    @IBAction func HandleTableAction(_ sender: Any)
    {
    }
    
    @objc func HandleDoubleClick(_ sender: Any)
    {
        if let Table = sender as? NSTableView
        {
            if Table == QuakeTable
            {
                let Index = Table.selectedRow
                if Index < 0
                {
                    return
                }
                let Quake = Filtered[Index]
                let Storyboard = NSStoryboard(name: "EarthquakeData", bundle: nil)
                if let WindowController = Storyboard.instantiateController(withIdentifier: "DetailQuakeWindow") as? DetailQuakeWindow
                {
                    let Window = WindowController.window
                    if let Controller = Window?.contentViewController as? DetailQuakeController
                    {
                        Controller.SetQuake(Quake)
                        self.view.window?.beginSheet(Window!)
                    }
                }
            }
        }
    }
    
    //https://www.raywenderlich.com/830-macos-nstableview-tutorial
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor])
    {
        guard let SortDescriptor = tableView.sortDescriptors.first else
        {
            return
        }
        let SortBy = ColumnDescriptors(rawValue: SortDescriptor.key!)
        switch SortBy
        {
            case .Code:
                if SortDescriptor.ascending
                {
                    Filtered.sort{$0.Code < $1.Code}
                }
                else
                {
                    Filtered.sort{$0.Code > $1.Code}
                }
                
            case .Date:
                if SortDescriptor.ascending
                {
                    Filtered.sort{$0.Time < $1.Time}
                }
                else
                {
                    Filtered.sort{$0.Time > $1.Time}
                }
                
            case .Magnitude:
                if SortDescriptor.ascending
                {
                    Filtered.sort{$0.Magnitude < $1.Magnitude}
                }
                else
                {
                    Filtered.sort{$0.Magnitude > $1.Magnitude}
                }
                
            case .Region:
                if SortDescriptor.ascending
                {
                    Filtered.sort{$0.RegionName < $1.RegionName}
                }
                else
                {
                    Filtered.sort{$0.RegionName > $1.RegionName}
                }
                
            default:
                return
        }
        QuakeTable.reloadData()
        if !Filtered.isEmpty
        {
            let Selected = IndexSet(integer: 0)
            QuakeTable.selectRowIndexes(Selected, byExtendingSelection: false)
            SetQRButton(With: Filtered[0])
        }
    }
    
    // MARK: - Menu handling
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool
    {
        return true
    }
    
    var Inserted = false
    var AddGate: NSObject = NSObject()
    
    func AddMenu()
    {
        objc_sync_enter(AddGate)
        defer{objc_sync_exit(AddGate)}
        if Inserted
        {
            return
        }
        Inserted = true
        QuakeMenu = NSMenuItem()
        QuakeMenu?.submenu = NSMenu(title: "Earthquakes")
        RefreshMenuItem = NSMenuItem(title: "Refresh", action: #selector(DoHandleRefresh), keyEquivalent: "")
        RefreshMenuItem?.target = self
        DecorateMenuItem = NSMenuItem(title: "Decorate", action: #selector(DoHandleDecorate), keyEquivalent: "")
        DecorateMenuItem?.target = self
        DecorateMenuItem?.state = Settings.GetBool(.DecorateEarthquakeCoordinates) ? .on : .off
        RegionalMenuItem = NSMenuItem(title: "Regional Earthquakes", action: #selector(DoHandleRegionalQuakes),
                                      keyEquivalent: "")
        RegionalMenuItem?.target = self
        RegionalMenuItem?.state = Settings.GetBool(.QuakeRegionEnable) ? .on : .off
        QuakeMenu!.submenu?.items =
            [
                RefreshMenuItem!,
                DecorateMenuItem!,
                RegionalMenuItem!,
                NSMenuItem.separator(),
                MakeMagnitudeMenu(),
                MakeAgeMenu()
            ]
        NSApplication.shared.mainMenu?.insertItem(QuakeMenu!, at: 3)
    }
    
    var QuakeMenu: NSMenuItem? = nil
    
    func MakeMagnitudeMenu() -> NSMenuItem
    {
        MagMenu = NSMenuItem()
        MagMenu?.title = "Magnitude filter"
        MagMenu?.submenu = NSMenu(title: "Magnitude filter")
        let CurrentMag = Settings.GetInt(.EarthquakeDisplayMagnitude, IfZero: 4)
        for Mag in 4 ... 10
        {
            let MagItem = NSMenuItem(title: "\(Mag)", action: #selector(DoHandleMagnitude), keyEquivalent: "")
            MagItem.target = self
            MagItem.tag = Mag
            MagItem.state = Mag == CurrentMag ? .on : .off
            MagMenu!.submenu?.items.append(MagItem)
        }
        return MagMenu!
    }
    
    func MakeAgeMenu() -> NSMenuItem
    {
        AgeMenu = NSMenuItem()
        AgeMenu?.title = "Age filter"
        AgeMenu?.submenu = NSMenu(title: "Age filter")
        let CurrentAgeE = Settings.GetEnum(ForKey: .EarthquakeListAge, EnumType: EarthquakeAges.self, Default: .Age5)
        let Parts = CurrentAgeE.rawValue.split(separator: " ", omittingEmptySubsequences: true)
        let RawAge = String(Parts[0])
        var CurrentAge = 0
        if let ActualAge = Int(RawAge)
        {
            CurrentAge = ActualAge
        }
        for Age in 1 ... 30
        {
            let Plural = Age == 1 ? "" : "s"
            let AgeItem = NSMenuItem(title: "\(Age) day\(Plural)", action: #selector(DoHandleAge(_:)), keyEquivalent: "")
            AgeItem.state = Age == CurrentAge ? .on : .off
            AgeMenu!.submenu?.items.append(AgeItem)
        }
        return AgeMenu!
    }
    
    var RegionalMenuItem: NSMenuItem? = nil
    var RefreshMenuItem: NSMenuItem? = nil
    var DecorateMenuItem: NSMenuItem? = nil
    var AgeMenu: NSMenuItem? = nil
    var MagMenu: NSMenuItem? = nil
    
    var RootMenu: NSMenuItem? = nil
    
    func RemoveMenu()
    {
        if QuakeMenu == nil
        {
            return
        }
        NSApplication.shared.mainMenu?.removeItem(QuakeMenu!)
        Inserted = false
        QuakeMenu = nil
    }
    
    @objc func DoHandleRegionalQuakes(_ sender: Any)
    {
        if let MenuItem = sender as? NSMenuItem
        {
            RunRegionalQuakeDialog()
            MenuItem.state = Settings.GetBool(.QuakeRegionEnable) ? .on : .off
        }
    }
    
    @objc func DoHandleAge(_ sender: Any)
    {
        if let MenuItem = sender as? NSMenuItem
        {
            FilterAge = MenuItem.tag
            let SelIndex = AgeFilterCombo.indexOfSelectedItem
            AgeFilterCombo.deselectItem(at: SelIndex)
            AgeFilterCombo.selectItem(at: FilterAge)
            UpdateTable()
        }
    }
    
    @objc func DoHandleMagnitude(_ sender: Any)
    {
        if let MenuItem = sender as? NSMenuItem
        {
            FilterMag = MenuItem.tag
            let SelIndex = MagFilterCombo.indexOfSelectedItem
            MagFilterCombo.deselectItem(at: SelIndex)
            MagFilterCombo.selectItem(at: FilterMag)
            UpdateTable()
        }
    }
    
    @objc func DoHandleRefresh(_ sender: Any)
    {
        ParentWindow.HideNextIndicator()
        ParentWindow.ShowPleaseWait()
        USGSSource?.ForceFetch()
    }
    
    @objc func DoHandleDecorate(_ sender: Any)
    {
        let PreviousDecorate = Settings.GetBool(.DecorateEarthquakeCoordinates)
        let DoDecorate = !PreviousDecorate
        Settings.SetBool(.DecorateEarthquakeCoordinates, DoDecorate)
        UpdateTable()
    }
    
    // MARK: - Child dialogs.
    
    func RunRegionalQuakeDialog()
    {
        let Storyboard = NSStoryboard(name: "EarthquakeData", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "RegionalQuakeWindow") as? RegionalQuakeWindow
        {
            let Window = WindowController.window
            self.view.window?.beginSheet(Window!)
            {
                Result in
                switch Result
                {
                    case .OK:
                        self.ShowDistance = Settings.GetBool(.QuakeRegionEnable)
                        self.ParentWindow.UpdateRegionalQuakeIcon(Enabled: Settings.GetBool(.QuakeRegionEnable))
                        self.RegionalMenuItem?.state = Settings.GetBool(.QuakeRegionEnable) ? .on : .off
                        self.UpdateTable()
                        
                    case .cancel:
                        //Do nothing.
                        break
                        
                    default:
                        break
                }
            }
        }
    }
    
    @IBAction func HandleComboBox(_ sender: Any)
    {
        if let ComboBox = sender as? NSComboBox
        {
            if let SelectedObject = ComboBox.objectValueOfSelectedItem as? String
            {
                switch ComboBox
                {
                    case MagFilterCombo:
                        HandleNewMagnitudeFilter(SelectedObject)
                        
                    case AgeFilterCombo:
                        HandleNewAgeFilter(SelectedObject)
                        
                    case RegionCombo:
                        HandleNewRegionFilter(SelectedObject)
                        
                    default:
                        return
                }
            }
        }
    }
    
    @IBAction func HandleQRButtonClicked(_ sender: Any)
    {
        if let Quake = QuakeForButton
        {
            if let ValidURL = URL(string: Quake.EventPageURL)
            {
                NSWorkspace.shared.open(ValidURL)
            }
        }
    }
    
    func SetQRButton(With: Earthquake?)
    {
        if let Quake = With
        {
            QRButton.isEnabled = true
            QRButton.isHidden = false
            QRButtonLabel.isHidden = false
            if let QRImage = Barcodes.QRCode(With: Quake.EventPageURL, FinalSize: NSSize(width: 50, height: 50))
            {
                QRButton.image = QRImage
                QuakeForButton = Quake
                QRButton.toolTip = "Click to open a browser showing this information"
                if let Title = With?.Title
                {
                    QRButtonLabel.stringValue = Title
                }
                else
                {
                    QRButtonLabel.stringValue = "Click label for more information - opens in your browser."
                }
                QRBox.wantsLayer = true
                let Colors = Settings.GetMagnitudeColors()
                let MagRange = Utility.GetMagnitudeRange(For: Quake.Magnitude)
                var BoxColor = NSColor.clear
                for (Magnitude, Color) in Colors
                {
                    if Magnitude == MagRange
                    {
                        BoxColor = Color
                        break
                    }
                }
                QRBox.layer?.backgroundColor = BoxColor.cgColor
            }
            else
            {
                QRButton.isEnabled = false
                QRButton.isHidden = true
                QRButtonLabel.isHidden = true
            }
        }
        else
        {
            QRButton.isEnabled = false
            QRButton.isHidden = true
            QRButtonLabel.isHidden = true
        }
    }
    
    var QuakeForButton: Earthquake? = nil
    
    // MARK: - Interface builder outlets
    
    @IBOutlet weak var RegionCombo: NSComboBox!
    @IBOutlet weak var QRBox: NSBox!
    @IBOutlet weak var QRButtonLabel: NSTextField!
    @IBOutlet weak var QRButton: NSButton!
    @IBOutlet weak var UpdatedLabel: NSTextField!
    @IBOutlet weak var FilteredQuakeLabel: NSTextField!
    @IBOutlet weak var MagFilterCombo: NSComboBox!
    @IBOutlet weak var AgeFilterCombo: NSComboBox!
    @IBOutlet weak var LinkColumn: NSTableColumn!
    @IBOutlet weak var QuakeTable: NSTableView!
}

enum ColumnDescriptors: String
{
    case Date = "Date"
    case Magnitude = "Magnitude"
    case Code = "Code"
    case Region = "Region"
}
