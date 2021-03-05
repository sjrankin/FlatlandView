//
//  MainWindow.swift
//  FlatlandView
//
//  Created by Stuart Rankin on 9/13/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import CoreGraphics

class MainWindow: NSWindowController
{
    override func windowDidLoad()
    {
        super.windowDidLoad()
        window?.acceptsMouseMovedEvents = true
        WorldLockButton.toolTip = "Locks or unlocks camera motion for views."
    }
    
    /// Change the image of the passed toolbar item to the passed image.
    /// - Parameter Item: The item to change.
    /// - Parameter To: The new image.
    func ChangeToolbarItemImage(Item: NSToolbarItem, To Image: NSImage)
    {
        Item.image = Image
    }
    
    @IBOutlet weak var DebuggerButton: NSToolbarItem!
    @IBOutlet weak var DebugButton: NSToolbarItem!
    @IBOutlet weak var WorldLockButton: NSButton!
    @IBOutlet weak var WorldLockToolbarItem: NSToolbarItem!
    @IBOutlet weak var MainToolBar: NSToolbar!
}
