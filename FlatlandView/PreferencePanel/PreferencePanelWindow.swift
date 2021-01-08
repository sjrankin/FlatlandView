//
//  PreferencePanelWindow.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/2/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// https://github.com/ruiaureliano/macOS-Appearance/blob/master/Appearance/Source/AppDelegate.swift
class PreferencePanelWindow: NSWindowController, NSWindowDelegate
{
    override func windowDidLoad()
    {
        POIItem.view?.wantsLayer = true
        POIItem.view?.layer?.cornerRadius = 3.0
        POIItem.view?.layer?.borderWidth = 1.0
        POIItem.view?.layer?.borderColor = NSColor.clear.cgColor
        MapsItem.view?.wantsLayer = true
        MapsItem.view?.layer?.cornerRadius = 3.0
        MapsItem.view?.layer?.borderWidth = 1.0
        MapsItem.view?.layer?.borderColor = NSColor.clear.cgColor
        LiveDataItem.view?.wantsLayer = true
        LiveDataItem.view?.layer?.cornerRadius = 3.0
        LiveDataItem.view?.layer?.borderWidth = 1.0
        LiveDataItem.view?.layer?.borderColor = NSColor.clear.cgColor
        GeneralItem2.view?.wantsLayer = true
        GeneralItem2.view?.layer?.cornerRadius = 3.0
        GeneralItem2.view?.layer?.borderWidth = 1.0
        GeneralItem2.view?.layer?.borderColor = NSColor.clear.cgColor
        SatelliteItem.view?.wantsLayer = true
        SatelliteItem.view?.layer?.cornerRadius = 3.0
        SatelliteItem.view?.layer?.borderWidth = 1.0
        SatelliteItem.view?.layer?.borderColor = NSColor.clear.cgColor
        QuakeItem.view?.wantsLayer = true
        QuakeItem.view?.layer?.cornerRadius = 3.0
        QuakeItem.view?.layer?.borderWidth = 1.0
        QuakeItem.view?.layer?.borderColor = NSColor.clear.cgColor
        MapAttributesItem.view?.wantsLayer = true
        MapAttributesItem.view?.layer?.cornerRadius = 3.0
        MapAttributesItem.view?.layer?.borderWidth = 1.0
        MapAttributesItem.view?.layer?.borderColor = NSColor.clear.cgColor
        
        ButtonMap[GeneralButton2] = GeneralItem2
        ButtonMap[LiveDataButton] = LiveDataItem
        ButtonMap[QuakeButton] = QuakeItem
        ButtonMap[POIButton] = POIItem
        ButtonMap[SatelliteButton] = SatelliteItem
        ButtonMap[MapButton] = MapsItem
        ButtonMap[MapAttributesButton] = MapAttributesItem
        
        Highlight(GeneralButton2)
    }
    
    /// A theme change was detected by the view controller. Update any highlighted buttons.
    /// - Parameter IsDark: Is in dark mode flag.
    func HandleThemeChanged(_ IsDark: Bool)
    {
        #if false
        if IsDark
        {
            CurrentHighlightColor = NSColor(RGB: 0x101010)
            BorderColor = NSColor.lightGray
        }
        else
        {
            CurrentHighlightColor = NSColor.controlAccentColor
            BorderColor = NSColor.black
        }
        if let Item = CurrentlyHighlightedItem
        {
            Item.view?.layer?.backgroundColor = CurrentHighlightColor.cgColor
            Item.view?.layer?.borderColor = BorderColor.cgColor
        }
        #endif
    }

    func windowWillClose(_ notification: Notification)
    {
    }
    
    var ButtonMap = [NSButton: NSToolbarItem]()
    
    var PreviousButton: NSButton? = nil
    
    func DeHighlight(_ Button: NSButton)
    {
        if let Item = ButtonMap[Button]
        {
            #if true
            Button.contentTintColor = NSColor(named: "ControlBlack")
            #else
            Item.view?.layer?.backgroundColor = NSColor.clear.cgColor
            Item.view?.layer?.borderColor = NSColor.clear.cgColor
            #endif
        }
    }
    
    func Highlight(_ Button: NSButton)
    {
        if PreviousButton != nil
        {
            DeHighlight(PreviousButton!)
        }
        PreviousButton = Button
        if let Item = ButtonMap[Button]
        {
            CurrentlyHighlightedItem = Item
            #if true
            Button.contentTintColor = NSColor.controlAccentColor
            #else
            Item.view?.layer?.backgroundColor = CurrentHighlightColor.cgColor
            Item.view?.layer?.borderColor = BorderColor.cgColor
            #endif
        }
    }
    
    var CurrentlyHighlightedItem: NSToolbarItem? = nil
    var CurrentHighlightColor: NSColor = NSColor.controlAccentColor
    var BorderColor = NSColor.black
    
    @IBOutlet weak var GeneralItem2: NSToolbarItem!
    @IBOutlet weak var LiveDataItem: NSToolbarItem!
    @IBOutlet weak var MapsItem: NSToolbarItem!
    @IBOutlet weak var POIItem: NSToolbarItem!
    @IBOutlet weak var QuakeItem: NSToolbarItem!
    @IBOutlet weak var SatelliteItem: NSToolbarItem!
    @IBOutlet weak var MapAttributesItem: NSToolbarItem!
    
    @IBOutlet weak var MapAttributesButton: NSButton!
    @IBOutlet weak var SatelliteButton: NSButton!
    @IBOutlet weak var QuakeButton: NSButton!
    @IBOutlet weak var POIButton: NSButton!
    @IBOutlet weak var MapButton: NSButton!
    @IBOutlet weak var LiveDataButton: NSButton!
    @IBOutlet weak var GeneralButton2: NSButton!
}
