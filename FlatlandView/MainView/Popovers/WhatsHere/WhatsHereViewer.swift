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
    }
    
    override func viewDidLayout()
    {
        super.viewDidLayout()
        Initialize()
    }
    
    func Initialize()
    {
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
        LatitudeLabel.stringValue = ""
        LongitudeLabel.stringValue = ""
        FoundSummary.stringValue = ""
        NearByTable.reloadData()
    }
    
    var CurrentDistance: Double = 0
    
    var Main: MainProtocol? = nil
    
    func SetLocation(_ Latitude: Double, _ Longitude: Double, Main: MainProtocol? = nil)
    {
        self.Main = Main
        let NiceLat = Utility.PrettyLatitude(Latitude)
        let NiceLon = Utility.PrettyLongitude(Longitude)
        LatitudeLabel.stringValue = NiceLat
        LongitudeLabel.stringValue = NiceLon
        SourceLatitude = Latitude
        SourceLongitude = Longitude
        print("Looking at \(NiceLat),\(NiceLon)")
        GetNearByItems()
    }
    
    var SourceLatitude = 0.0
    var SourceLongitude = 0.0
    
    func GetNearByItems()
    {
        var DistanceToUse = CurrentDistance
        if Settings.GetEnum(ForKey: .InputUnit, EnumType: InputUnits.self, Default: .Kilometers) == .Miles
        {
            DistanceToUse = CurrentDistance * 1.6
        }
        NearTable.removeAll()
        NearTable.append((Distance: 0.0,
                          Location: GeoPoint(SourceLatitude, SourceLongitude),
                          Description: "Search location",
                          LocType: .UserPoint))
        let LocationManager = Locations()
        if let MainDelegate = Main
        {
            LocationManager.Main = MainDelegate
        }
        let LookFor: [LocationTypes] = [.City, .Earthquake, .Home, .UNESCO, .UserPOI]
        let CloseBy = LocationManager.WhatIsCloseTo(Latitude: SourceLatitude,
                                                    Longitude: SourceLongitude,
                                                    CloseIs: DistanceToUse,
                                                    ForLocations: LookFor)
        for SomethingClose in CloseBy
        {
            NearTable.append((SomethingClose.Distance,
                              GeoPoint(SomethingClose.Latitude, SomethingClose.Longitude),
                              SomethingClose.Name,
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
            var IconName = ""
            var ToolTipText = ""
            switch NearTable[row].LocType
            {
                case .City:
                    IconName = "CityIcon"
                    ToolTipText = "Location is a city"
                    
                case .Earthquake:
                    IconName = "EventIcon"
                    ToolTipText = "Location is an earthquake"
                    
                case .Home:
                    IconName = "HomeTypeIcon"
                    ToolTipText = "Location is your home location"
                    
                case .UNESCO:
                    IconName = "UNESCOTypeIcon"
                    ToolTipText = "Location is a World Heritage Site"
                    
                case .UserPOI:
                    IconName = "POITypeIcon"
                    ToolTipText = "Location is a point-of-interest"
                    
                case .UserPoint:
                    IconName = "SearchTypeIcon"
                    ToolTipText = "Location is where you started searching"
                    
                default:
                    IconName = "UnknownTypeIcon"
                    ToolTipText = "Location is an unknown type"
            }
            let IView = NSImageView(frame: NSRect(origin: CGPoint.zero, size: CGSize(width: 24, height: 24)))
            IView.image = NSImage(named: IconName)
            IView.toolTip = ToolTipText
            return IView
            
        }
        if tableColumn == tableView.tableColumns[1]
        {
            let Units = Settings.GetEnum(ForKey: .InputUnit, EnumType: InputUnits.self, Default: .Kilometers)
            let UnitName = Units == .Kilometers ? "km" : "mi"
            let Distance = Int(NearTable[row].Distance.RoundedTo(0))
            CellContents = "\(Distance) \(UnitName)"
            CellIdentifier = "DistanceColumn"
        }
        if tableColumn == tableView.tableColumns[2]
        {
            let LocalLat = NearTable[row].Location.Latitude
            let LocalLon = NearTable[row].Location.Longitude
            let PrettyLocation = Utility.PrettyCoordinates(LocalLat, LocalLon, Precision: 3)
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
    
    @IBOutlet weak var FoundSummary: NSTextField!
    @IBOutlet weak var DistanceCombo: NSComboBox!
    @IBOutlet weak var LatitudeLabel: NSTextField!
    @IBOutlet weak var LongitudeLabel: NSTextField!
    @IBOutlet weak var NearByTable: NSTableView!
}
