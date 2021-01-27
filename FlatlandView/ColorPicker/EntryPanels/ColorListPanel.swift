//
//  ColorListPanel.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/26/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ColorListPanel: NSViewController, NSTableViewDelegate, NSTableViewDataSource, ColorPanelProtocol
{
    public weak var Parent: ColorPanelParentProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidAppear()
    {
        super.viewDidAppear()
    }
    
    func SetColor(_ Color: NSColor, From: ColorPanelTypes)
    {
        if From != .ColorList
        {
            
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        return nil
    }
    
    @IBOutlet weak var ColorTable: NSTableView!
}
