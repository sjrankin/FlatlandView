//
//  MemoryUIWindow.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/6/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class MemoryUIWindow: NSWindowController
{
    override func windowDidLoad()
    {
        super.windowDidLoad()
        FullValueCheck.state = .off
    }
    
    var Controller: MemoryUI? = nil
    
    @IBAction func HandleFullValueChanged(_ sender: Any)
    {
        if let Controller = self.contentViewController as? MemoryUI
        {
            Controller.HandleFullValueChanged(ShowFullValue: FullValueCheck.state == .on ? true : false)
        }
    }
    
    @IBAction func HandleRefreshPressed(_ sender: Any)
    {
        if let Controller = self.contentViewController as? MemoryUI
        {
            Controller.HandleRefreshButton()
        }
    }
    
    @IBOutlet weak var FullValueCheck: NSButton!
}
