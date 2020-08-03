//
//  EarthquakeDetailController.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class EarthquakeDetailController: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("viewDidLoad")
    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent?.endSheet(Window!, returnCode: .OK)
    }
    
    func DisplayEarthquake(_ Quake: Earthquake)
    {
        print("DisplayEarthquake")
        QuakeSource = Quake
        RelatedEarthquakeTable.reloadData()
        PrimaryEarthquakeTable.reloadData()
    }
    
    var QuakeSource: Earthquake? = nil
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        switch tableView
        {
            case PrimaryEarthquakeTable:
                if QuakeSource == nil
                {
                    return 0
                }
                return 12
                
            case RelatedEarthquakeTable:
                if QuakeSource == nil
                {
                    return 0
                }
                else
                {
                    if let Related = QuakeSource?.Related
                    {
                        return Related.count
                    }
                    return 0
                }
                
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        var CellToolTip: String? = nil
        
        switch tableView
        {
            case PrimaryEarthquakeTable:
                if tableColumn == tableView.tableColumns[0]
                {
                    CellIdentifier = "QuakeAttributeColumn"
                    CellContents = ["Code", "Place", "Magnitude", "Time", "Location", "Depth", "Tsunami", "Status",
                                    "Updated", "MMI", "Felt", "Significance"][row]
                }
                if tableColumn == tableView.tableColumns[1]
                {
                    CellIdentifier = "QuakeValueColumn"
                    switch row
                    {
                        case 0:
                            CellContents = QuakeSource!.Code
                            
                        case 1:
                            CellContents = QuakeSource!.Place
                            CellToolTip = QuakeSource!.Place
                            
                        case 2:
                            CellContents = "\(QuakeSource!.Magnitude.RoundedTo(3))"
                            
                        case 3:
                            CellContents = "\(QuakeSource!.Time)"
                            
                        case 4:
                            CellContents = "\(QuakeSource!.Latitude.RoundedTo(3)), \(QuakeSource!.Longitude.RoundedTo(3))"
                            
                        case 5:
                            CellContents = "\(QuakeSource!.Depth)"
                            
                        case 6:
                            CellContents = QuakeSource!.Tsunami == 1 ? "Have data" : "No data"
                            
                        case 7:
                            CellContents = QuakeSource!.Status
                            
                        case 8:
                            if let Updated = QuakeSource!.Updated
                            {
                                CellContents = "\(Updated)"
                            }
                            else
                            {
                                CellContents = ""
                            }
                            
                        case 9:
                            CellContents = "\(QuakeSource!.MMI.RoundedTo(3))"
                            
                        case 10:
                            CellContents = "\(QuakeSource!.Felt)"
                            
                        case 11:
                            CellContents = "\(QuakeSource!.Significance)"
                            
                        default:
                            return nil
                    }
                }
                
            case RelatedEarthquakeTable:
                if tableColumn == tableView.tableColumns[0]
                {
                    CellIdentifier = "CodeColumn"
                    CellContents = QuakeSource!.Related![row].Code
                }
                if tableColumn == tableView.tableColumns[1]
                {
                    CellIdentifier = "MagnitudeColumn"
                    CellContents = "\(QuakeSource!.Related![row].Magnitude.RoundedTo(3))"
                }
                if tableColumn == tableView.tableColumns[2]
                {
                    CellIdentifier = "DateColumn"
                    CellContents = "\(QuakeSource!.Related![row].Time)"
                }
                if tableColumn == tableView.tableColumns[3]
                {
                    CellIdentifier = "CoordinateColumn"
                    let Crd = "\(QuakeSource!.Related![row].Latitude.RoundedTo(2)), \(QuakeSource!.Related![row].Longitude.RoundedTo(2))"
                    CellContents = Crd
                    CellToolTip = QuakeSource!.Place
                }
                if tableColumn == tableView.tableColumns[4]
                {
                    CellIdentifier = "DistanceColumn"
                    let Distance = QuakeSource!.DistanceTo(QuakeSource!.Related![row]).RoundedTo(1)
                    CellContents = "\(Distance)"
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
    
    @IBOutlet weak var RelatedEarthquakeTable: NSTableView!
    @IBOutlet weak var PrimaryEarthquakeTable: NSTableView!
}
