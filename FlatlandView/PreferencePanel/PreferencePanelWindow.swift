//
//  PreferencePanelWindow.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/2/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class PreferencePanelWindow: NSWindowController
{
    override func windowDidLoad()
    {
        #if true
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
        GeneralItem.view?.wantsLayer = true
        GeneralItem.view?.layer?.cornerRadius = 3.0
        GeneralItem.view?.layer?.borderWidth = 1.0
        GeneralItem.view?.layer?.borderColor = NSColor.clear.cgColor
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
        #else
        POIButton.wantsLayer = true
        POIButton.layer?.cornerRadius = 3.0
        POIButton.layer?.borderWidth = 1.0
        POIButton.layer?.borderColor = NSColor.clear.cgColor
        MapButton.wantsLayer = true
        MapButton.layer?.cornerRadius = 3.0
        MapButton.layer?.borderWidth = 1.0
        MapButton.layer?.borderColor = NSColor.clear.cgColor
        LiveDataButton.wantsLayer = true
        LiveDataButton.layer?.cornerRadius = 3.0
        LiveDataButton.layer?.borderWidth = 1.0
        LiveDataButton.layer?.borderColor = NSColor.clear.cgColor
        GeneralButton.wantsLayer = true
        GeneralButton.layer?.cornerRadius = 3.0
        GeneralButton.layer?.borderWidth = 1.0
        GeneralButton.layer?.borderColor = NSColor.clear.cgColor
        SatelliteButton.wantsLayer = true
        SatelliteButton.layer?.cornerRadius = 3.0
        SatelliteButton.layer?.borderWidth = 1.0
        SatelliteButton.layer?.borderColor = NSColor.clear.cgColor
        QuakeButton.wantsLayer = true
        QuakeButton.layer?.cornerRadius = 3.0
        QuakeButton.layer?.borderWidth = 1.0
        QuakeButton.layer?.borderColor = NSColor.clear.cgColor
        #endif
        
        ButtonMap[GeneralButton] = GeneralItem
        ButtonMap[LiveDataButton] = LiveDataItem
        ButtonMap[QuakeButton] = QuakeItem
        ButtonMap[POIButton] = POIItem
        ButtonMap[SatelliteButton] = SatelliteItem
        ButtonMap[MapButton] = MapsItem
        ButtonMap[MapAttributesButton] = MapAttributesItem
    }
    
    var ButtonMap = [NSButton: NSToolbarItem]()
    
    var PreviousButton: NSButton? = nil
    
    func DeHighlight(_ Button: NSButton)
    {
        #if true
        if let Item = ButtonMap[Button]
        {
        Item.view?.layer?.backgroundColor = NSColor.clear.cgColor
            Item.view?.layer?.borderColor = NSColor.clear.cgColor
        }
        #else
        Button.layer?.backgroundColor = NSColor.clear.cgColor
        Button.layer?.borderColor = NSColor.clear.cgColor
        #endif
    }
    
    func Highlight(_ Button: NSButton)
    {
        if PreviousButton != nil
        {
            DeHighlight(PreviousButton!)
        }
        PreviousButton = Button
        #if true
        if let Item = ButtonMap[Button]
        {
            Item.view?.layer?.backgroundColor = NSColor.systemYellow.cgColor
            Item.view?.layer?.borderColor = NSColor.black.cgColor
        }
        #else
        Button.layer?.backgroundColor = NSColor.systemYellow.cgColor
        Button.layer?.borderColor = NSColor.black.cgColor
        #endif
    }
    
    @IBOutlet weak var GeneralItem: NSToolbarItem!
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
    @IBOutlet weak var GeneralButton: NSButton!
}
