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
class PreferencePanelWindow: NSWindowController, NSWindowDelegate, NSToolbarDelegate
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
        CitiesItem.view?.wantsLayer = true
        CitiesItem.view?.layer?.cornerRadius = 3.0
        CitiesItem.view?.layer?.borderWidth = 1.0
        CitiesItem.view?.layer?.borderColor = NSColor.clear.cgColor
        SoundsItem.view?.wantsLayer = true
        SoundsItem.view?.layer?.cornerRadius = 3.0
        SoundsItem.view?.layer?.borderWidth = 1.0
        SoundsItem.view?.layer?.borderColor = NSColor.clear.cgColor
        
        ButtonMap[GeneralButton2] = GeneralItem
        ButtonMap[LiveDataButton] = LiveDataItem
        ButtonMap[QuakeButton] = QuakeItem
        ButtonMap[POIButton] = POIItem
        ButtonMap[SatelliteButton] = SatelliteItem
        ButtonMap[MapButton] = MapsItem
        ButtonMap[MapAttributesButton] = MapAttributesItem
        ButtonMap[CitiesButton] = CitiesItem
        ButtonMap[SoundsButton] = SoundsItem
        
        Highlight(GeneralButton2)
        
        perform(#selector(RemoveTest), with: nil, afterDelay: 0.01, inModes: [.common])
    }
    
    @objc func RemoveTest()
    {
        let SatelliteIndex = IndexOf(SatelliteItem.itemIdentifier)
        if SatelliteIndex > -1
        {
            PreferenceToolbar.removeItem(at: SatelliteIndex)
        }
    }
    
    func IndexOf(_ Item: NSToolbarItem.Identifier) -> Int
    {
        for Index in 0 ..< PreferenceToolbar.items.count
        {
            if PreferenceToolbar.items[Index].itemIdentifier == Item
            {
                return Index
            }
        }
        return -1
    }
    
    /// A theme change was detected by the view controller. Update any highlighted buttons.
    /// - Parameter IsDark: Is in dark mode flag.
    func HandleThemeChanged(_ IsDark: Bool)
    {
    }
    
    func windowWillClose(_ notification: Notification)
    {
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier]
    {
        var OK = [NSToolbarItem.Identifier.flexibleSpace,
                  NSToolbarItem.Identifier.space,
                  GeneralItem.itemIdentifier,
                  LiveDataItem.itemIdentifier,
                  MapsItem.itemIdentifier,
                  POIItem.itemIdentifier,
                  QuakeItem.itemIdentifier,
                  MapAttributesItem.itemIdentifier,
                  CitiesItem.itemIdentifier,
                  SoundsItem.itemIdentifier
        ]
        Features.FeatureIsEnabled(.Satellites)
        {
            OK.append(self.SatelliteItem.itemIdentifier)
        }
        return OK
    }
    
    
    var ButtonMap = [NSButton: NSToolbarItem]()
    
    var PreviousButton: NSButton? = nil
    
    func DeHighlight(_ Button: NSButton)
    {
        Button.contentTintColor = NSColor(named: "ControlBlack")
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
            Button.contentTintColor = NSColor.controlAccentColor
        }
    }
    
    var CurrentlyHighlightedItem: NSToolbarItem? = nil
    var CurrentHighlightColor: NSColor = NSColor.controlAccentColor
    var BorderColor = NSColor.black
    
    @IBOutlet weak var PreferenceToolbar: NSToolbar!
    @IBOutlet weak var GeneralItem: NSToolbarItem!
    @IBOutlet weak var LiveDataItem: NSToolbarItem!
    @IBOutlet weak var MapsItem: NSToolbarItem!
    @IBOutlet weak var POIItem: NSToolbarItem!
    @IBOutlet weak var QuakeItem: NSToolbarItem!
    @IBOutlet weak var SatelliteItem: NSToolbarItem!
    @IBOutlet weak var MapAttributesItem: NSToolbarItem!
    @IBOutlet weak var CitiesItem: NSToolbarItem!
    @IBOutlet weak var SoundsItem: NSToolbarItem!
    
    @IBOutlet weak var MapAttributesButton: NSButton!
    @IBOutlet weak var SatelliteButton: NSButton!
    @IBOutlet weak var QuakeButton: NSButton!
    @IBOutlet weak var POIButton: NSButton!
    @IBOutlet weak var MapButton: NSButton!
    @IBOutlet weak var LiveDataButton: NSButton!
    @IBOutlet weak var GeneralButton2: NSButton!
    @IBOutlet weak var CitiesButton: NSButton!
    @IBOutlet weak var SoundsButton: NSButton!
}
