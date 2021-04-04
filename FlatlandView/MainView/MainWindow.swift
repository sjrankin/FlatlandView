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

class MainWindow: NSWindowController, NSToolbarDelegate, NSWindowDelegate
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
    
    //https://stackoverflow.com/questions/55878224/how-to-add-a-custom-nstoolbaritem-to-an-existing-toolbar-programmatically
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier]
    {
        var OKIDs = [NSToolbarItem.Identifier.flexibleSpace,
                     NSToolbarItem.Identifier.space,
                     SnapshotButtonItem.itemIdentifier,
                     ResetMapButtonItem.itemIdentifier,
                     PreferenceButtonItem.itemIdentifier,
                     LiveDataButtonItem.itemIdentifier,
                     WorldLockToolbarItem.itemIdentifier,
                     EarthquakeListItem.itemIdentifier]
        #if DEBUG
        OKIDs.append(MemoryButtonItem.itemIdentifier)
        OKIDs.append(DebuggerButton.itemIdentifier)
        OKIDs.append(DebugButton.itemIdentifier)
        #endif
        return OKIDs
    }
    
    @IBOutlet weak var EarthquakeListItem: NSToolbarItem!
    @IBOutlet weak var MemoryButtonItem: NSToolbarItem!
    @IBOutlet weak var SnapshotButtonItem: NSToolbarItem!
    @IBOutlet weak var ResetMapButtonItem: NSToolbarItem!
    @IBOutlet weak var PreferenceButtonItem: NSToolbarItem!
    @IBOutlet weak var LiveDataButtonItem: NSToolbarItem!
    @IBOutlet weak var AboutButtonItem: NSToolbarItem!
    @IBOutlet weak var DebuggerButton: NSToolbarItem!
    @IBOutlet weak var DebugButton: NSToolbarItem!
    @IBOutlet weak var WorldLockButton: NSButton!
    @IBOutlet weak var WorldLockToolbarItem: NSToolbarItem!
    @IBOutlet weak var MainToolBar: NSToolbar!
}
