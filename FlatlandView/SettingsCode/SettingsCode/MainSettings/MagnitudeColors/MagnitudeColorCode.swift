//
//  MagnitudeColorCode.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/22/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class MagnitudeColorCode: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        EarthquakeColors = Settings.GetMagnitudeColors()
        for (Mag, Color) in EarthquakeColors
        {
            EqColorList.append((Mag.rawValue, Color))
        }
        EqColorList.sort(by: {$0.Magnitude < $1.Magnitude})
        MagnitudeTable.reloadData()
    }
    
    var EarthquakeColors = [EarthquakeMagnitudes: NSColor]()
    var EqColorList = [(Magnitude: Double, Color: NSColor)]()
    var CurrentMagIndex = -1
    
    @IBAction func HandleEditColor(_ sender: Any)
    {
    }
    
    @IBAction func HandleResetColor(_ sender: Any)
    {
    }
    
    @IBAction func HandleResetAllColors(_ sender: Any)
    {
        EarthquakeColors = Settings.GetMagnitudeColors()
        for (Mag, Color) in EarthquakeColors
        {
            EqColorList.append((Mag.rawValue, Color))
        }
        EqColorList.sort(by: {$0.Magnitude < $1.Magnitude})
        MagnitudeTable.reloadData()
    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent?.endSheet(Window!, returnCode: .OK)
    }
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent?.endSheet(Window!, returnCode: .cancel)
    }
    
    @IBAction func HandleTableClicked(_ sender: Any)
    {
        if let Table = sender as? NSTableView
        {
            CurrentMagIndex = Table.selectedRow
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "MagnitudeColumn"
            CellContents = "\(EqColorList[row].Magnitude)"
        }
        if tableColumn == tableView.tableColumns[1]
        {
            CellIdentifier = "ColorColumn"
            let Color = EqColorList[row].Color
            let Swatch = NSView(frame: NSRect(x: 5, y: 2, width: 40, height: 20))
            Swatch.wantsLayer = true
            Swatch.layer?.backgroundColor = Color.cgColor
            Swatch.layer?.borderColor = NSColor.black.cgColor
            Swatch.layer?.borderWidth = 0.5
            Swatch.layer?.cornerRadius = 5.0
            return Swatch
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        print("EqColorList.count=\(EqColorList.count)")
        return EqColorList.count
    }
    
    @IBOutlet weak var MagnitudeTable: NSTableView!
}
