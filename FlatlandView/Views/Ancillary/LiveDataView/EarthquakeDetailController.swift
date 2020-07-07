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
    }
    
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent?.endSheet(Window!, returnCode: .OK)
    }
    
    func DisplayEarthquake(_ Quake: Earthquake2)
    {
        QuakeSource = Quake
        RelatedEarthquakeTable.reloadData()
        PrimaryEarthquakeTable.reloadData()
    }
    
    var QuakeSource: Earthquake2? = nil
    
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
        
        switch tableView
        {
            case PrimaryEarthquakeTable:
                if tableColumn == tableView.tableColumns[0]
                {
                    CellIdentifier = "QuakeAttributeColumn"
                    switch row
                    {
                        case 0:
                            CellContents = "Code"
                            
                        case 1:
                            CellContents = "Place"
                            
                        case 2:
                            CellContents = "Magnitude"
                            
                        case 3:
                            CellContents = "Time"
                            
                        case 4:
                            CellContents = "Location"
                            
                        case 5:
                            CellContents = "Depth"
                            
                        case 6:
                            CellContents = "Tsunami"

                        case 7:
                            CellContents = "Status"
                            
                        case 8:
                            CellContents = "Updated"
                            
                        case 9:
                            CellContents = "MMI"
                            
                        case 10:
                            CellContents = "Felt"
                            
                        case 11:
                            CellContents = "Significance"

                        default:
                            return nil
                    }
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
                            CellContents = "\(QuakeSource!.Updated)"
                            
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
                    CellIdentifier = "MagnitudeColumn"
                    CellContents = "\(QuakeSource!.Related![row].Magnitude.RoundedTo(3))"
                }
                if tableColumn == tableView.tableColumns[1]
                {
                    CellIdentifier = "DateColumn"
                    CellContents = "\(QuakeSource!.Related![row].Time)"
                }
                if tableColumn == tableView.tableColumns[2]
                {
                    CellIdentifier = "CoordinateColumn"
                    let Crd = "\(QuakeSource!.Related![row].Latitude.RoundedTo(2)), \(QuakeSource!.Related![row].Longitude.RoundedTo(2))"
                    CellContents = Crd
                }
                
            default:
                return nil
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    @IBOutlet weak var RelatedEarthquakeTable: NSTableView!
    @IBOutlet weak var PrimaryEarthquakeTable: NSTableView!
}
