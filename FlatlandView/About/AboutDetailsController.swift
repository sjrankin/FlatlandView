//
//  AboutDetailsController.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class AboutDetailsController: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Details.append("Flatland")
        Details.append("Version \(Versioning.VerySimpleVersionString())")
        Details.append("Build \(Versioning.Build), \(Versioning.BuildDate), \(Versioning.BuildTime)")
        Details.append("\(Versioning.CopyrightText())")
        VersioningTable.reloadData()
    }
    
    var Details = [String]()
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return Details.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "ValueColumn"
            CellContents = Details[row]
        }
        else
        {
            return nil
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    @IBAction func HandleCloseButton(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent!.endSheet(Window!, returnCode: .OK)
    }
    
    @IBOutlet weak var VersioningTable: NSTableView!
}
