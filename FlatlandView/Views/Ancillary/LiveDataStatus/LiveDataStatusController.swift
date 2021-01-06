//
//  LiveDataStatusController.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/5/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class LiveDataStatusController: NSViewController, NSTableViewDelegate, NSTableViewDataSource,
                                WindowManagement
{
    public weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        DataSelectionSegment.selectedSegment = 0
    }
    
    override func viewDidLayout()
    {
        LoadData()
    }
    
    func LoadData()
    {
        TableData.removeAll()
        switch DataSelectionSegment.selectedSegment
        {
            case 0:
                var Enabled = ""
                if Settings.GetBool(.EnableEarthquakes)
                {
                    Enabled = "True"
                }
                else
                {
                    Enabled = "False"
                }
                TableData.append(("Earthquakes Enabled", Enabled))
                TableData.append(("Source", "USGS"))
                TableData.append(("URL", "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson"))
                let Seconds = Settings.GetDouble(.EarthquakeFetchInterval, 0.0)
                if Seconds > 0.0
                {
                    TableData.append(("Retrieval Frequency", "\(Seconds) seconds"))
                }
                TableData.append(("Call Count", "\(USGS.CallCount)"))
                TableData.append(("Total Duration", "\(USGS.TotalDuration) seconds"))
                if USGS.CallCount > 0
                {
                    TableData.append(("Mean Duration", "\(USGS.TotalDuration / Double(USGS.CallCount)) seconds"))
                }
                TableData.append(("Parse Error Count", "\(USGS.ParseErrorCount)"))
                TableData.append(("Response Error Count", "\(USGS.ResponseErrorCount)"))
                TableData.append(("Time-Out Count", "\(USGS.TimeOutCount)"))
                
            case 1:
                break
                
            default:
                break
        }
        StatusView.reloadData()
    }
    
    var TableData = [(Key: String, Value: String)]()
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return TableData.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any?
    {
        var CellContents = ""
        var CellIdentifier = ""
        
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "IndicatorColumn"
            CellContents = TableData[row].Key
        }
        if tableColumn == tableView.tableColumns[1]
        {
            CellIdentifier = "ValueColumn"
            CellContents = TableData[row].Value
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier),
                                      owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    func MainClosing()
    {
        self.view.window?.close()
    }
    
    @IBAction func HandleCloseButton(_ sender: Any)
    {
        self.view.window?.close()
    }
    
    @IBAction func HandleDataSelectionChanged(_ sender: Any)
    {
    }
    
    @IBOutlet weak var StatusView: NSTableView!
    @IBOutlet weak var DataSelectionSegment: NSSegmentedControl!
}
