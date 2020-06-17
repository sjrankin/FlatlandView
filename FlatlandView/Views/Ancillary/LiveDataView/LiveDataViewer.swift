//
//  LiveDataViewer.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/17/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class LiveDataViewer: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        LiveViewTable.tableColumns[0].sortDescriptorPrototype = LocationDescriptor
        LiveViewTable.tableColumns[1].sortDescriptorPrototype = MagnitudeDescriptor
        LiveViewTable.tableColumns[2].sortDescriptorPrototype = DateDescriptor
        LiveViewTable.reloadData()
        CategoryTable.reloadData()
        let SelectedRow = IndexSet(integer: 0)
        CategoryTable.selectRowIndexes(SelectedRow, byExtendingSelection: false)
        TableTitle.stringValue = "Earthquake Live Data"
    }
    
    func LoadData(DataType: AsynchronousDataTypes, Raw: Any)
    {
        switch DataType
        {
            case .Earthquakes:
                if let RawEarthquakes = Raw as? [Earthquake]
                {
                    let Plural = RawEarthquakes.count == 1 ? "" : "s"
                    TableSummary.stringValue = "\(RawEarthquakes.count) earthquake\(Plural)"
                    EarthquakeList = RawEarthquakes
                    LiveViewTable.reloadData()
            }
        }
    }
    
    var EarthquakeList = [Earthquake]()
    var LiveDataCategories =
    [
        "Earthquakes"
    ]
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        switch tableView
        {
            case LiveViewTable:
                return EarthquakeList.count
            
            case CategoryTable:
                return LiveDataCategories.count
            
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
            case CategoryTable:
                if tableColumn == tableView.tableColumns[0]
                {
                    CellIdentifier = "LiveDataNameColumn"
                    CellContents = LiveDataCategories[row]
            }
            
            case LiveViewTable:
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
                    CellContents = EarthquakeList[row].Time.PrettyDateTime()
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
    
    //https://www.raywenderlich.com/830-macos-nstableview-tutorial
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor])
    {
        guard let SortDescriptor = tableView.sortDescriptors.first else
        {
            return
        }
        switch tableView
        {
            case LiveViewTable:
                if let Order = EarthquakeDescriptors(rawValue: SortDescriptor.key!)
                {
                    SortEarthquakes(By: Order, Ascending: SortDescriptor.ascending)
                    LiveViewTable.reloadData()
            }
            
            default:
                return
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
            
            default:
                return
        }
    }
    
    @IBAction func HandleTableClicked(_ sender: Any)
    {
        if let Table = sender as? NSTableView
        {
            switch Table
            {
                case CategoryTable:
                TableTitle.stringValue = "Earthquake Live Data"
                
                default:
                    return
            }
        }
    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        if let Frame = self.view.window?.frame
        {
            print("Window frame at close \(Frame)")
            Settings.SetRect(.LiveViewWindowFrame, Frame)
        }
        self.view.window?.close()
    }
    
    let LocationDescriptor = NSSortDescriptor(key: EarthquakeDescriptors.Location.rawValue, ascending: true)
    let MagnitudeDescriptor = NSSortDescriptor(key: EarthquakeDescriptors.Magnitude.rawValue, ascending: false)
    let DateDescriptor = NSSortDescriptor(key: EarthquakeDescriptors.Date.rawValue, ascending: false)
    @IBOutlet weak var TableSummary: NSTextField!
    @IBOutlet weak var LiveViewTable: NSTableView!
    @IBOutlet weak var TableTitle: NSTextField!
    @IBOutlet weak var CategoryTable: NSTableView!
    
    enum EarthquakeDescriptors: String
    {
        case Location = "Location"
        case Magnitude = "Magnitude"
        case Date = "Date"
    }
}
