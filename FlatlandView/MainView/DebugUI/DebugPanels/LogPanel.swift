//
//  LogPanel.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/8/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class LogPanel: PanelController, NSTableViewDelegate, NSTableViewDataSource
{
    override func viewDidLoad()
    {
        LocalLog = Debug.GetLog()
    }
    
    var LocalLog = [(TimeStamp: String, Payload: String)]()
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return LocalLog.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        var CellToolTip: String? = nil
        
        if tableColumn == tableView.tableColumns[0]
        {
            CellContents = LocalLog[row].TimeStamp
            CellIdentifier = "TimeStampColumn"
        }
        if tableColumn == tableView.tableColumns[1]
        {
            CellContents = LocalLog[row].Payload
            CellToolTip = LocalLog[row].Payload
            CellIdentifier = "TextColumn"
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        if let ToolTip = CellToolTip
        {
            Cell?.toolTip = ToolTip
        }
        return Cell
    }
    
    @IBAction func HandleRefreshButton(_ sender: Any)
    {
        LocalLog.removeAll()
        LocalLog = Debug.GetLog()
        LogTable.reloadData()
    }
    
    @IBOutlet weak var LogTable: NSTableView!
}
