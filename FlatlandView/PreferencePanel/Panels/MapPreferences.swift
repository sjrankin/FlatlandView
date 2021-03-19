//
//  MapPreferences.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/3/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class MapPreferences: NSViewController, NSTableViewDelegate, NSTableViewDataSource,
                      PreferencePanelProtocol
{
    weak var Parent: PreferencePanelControllerProtocol? = nil
    weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        for Category in MapManager.GetMapCategories()
        {
            let CategoryMaps = MapManager.GetMapsInCategory(Category)
            let MapNames = CategoryMaps.map{$0.rawValue}
            let TableNode = TableMapNode()
            TableNode.IsHeader = true
            TableNode.Title = Category.rawValue
            TableMapList.append(TableNode)
            for MapName in MapNames
            {
                let MapForCat = TableMapNode()
                MapForCat.IsHeader = false
                MapForCat.Title = MapName
                TableMapList.append(MapForCat)
            }
        }
        
        MapNameLabel.stringValue = ""
        MapTableView.reloadData()
        HelpButtons.append(MapSampleHelpButton)
        HelpButtons.append(ResetPaneHelp)
        HelpButtons.append(UpdateNowHelpButton)
        HelpButtons.append(MapTableHelp)
        HelpButtons.append(SaveImageHelp)
        SetHelpVisibility(To: Settings.GetBool(.ShowUIHelp))
    }
    
    override func viewDidAppear()
    {
        CurrentMap = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .SimplePoliticalMap1)
        SelectMap(CurrentMap)
    }
    
    // MARK: - Table view handling
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return TableMapList.count
    }
    
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool
    {
        TableMapList[row].IsHeader
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "MapColumn"
            CellContents = "  " + TableMapList[row].Title
        }
        else
        {
            let TableWidth = MapTableView.frame.width
            let Header = NSTextField(frame: NSRect(origin: CGPoint(x: 0, y: -16), size: CGSize(width: TableWidth, height: 40)))
            Header.isEditable = false
            Header.drawsBackground = false
            Header.isBezeled = false
            Header.stringValue = TableMapList[row].Title
            Header.textColor = NSColor.white
            Header.font = NSFont.boldSystemFont(ofSize: 18.0)
            Header.backgroundColor = NSColor.clear
            let HeaderView = NSView(frame: NSRect(origin: CGPoint.zero, size: CGSize(width: TableWidth, height: 40)))
            HeaderView.addSubview(Header)
            HeaderView.wantsLayer = true
            HeaderView.layer?.backgroundColor = NSColor.systemGray.cgColor
            return HeaderView
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification)
    {
        let NewRow = MapTableView.selectedRow
        if NewRow > -1
        {
            let MapData = TableMapList[NewRow].Title
            if let ActualMap = MapTypes(rawValue: MapData)
            {
                MapNameLabel.stringValue = MapData
                CurrentMap = ActualMap
                HandleMapViewTypeChanged(self)
            }
        }
    }
    
    func SelectMap(_ Which: MapTypes)
    {
        let SearchFor = Which.rawValue
        for Index in 0 ..< TableMapList.count
        {
            if TableMapList[Index].IsHeader
            {
                continue
            }
            if TableMapList[Index].Title == SearchFor
            {
                let ISet = IndexSet(integer: Index)
                MapTableView.selectRowIndexes(ISet, byExtendingSelection: false)
                MapTableView.scrollRowToVisible(Index)
                MapNameLabel.stringValue = SearchFor
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
        SaveImageGrid.isHidden = true
        if MapManager.IsSatelliteMap(CurrentMap)
        {
            if let SatMap = Settings.GetCachedImage(For: CurrentMap)
            {
                MapViewTypeSegment.selectedSegment = 2
                SampleMapView.image = SatMap
                SaveImageGrid.isHidden = false
            }
        }
        else
        {
            if let MapImage = MapManager.ImageFor(MapType: CurrentMap, ViewType: ViewType, ImageCenter: ImageCenter)
            {
                SampleMapView.image = MapImage
            }
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
                    
                case ResetPaneHelp:
                    Parent?.ShowHelp(For: .PaneReset, Where: Button.bounds, What: ResetPaneHelp)
                    
                case MapTableHelp:
                    Parent?.ShowHelp(For: .ChangingMapsHelp, Where: Button.bounds, What: MapTableHelp)
                    
                case UpdateNowHelpButton:
                    Parent?.ShowHelp(For: .UpdateNowHelp, Where: Button.bounds, What: UpdateNowHelpButton)
                    
                case SaveImageHelp:
                    Parent?.ShowHelp(For: .SaveImageHelp, Where: Button.bounds, What: SaveImageHelp)
                    
                default:
                    return
            }
        }
    }
    
    @IBAction func HandleSaveButtonPressed(_ sender: Any)
    {
        let SavePanel = NSSavePanel()
        SavePanel.showsTagField = true
        SavePanel.title = "Save Satellite Map Image"
        SavePanel.allowedFileTypes = ["png"]
        SavePanel.canCreateDirectories = true
        let Now = Date()
        let PrettyDate = Now.PrettyDate()
        let PrettyTime = Now.PrettyTime(ForFileName: true)
        SavePanel.nameFieldStringValue = "Flatland Satellite Map \(PrettyDate), \(PrettyTime).png"
        SavePanel.level = .modalPanel
        var SaveLocation: URL? = nil
        if SavePanel.runModal() == .OK
        {
            SaveLocation = SavePanel.url
        }
        else
        {
            return
        }
        
        if let SatMap = Settings.GetCachedImage(For: CurrentMap)
        {
            SatMap.WritePNG(ToURL: SaveLocation!)
        }
    }
    
    func SetDarkMode(To DarkMode: Bool)
    {
        InDarkMode = DarkMode
    }
    
    func SetHelpVisibility(To: Bool)
    {
        for HelpButton in HelpButtons
        {
            HelpButton.alphaValue = To ? 1.0 : 0.0
            HelpButton.isEnabled = To ? true : false
        }
    }
    
    //https://stackoverflow.com/questions/29433487/create-an-nsalert-with-swift
    @discardableResult func RunMessageBoxOK(Message: String, InformationMessage: String) -> Bool
    {
        let Alert = NSAlert()
        Alert.messageText = Message
        Alert.informativeText = InformationMessage
        Alert.alertStyle = .warning
        Alert.addButton(withTitle: "Reset Values")
        Alert.addButton(withTitle: "Cancel")
        return Alert.runModal() == .alertFirstButtonReturn
    }
    
    @IBAction func HandleResetPane(_ sender: Any)
    {
        if let _ = sender as? NSButton
        {
            let DoReset = RunMessageBoxOK(Message: "Reset settings on this pane?",
                                          InformationMessage: "You will lose all of the changes you have made to the settings on this panel.")
            if DoReset
            {
                ResetToFactorySettings()
            }
        }
    }
    
    @IBAction func HandleUpdateNowButton(_ sender: Any)
    {
        Settings.SetEnum(CurrentMap, EnumType: MapTypes.self, ForKey: .MapType)
        Debug.Print("CurrentMap is now \(CurrentMap)")
    }
    
    func ResetToFactorySettings()
    {
        CurrentMap = .SimplePoliticalMap1
        Settings.SetEnum(.SimplePoliticalMap1, EnumType: MapTypes.self, ForKey: .MapType)
        SelectMap(CurrentMap)
        MapViewTypeSegment.selectedSegment = 1
        HandleMapViewTypeChanged(self)
    }
    
    var InDarkMode = false
    
    var TableMapList = [TableMapNode]()
    
    var HelpButtons: [NSButton] = [NSButton]()
    
    @IBOutlet weak var SaveImageHelp: NSButton!
    @IBOutlet weak var SaveImageGrid: NSGridView!
    @IBOutlet weak var MapTableView: NSTableView!
    @IBOutlet weak var UpdateNowHelpButton: NSButton!
    @IBOutlet weak var MapTableHelp: NSButton!
    @IBOutlet weak var ResetPaneHelp: NSButton!
    @IBOutlet weak var MapSampleHelpButton: NSButton!
    @IBOutlet weak var MapNameLabel: NSTextField!
    @IBOutlet weak var MapViewTypeSegment: NSSegmentedControl!
    @IBOutlet weak var SampleMapView: NSImageView!
}

class TableMapNode
{
    var IsHeader: Bool = false
    var Title: String = ""
}


class NSImageView2: NSImageView
{
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    override func rightMouseDown(with event: NSEvent)
    {
        super.rightMouseDown(with: event)
    }
}
