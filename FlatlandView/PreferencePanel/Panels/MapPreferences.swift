//
//  MapPreferences.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/3/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class MapPreferences: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate,
                      PreferencePanelProtocol
{
    weak var Parent: PreferencePanelControllerProtocol? = nil
    weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        AllMaps = [MapNode]()
        for Category in MapManager.GetMapCategories()
        {
            #if DEBUG
            #else
            if Category == .Debug
            {
                Continue
            }
            #endif
            let CategoryMaps = MapManager.GetMapsInCategory(Category)
            let MapNames = CategoryMaps.map{$0.rawValue}
            let NewNode = MapNode(Category: Category.rawValue, Maps: MapNames)
            AllMaps.append(NewNode)
        }
        MapNameLabel.stringValue = ""
        MapTable.reloadData()
    }
    
    var AllMaps: [MapNode]!
    
    // MARK: - Outline view handling

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
    {
        if let SomeMap = item as? MapNode
        {
            return SomeMap.Maps[index]
        }
        return AllMaps![index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
    {
        if let SomeMap = item as? MapNode
        {
            return SomeMap.Maps.count > 0
        }
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int
    {
        if AllMaps == nil
        {
            return 0
        }
        if let SomeMap = item as? MapNode
        {
            return SomeMap.Maps.count
        }
        return AllMaps!.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?
    {
        var Text = ""
        var TextFont = NSFont()
        var TextColor = NSColor.black
        if let SomeMap = item as? MapNode
        {
            Text = SomeMap.Category
            TextColor = NSColor.PrussianBlue
            TextFont = NSFont.boldSystemFont(ofSize: 15.0)
        }
        else
        {
            Text = item as! String
            TextFont = NSFont.systemFont(ofSize: 14.0)
        }
        let tableCell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MapCell"), owner: self) as! NSTableCellView
        tableCell.textField!.stringValue = Text
        tableCell.textField!.font = TextFont
        tableCell.textField!.textColor = TextColor
        return tableCell
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification)
    {
        guard let outView = notification.object as? NSOutlineView else
        {
            return
        }
        let SelectedIndex = outView.selectedRow
        if let MapName = outView.item(atRow: SelectedIndex) as? String
        {
            if let MapType = MapTypes(rawValue: MapName)
            {
                MapNameLabel.stringValue = MapName
                let ViewType = GetViewType()
                var ImageCenter = ImageCenters.SouthPole
                if ViewType == .FlatNorthCenter
                {
                    ImageCenter = .NorthPole
                }
                if let MapImage = MapManager.ImageFor(MapType: MapType, ViewType: ViewType, ImageCenter: ImageCenter)
                {
                    SampleMapView.image = MapImage
                    CurrentMap = MapType
                }
                else
                {
                    print("MapManager.ImageFor return nil image.")
                }
            }
            else
            {
                print("Bad map type: \(MapName)")
            }
        }
    }
    
    var CurrentMap: MapTypes = .Standard
    
    func GetViewType() -> ViewTypes
    {
        let Index = MapViewTypeSegment.selectedSegment
        switch Index
        {
            case 0:
                return .FlatSouthCenter
                
            case 1:
                return .FlatNorthCenter
                
            case 2:
                return .Rectangular
                
            case 3:
                return .Globe3D
                
            default:
                fatalError("Unexpected index in \(#function)")
        }
    }
    
    @IBAction func HandleMapViewTypeChanged(_ sender: Any)
    {
        let ViewType = GetViewType()
        var ImageCenter = ImageCenters.SouthPole
        if ViewType == .FlatNorthCenter
        {
            ImageCenter = .NorthPole
        }
        if let MapImage = MapManager.ImageFor(MapType: CurrentMap, ViewType: ViewType, ImageCenter: ImageCenter)
        {
            SampleMapView.image = MapImage
        }
    }
    
    @IBAction func HandleHelpButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            switch Button
            {
                case MapSampleHelpButton:
                    Parent?.ShowHelp(For: .MapSample, Where: Button.bounds, What: MapSampleHelpButton)
                    
                default:
                    return
            }
        }
    }
    
    @IBOutlet weak var MapSampleHelpButton: NSButton!
    @IBOutlet weak var MapNameLabel: NSTextField!
    @IBOutlet weak var MapViewTypeSegment: NSSegmentedControl!
    @IBOutlet weak var MapTable: NSOutlineView!
    @IBOutlet weak var SampleMapView: NSImageView!
}

class MapNode
{
    var Category: String!
    var Maps: [String]!
    
    init(Category: String, Maps: [String])
    {
        self.Category = Category
        self.Maps = Maps
    }
}

class MapCategory
{
    var Name: String!
    var Maps: [String]!
    
    init(Name: String, Maps: [String])
    {
        self.Name = Name
        self.Maps = Maps
    }
}
