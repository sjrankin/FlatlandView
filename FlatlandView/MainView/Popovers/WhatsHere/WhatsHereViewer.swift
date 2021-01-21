//
//  WhatsHereViewer.swift
//  Flatland
//
//  Created by Stuart Rankin on 12/13/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class WhatsHereViewer: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        NearByTable.tableColumns[0].sortDescriptorPrototype = TypeDescriptor
        NearByTable.tableColumns[1].sortDescriptorPrototype = DistDescriptor
        NearByTable.tableColumns[3].sortDescriptorPrototype = NameDescriptor
    }
    
    let TypeDescriptor = NSSortDescriptor(key: LocationDescriptors.LocationType.rawValue, ascending: true)
    let NameDescriptor = NSSortDescriptor(key: LocationDescriptors.TypeName.rawValue, ascending: true)
    let DistDescriptor = NSSortDescriptor(key: LocationDescriptors.DistanceType.rawValue, ascending: true)
    
    override func viewDidLayout()
    {
        super.viewDidLayout()
        Initialize()
    }
    
    func Initialize()
    {
        if SourceLatitude == nil || SourceLongitude == nil
        {
            CurrentLocationLabel.stringValue = ""
        }
        else
        {
            let NiceLat = Utility.PrettyLatitude(SourceLatitude!)
            let NiceLon = Utility.PrettyLongitude(SourceLongitude!)
            CurrentLocationLabel.stringValue = "\(NiceLat)\t\(NiceLon)"
        }
        let Units = Settings.GetEnum(ForKey: .InputUnit, EnumType: InputUnits.self, Default: .Kilometers)
        if Units == .Miles
        {
            DistanceCombo.removeAllItems()
            DistanceCombo.addItem(withObjectValue: "50 mi")
            DistanceCombo.addItem(withObjectValue: "100 mi")
            DistanceCombo.addItem(withObjectValue: "200 mi")
            DistanceCombo.addItem(withObjectValue: "500 mi")
            DistanceCombo.addItem(withObjectValue: "1000 mi")
        }
        DistanceCombo.selectItem(at: 0)
        CurrentDistance = 50.0
        FoundSummary.stringValue = ""
        NearByTable.reloadData()
        let DistanceHeader = Units == .Kilometers ? "Distance km" : "Distance mi"
        DistanceColumn.title = DistanceHeader
    }
    
    var CurrentDistance: Double = 0
    
    var Main: MainProtocol? = nil
    
    func SetLocation(_ Latitude: Double, _ Longitude: Double, Main: MainProtocol? = nil)
    {
        self.Main = Main
        SourceLatitude = Latitude
        SourceLongitude = Longitude
        GetNearByItems()
    }
    
    var SourceLatitude: Double? = nil
    var SourceLongitude: Double? = nil
    
    func GetNearByItems()
    {
        var DistanceToUse = CurrentDistance
        if Settings.GetEnum(ForKey: .InputUnit, EnumType: InputUnits.self, Default: .Kilometers) == .Miles
        {
            DistanceToUse = CurrentDistance * 1.6
        }
        NearTable.removeAll()
        NearTable.append((Distance: 0.0,
                          Location: GeoPoint(SourceLatitude!, SourceLongitude!),
                          Description: "Search origin",
                          LocType: .UserPoint))
        let LocationManager = Locations()
        if let MainDelegate = Main
        {
            LocationManager.Main = MainDelegate
        }
        let LookFor: [LocationTypes] = [.City, .Earthquake, .Home, .UNESCO, .UserPOI, .Region]
        let CloseBy = LocationManager.WhatIsCloseTo(Latitude: SourceLatitude!,
                                                    Longitude: SourceLongitude!,
                                                    CloseIs: DistanceToUse,
                                                    ForLocations: LookFor)
        for SomethingClose in CloseBy
        {
            var FinalName = SomethingClose.Name
            if SomethingClose.LocationType == .Region
            {
                FinalName = "\(FinalName) region"
            }
            NearTable.append((SomethingClose.Distance,
                              GeoPoint(SomethingClose.Latitude, SomethingClose.Longitude),
                              FinalName,
                              SomethingClose.LocationType))
        }
        let Plural = CloseBy.count != 1 ? "s" : ""
        FoundSummary.stringValue = "Found \(CloseBy.count) item\(Plural)."
        NearByTable.reloadData()
    }
    
    var NearTable = [(Distance: Double, Location: GeoPoint, Description: String, LocType: LocationTypes)]()
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        self.view.window?.close()
    }
    
    @IBAction func HandleDistanceComboChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            let Index = Combo.indexOfSelectedItem
            switch Index
            {
                case 0:
                    CurrentDistance = 50.0
                    
                case 1:
                    CurrentDistance = 100.0
                    
                case 2:
                    CurrentDistance = 200.0
                    
                case 3:
                    CurrentDistance = 500.0
                    
                case 4:
                    CurrentDistance = 1000.0
                    
                default:
                    return
            }
            GetNearByItems()
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat
    {
        return 34.0
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return NearTable.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        
        if tableColumn == tableView.tableColumns[0]
        {
            let IconBox = NSImageView(frame: NSRect(origin: CGPoint.zero, size: CGSize(width: 24, height: 24)))
            var IconName = ""
            var ToolTipText = ""
            switch NearTable[row].LocType
            {
                case .City:
                    ToolTipText = "Location is a city"
                    IconName = "building.2"
                    
                case .Earthquake:
                    ToolTipText = "Location is an earthquake"
                    IconName = "waveform.path"
                    
                case .Home:
                    ToolTipText = "Location is your home location"
                    IconName = "house"
                    
                case .UNESCO:
                    ToolTipText = "Location is a World Heritage Site"
                    IconName = "globe"
                    
                case .UserPOI:
                    ToolTipText = "Location is a point-of-interest"
                    IconName = "pin.fill"
                    
                case .UserPoint:
                    ToolTipText = "Location is where you started searching"
                    IconName = "magnifyingglass.circle.fill"
                    
                case .Region:
                    ToolTipText = "Region you defined"
                    IconName = "rectangle.inset.bottomright.fill"
            }
            IconBox.toolTip = ToolTipText
            let Icon = NSImage(systemSymbolName: IconName, accessibilityDescription: nil)
            IconBox.image = Icon
            return IconBox
        }
        if tableColumn == tableView.tableColumns[1]
        {
            let Units = Settings.GetEnum(ForKey: .InputUnit, EnumType: InputUnits.self, Default: .Kilometers)
            let UnitName = Units == .Kilometers ? "km" : "mi"
            let Distance = Int(NearTable[row].Distance.RoundedTo(0))
            CellContents = "\(Distance)"//"\(Distance) \(UnitName)"
            CellIdentifier = "DistanceColumn"
        }
        if tableColumn == tableView.tableColumns[2]
        {
            let LocalLat = Utility.PrettyLatitude(NearTable[row].Location.Latitude, Precision: 3)
            let LocalLon = Utility.PrettyLongitude(NearTable[row].Location.Longitude, Precision: 3)
            let PrettyLocation = "\(LocalLat)\t\t\(LocalLon)"
            CellContents = PrettyLocation
            CellIdentifier = "LocationColumn"
        }
        if tableColumn == tableView.tableColumns[3]
        {
            CellContents = NearTable[row].Description
            CellIdentifier = "DescriptionColumn"
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor])
    {
        guard let SortDescriptor = tableView.sortDescriptors.first else
        {
            return
        }
        let SortBy = LocationDescriptors(rawValue: SortDescriptor.key!)
        switch SortBy
        {
            case .DistanceType:
                if SortDescriptor.ascending
                {
                    NearTable.sort{$0.Distance < $1.Distance}
                }
                else
                {
                    NearTable.sort{$0.Distance > $1.Distance}
                }
                
            case .LocationType:
                if SortDescriptor.ascending
                {
                    NearTable.sort{$0.LocType.rawValue < $1.LocType.rawValue}
                }
                else
                {
                    NearTable.sort{$0.LocType.rawValue > $1.LocType.rawValue}
                }
                
            case .TypeName:
                if SortDescriptor.ascending
                {
                    NearTable.sort{$0.Description < $1.Description}
                }
                else
                {
                    NearTable.sort{$0.Description > $1.Description}
                }
                
            case .none:
                return
        }
        NearByTable.reloadData()
    }
    
    @IBOutlet weak var DistanceColumn: NSTableColumn!
    @IBOutlet weak var CurrentLocationLabel: NSTextField!
    @IBOutlet weak var FoundSummary: NSTextField!
    @IBOutlet weak var DistanceCombo: NSComboBox!
    @IBOutlet weak var NearByTable: NSTableView!
    
    enum LocationDescriptors: String
    {
        case LocationType = "LocationType"
        case DistanceType = "Distance"
        case TypeName = "Name"
    }
}
