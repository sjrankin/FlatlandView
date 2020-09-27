//
//  RawSettingsController.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/28/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

class RawSettingsController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, RawSettingsProtocol
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        LoadSettingsData()
        SettingsTable.reloadData()
    }
    
    func LoadSettingsData()
    {
        for Setting in SettingKeys.allCases
        {
            if let SettingType = Settings.SettingKeyTypes[Setting]
            {
                if let EditorID = TypeEditorMap["\(SettingType)"]
                {
                    let Editor = CreateEditorDialog(EditorID)
                    SettingsData.append(("\(Setting)", "\(SettingType)", false, Editor))
                }
            }
        }
    }
    
    var SettingsData = [(Name: String, Type: String, IsDirty: Bool, Editor: NSViewController?)]()
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return SettingsData.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "SettingNameColumn"
            CellContents = SettingsData[row].Name
        }
        if tableColumn == tableView.tableColumns[1]
        {
            CellIdentifier = "SettingTypeColumn"
            CellContents = SettingsData[row].Type
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        if SettingsData[row].IsDirty
        {
            Cell?.textField?.textColor = NSColor.systemRed
        }
        else
        {
            Cell?.textField?.textColor = NSColor.black
        }
        return Cell
    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent?.endSheet(Window!, returnCode: .OK)
    }
    
    @IBAction func HandleSettingsAction(_ sender: Any)
    {
        let Row = SettingsTable.selectedRow
        if Row > -1
        {
            DisplayEditorFor(SettingsData[Row])
        }
    }
    
    func DisplayEditorFor(_ SettingData: (Name: String, Type: String, IsDirty: Bool, Editor: NSViewController?))
    {
        for SomeView in EditorSink.subviews
        {
            SomeView.removeFromSuperview()
        }
        SettingData.Editor?.view.frame = EditorSink.bounds
        EditorSink.addSubview(SettingData.Editor!.view)
        let EditorController = SettingData.Editor as! EditorProtocol
        EditorController.AssignDelegate(self)
        if let (RawValue, RawType) = GetSettingValue()
        {
            EditorController.LoadValue(RawValue, RawType)
        }
        else
        {
            let Row = SettingsTable.selectedRow
            fatalError("Error getting value for \(SettingsData[Row].Name)")
        }
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor])
    {
        guard let SortDescriptor = tableView.sortDescriptors.first else
        {
            return
        }
        if let Order = SettingDescriptors(rawValue: SortDescriptor.key!)
        {
            SortTable(By: Order, Ascending: SortDescriptor.ascending)
            SettingsTable.reloadData()
        }
    }
    
    func SortTable(By: SettingDescriptors, Ascending: Bool)
    {
        switch By
        {
            case .SettingKey:
                if Ascending
                {
                    SettingsData.sort
                    {
                        $0.Name < $1.Name
                    }
                }
                else
                {
                    SettingsData.sort
                    {
                        $0.Name > $1.Name
                    }
                }
                
            case .SettingType:
                if Ascending
                {
                    SettingsData.sort
                    {
                        $0.Type < $1.Type
                    }
                }
                else
                {
                    SettingsData.sort
                    {
                        $0.Type > $1.Type
                    }
                }
        }
    }
    
    func GetSettingName() -> String
    {
        let Row = SettingsTable.selectedRow
        return SettingsData[Row].Name
    }
    
    func GetSettingType() -> String
    {
        let Row = SettingsTable.selectedRow
        return SettingsData[Row].Type
    }
    
    func GetSettingValue() -> (Any?, String)?
    {
        let Frames = Debug.StackFrameContents(10)
        print(Debug.PrettyStackTrace(Frames))
        let Row = SettingsTable.selectedRow
        let SettingType = "\(SettingsData[Row].Type)"
        let SettingKey = SettingKeys(rawValue: SettingsData[Row].Name)
        if EnumFields.contains(SettingType)
        {
            if let EVal = GetEnumValue(SettingType)
            {
                return (EVal, SettingType)
            }
            else
            {
                return nil
            }
        }
        var Final: (Any?, String)? = nil
        Settings.GetValue(For: SettingKey!)
        {
            Result in
            switch Result
            {
                case .failure(let Error):
                    print("\(#function): Error getting value for \(SettingKey!): \(Error)")
                    
                case .success(let (SettingValue, _)):
                    Final = (SettingValue, SettingType)
            }
        }
        return Final
    }
    
    func SetDirty(_ Key: SettingKeys)
    {
        var Found = false
        var Index = 0
        for (Name, _, _, _) in SettingsData
        {
            if Name == "\(Key)"
            {
                Found = true
                break
            }
            Index = Index + 1
        }
        if Found
        {
            let (Name, Type, _, Editor) = SettingsData[Index]
            let New: (Name: String, Type: String, IsDirty: Bool, Editor: NSViewController?) = (Name, Type, true, Editor)
            SettingsData[Index] = New
            SettingsTable.reloadData()
        }
    }
    
    func ClearDirty(_ Key: SettingKeys)
    {
        var Found = false
        var Index = 0
        for (Name, _, _, _) in SettingsData
        {
            if Name == "\(Key)"
            {
                Found = true
                break
            }
            Index = Index + 1
        }
        if Found
        {
            let (Name, Type, _, Editor) = SettingsData[Index]
            let New: (Name: String, Type: String, IsDirty: Bool, Editor: NSViewController?) = (Name, Type, false, Editor)
            SettingsData[Index] = New
            SettingsTable.reloadData()
        }
    }
    
    @IBOutlet weak var SettingsTable: NSTableView!
    @IBOutlet weak var EditorSink: ContainerController!
    
    enum SettingDescriptors: String
    {
        case SettingKey = "SettingKey"
        case SettingType = "SettingType"
    }
    
    let EnumFields =
    [
        "MapTypes",
        "ViewTypes",
        "HourValueTypes",
        "TimeLabels",
        "Scripts",
        "SunNames",
        "StarSpeeds",
        "PolarShapes",
        "CameraProjections",
        "HomeShapes",
        "CityDisplayTypes",
        "PopulationTypes",
        "SiteTypeFilters",
        "EarthquakeColorMethods",
        "EarthquakeShapes",
        "EarthquakeListStyles",
        "EarthquakeRecents",
        "EarthquakeTextures",
        "EarthquakeIndicators",
        "EarthquakeIndicators2D",
        "EarthquakeAges",
        "EarthquakeMagnitudeViews",
        "NotificationLocations",
        "SettingGroups",
        "TimeControls"
    ]
    
    let TypeEditorMap =
        [
            "Int": "GeneralTypeEditor",
            "Double": "GeneralTypeEditor",
            "Double?": "GeneralTypeEditor",
            "CGFloat": "GeneralTypeEditor",
            "CGFloat?": "GeneralTypeEditor",
            "String": "GeneralTypeEditor",
            
            "Bool": "BoolTypeEditor",
            
            "NSColor": "ColorTypeEditor",
            
            "Date": "DateTimeEditor",
            
            "SCNVector3": "VectorTypeEditor",
            
            "MapTypes": "EnumTypeEditor",
            "ViewTypes": "EnumTypeEditor",
            "HourValueTypes": "EnumTypeEditor",
            "TimeLabels": "EnumTypeEditor",
            "Scripts": "EnumTypeEditor",
            "SunNames": "EnumTypeEditor",
            "StarSpeeds": "EnumTypeEditor",
            "PolarShapes": "EnumTypeEditor",
            "CameraProjections": "EnumTypeEditor",
            "HomeShapes": "EnumTypeEditor",
            "CityDisplayTypes": "EnumTypeEditor",
            "PopulationTypes": "EnumTypeEditor",
            "SiteTypeFilters": "EnumTypeEditor",
            "EarthquakeColorMethods": "EnumTypeEditor",
            "EarthquakeShapes": "EnumTypeEditor",
            "EarthquakeListStyles": "EnumTypeEditor",
            "EarthquakeRecents": "EnumTypeEditor",
            "EarthquakeTextures": "EnumTypeEditor",
            "EarthquakeIndicators": "EnumTypeEditor",
            "EarthquakeIndicators2D": "EnumTypeEditor",
            "EarthquakeAges": "EnumTypeEditor",
            "EarthquakeMagnitudeViews": "EnumTypeEditor",
            "NotificationLocations": "EnumTypeEditor",
            "SettingGroups": "EnumTypeEditor",
            "TimeControls": "EnumTypeEditor"
        ]
    
    func CreateEditorDialog(_ IDName: String) -> NSViewController?
    {
        if let Controller = NSStoryboard(name: "RawSettingsEditor", bundle: nil).instantiateController(withIdentifier: IDName) as? NSViewController
        {
            return Controller
        }
        fatalError("Error creating \(IDName)")
    }
}

class RawEditorEntry
{
    init(_ Controller: NSViewController?)
    {
        self.Controller = Controller
    }
    
    public var Controller: NSViewController? = nil
}
