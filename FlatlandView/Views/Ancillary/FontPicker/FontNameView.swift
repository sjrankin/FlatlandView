//
//  FontNameView.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class FontNameView: NSViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    func LoadNames(_ FontNames: [String])
    {
        self.FontNames = FontNames.sorted()
        NameTable.reloadData()
    }
    
    var FontNames = [String]()
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return FontNames.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "FontNameColumn"
            CellContents = FontNames[row]
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent?.endSheet(Window!, returnCode: .OK)
    }
    
    @IBOutlet weak var NameTable: NSTableView!
}
