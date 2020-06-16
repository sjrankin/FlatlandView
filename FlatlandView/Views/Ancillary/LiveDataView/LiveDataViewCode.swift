//
//  LiveDataViewCode.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/16/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class LiveDataViewCode: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        EarthquakeTable.reloadData()
    }
    
    func LoadData(DataType: AsynchronousDataTypes, Raw: Any)
    {
        switch DataType
        {
            case .Earthquakes:
            if let RawEarthquakes = Raw as? [Earthquake]
            {
                EarthquakeList = RawEarthquakes
                EarthquakeTable.reloadData()
            }
        }
    }
    
    var EarthquakeList = [Earthquake]()
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        switch tableView
        {
            case EarthquakeTable:
                return EarthquakeList.count
            
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
            case EarthquakeTable:
                if tableColumn == tableView.tableColumns[0]
                {
                    CellIdentifier = "LocationColumn"
                    CellContents = EarthquakeList[row].Place
            }
                if tableColumn == tableView.tableColumns[1]
                {
                    CellIdentifier = "MagnitudeColumn"
                    CellContents = "\(EarthquakeList[row].Magnitude)"
            }
                if tableColumn == tableView.tableColumns[2]
                {
                    CellIdentifier = "DateColumn"
                    CellContents = EarthquakeList[row].Time.PrettyTime()
            }
                if tableColumn == tableView.tableColumns[3]
                {
                    CellIdentifier = "CoordinatesColumn"
                    CellContents = "\(EarthquakeList[row].Latitude), \(EarthquakeList[row].Longitude)"
            }
            default:
            return nil
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
                self.view.window?.close()
    }
    
    @IBOutlet weak var EarthquakeTable: NSTableView!
}
