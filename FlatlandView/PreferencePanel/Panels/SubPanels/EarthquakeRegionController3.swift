//
//  EarthquakeRegionController3.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/9/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class EarthquakeRegionController3: NSViewController, NSTableViewDelegate, NSTableViewDataSource,
                                   NSControlTextEditingDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        AgeCombo.removeAllItems()
        for Day in 1 ... 30
        {
            let Plural = Day == 1 ? "" : "s"
            AgeCombo.addItem(withObjectValue: "\(Day) day\(Plural)")
        }
        SaveChangesButton.isHidden = true
        RegionList = Settings.GetEarthquakeRegions()
        RegionTable.reloadData()
    }
    
    var IsDirty = false
    
    // MARK: - Initialization.
    
    var RegionList = [UserRegion]()
    
    // MARK: - UI handling.
    
    @IBAction func AddRegionButtonHandler(_ sender: Any)
    {
        SaveChangesButton.isHidden = false
        ClearEditor()
        CurrentRegion = UserRegion()
        IsDirty = true
    }
    
    @IBAction func DeleteRegionButtonHandler(_ sender: Any)
    {
        if RegionTable.selectedRow < 0
        {
            return
        }
        RegionList.remove(at: RegionTable.selectedRow)
        RegionTable.reloadData()
        ClearEditor()
    }
    
    //https://stackoverflow.com/questions/29433487/create-an-nsalert-with-swift
    func RunMessageBoxOK(Message: String, InformationMessage: String) -> Bool
    {
        let Alert = NSAlert()
        Alert.messageText = Message
        Alert.informativeText = InformationMessage
        Alert.alertStyle = .warning
        Alert.addButton(withTitle: "Clear All")
        Alert.addButton(withTitle: "Cancel")
        return Alert.runModal() == .alertFirstButtonReturn
    }
    
    @IBAction func ClearRegionsButtonHandler(_ sender: Any)
    {
        let DoClearAll = RunMessageBoxOK(Message: "Do you really want to delete all regions?",
                                         InformationMessage: "All of your defined earthquake regions will be deleted.")
        if DoClearAll
        {
            RegionList.removeAll()
            RegionTable.reloadData()
        }
    }
    
    @IBAction func OKButtonHandler(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        print("Saving changed region list.")
        Settings.SetEarthquakeRegions(RegionList)
        Parent?.endSheet(Window!, returnCode: .OK)
    }
    
    @IBAction func CancelButtonHandler(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent?.endSheet(Window!, returnCode: .cancel)
    }
    
    @IBAction func SaveChangesButtonHandler(_ sender: Any)
    {
        SaveChangesButton.isHidden = true
        if let Region = CurrentRegion
        {
            RegionList.append(Region)
        }
        CurrentRegion = nil
        RegionTable.reloadData()
    }
    
    @IBAction func HandleAgeComboChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            let Index = Combo.indexOfSelectedItem
            if let Region = CurrentRegion
            {
                Region.Age = Index
                IsDirty = true
            }
        }
    }
    
    @IBAction func RegionColorWellHandler(_ sender: Any)
    {
        if let ColorWell = sender as? NSColorWell
        {
            if let Region = CurrentRegion
            {
                Region.RegionColor = ColorWell.color
                IsDirty = true
            }
        }
    }
    
    @IBAction func HandleSwitchChanges(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            switch Switch
            {
                case EnableRegionSwitch:
                    if let Region = CurrentRegion
                    {
                        Region.IsEnabled = Switch.state == .on ? true : false
                        IsDirty = true
                    }
                    
                case ShowNotificationSwitch:
                    if let Region = CurrentRegion
                    {
                        Region.NotifyOnNewEarthquakes = Switch.state == .on ? true: false
                        IsDirty = true
                    }
                    
                default:
                    return
            }
        }
    }
    
    @IBAction func RegionTypeChangedHandler(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            switch Segment.selectedSegment
            {
                case 0:
                    RectangleBox.isHidden = false
                    CircleBox.isHidden = true
                    if let Region = CurrentRegion
                    {
                        Region.IsRectangular = true
                        IsDirty = true
                    }
                    
                case 1:
                    RectangleBox.isHidden = true
                    CircleBox.isHidden = false
                    if let Region = CurrentRegion
                    {
                        Region.IsRectangular = false
                        IsDirty = true
                    }
                    
                default:
                    RectangleBox.isHidden = false
                    CircleBox.isHidden = false
            }
        }
    }
    
    func PopulateWithRow(_ Row: Int)
    {
        if Row >= RegionList.count
        {
            Debug.Print("Specified Row{\(Row)} greater than number of regions (\(RegionList.count))")
            return
        }
        let Item = RegionList[Row]
        CurrentRegion = Item
        RegionNameField.stringValue = Item.RegionName
        MinMagField.stringValue = "\(Item.MinimumMagnitude.RoundedTo(1))"
        MaxMagField.stringValue = "\(Item.MaximumMagnitude.RoundedTo(1))"
        let Age = Item.Age
        if Age > AgeCombo.numberOfItems - 1
        {
            AgeCombo.selectItem(at: AgeCombo.numberOfItems - 1)
        }
        else
        {
            AgeCombo.selectItem(at: Age)
        }
        RegionColorWell.color = Item.RegionColor
        ShowNotificationSwitch.state = Item.NotifyOnNewEarthquakes ? .on : .off
        EnableRegionSwitch.state = Item.IsEnabled ? .on : .off
        if Item.IsRectangular
        {
            RegionTypeSegment.selectedSegment = 0
            RectangleBox.isHidden = false
            CircleBox.isHidden = true
            UpperLeftLat.stringValue = Utility.PrettyLatitude(Item.UpperLeft.Latitude)
            UpperLeftLon.stringValue = Utility.PrettyLongitude(Item.UpperLeft.Longitude)
            LowerRightLat.stringValue = Utility.PrettyLatitude(Item.LowerRight.Latitude)
            LowerRightLon.stringValue = Utility.PrettyLongitude(Item.LowerRight.Longitude)
        }
        else
        {
            RegionTypeSegment.selectedSegment = 1
            RectangleBox.isHidden = true
            CircleBox.isHidden = false
            CenterLat.stringValue = Utility.PrettyLatitude(Item.Center.Latitude)
            CenterLon.stringValue = Utility.PrettyLongitude(Item.Center.Longitude)
            CircularRadius.stringValue = "\(Item.Radius.RoundedTo(1))"
        }
    }
    
    var CurrentRegion: UserRegion? = nil
    
    func ClearEditor()
    {
        RegionNameField.stringValue = ""
        MinMagField.stringValue = "5.0"
        MaxMagField.stringValue = "9.9"
        AgeCombo.selectItem(at: 29)
        RegionColorWell.color = NSColor.cyan
        ShowNotificationSwitch.state = .off
        EnableRegionSwitch.state = .on
        UpperLeftLat.stringValue = ""
        UpperLeftLon.stringValue = ""
        LowerRightLat.stringValue = ""
        LowerRightLon.stringValue = ""
        CenterLat.stringValue = ""
        CenterLon.stringValue = ""
        CircularRadius.stringValue = ""
        RegionTypeSegment.selectedSegment = 0
        RectangleBox.isHidden = false
        CircleBox.isHidden = true
    }
    
    // MARK: - Table handling.
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return RegionList.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "RegionNameColumn"
            CellContents = RegionList[row].RegionName
        }
        else
        {
            return nil
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification)
    {
        let NewRow = RegionTable.selectedRow
        if NewRow > -1
        {
            if IsDirty
            {
                RegionTable.reloadData()
            }
            IsDirty = false
            SaveChangesButton.isHidden = true
            PopulateWithRow(NewRow)
        }
    }
    
    // MARK: - Text handling.
    
    func controlTextDidEndEditing(_ obj: Notification)
    {
        if let TextField = obj.object as? NSTextField
        {
            let TextValue = TextField.stringValue
            if let Region = CurrentRegion
            {
                switch TextField
                {
                    case RegionNameField:
                        Region.RegionName = TextValue
                        IsDirty = true
                        
                    case MinMagField:
                        if let MinMag = Double(TextValue)
                        {
                            if MinMag > Region.MaximumMagnitude
                            {
                                Region.MaximumMagnitude = 9.9
                            }
                            else
                            {
                                Region.MinimumMagnitude = abs(MinMag)
                            }
                            IsDirty = true
                        }
                        
                    case MaxMagField:
                        if let MaxMag = Double(TextValue)
                        {
                            if Region.MinimumMagnitude > MaxMag
                            {
                                Region.MaximumMagnitude = 9.9
                            }
                            else
                            {
                                Region.MaximumMagnitude = abs(MaxMag)
                            }
                            IsDirty = true
                        }
                        
                    case UpperLeftLat:
                        if let Region = CurrentRegion
                        {
                            let Result = InputValidation.LatitudeValidation(TextValue)
                            switch Result
                            {
                                case .success(let Final):
                                    Region.UpperLeft.Latitude = Final
                                    IsDirty = true
                                    
                                default:
                                    break
                            }
                        }
                        
                    case UpperLeftLon:
                        if let Region = CurrentRegion
                        {
                            let Result = InputValidation.LongitudeValidation(TextValue)
                            switch Result
                            {
                                case .success(let Final):
                                    Region.UpperLeft.Longitude = Final
                                    IsDirty = true
                                    
                                default:
                                    break
                            }
                        }
                        
                    case LowerRightLat:
                        if let Region = CurrentRegion
                        {
                            let Result = InputValidation.LatitudeValidation(TextValue)
                            switch Result
                            {
                                case .success(let Final):
                                    Region.LowerRight.Latitude = Final
                                    IsDirty = true
                                    
                                default:
                                    break
                            }
                        }
                        
                    case LowerRightLon:
                        if let Region = CurrentRegion
                        {
                            let Result = InputValidation.LongitudeValidation(TextValue)
                            switch Result
                            {
                                case .success(let Final):
                                    Region.LowerRight.Longitude = Final
                                    IsDirty = true
                                    
                                default:
                                    break
                            }
                        }
                        
                    case CenterLat:
                        if let Region = CurrentRegion
                        {
                            let Result = InputValidation.LatitudeValidation(TextValue)
                            switch Result
                            {
                                case .success(let Final):
                                    Region.Center.Latitude = Final
                                    IsDirty = true
                                    
                                default:
                                    break
                            }
                        }
                        
                    case CenterLon:
                        if let Region = CurrentRegion
                        {
                            let Result = InputValidation.LongitudeValidation(TextValue)
                            switch Result
                            {
                                case .success(let Final):
                                    Region.Center.Longitude = Final
                                    IsDirty = true
                                    
                                default:
                                    break
                            }
                        }
                        
                    case CircularRadius:
                        if let Radius = Double(TextValue)
                        {
                            if Radius > 0.0
                            {
                                Region.Radius = Radius
                                IsDirty = true
                            }
                        }
                        
                    default:
                        break
                }
            }
        }
    }
    
    // MARK: - Help functionality.
    
    @IBAction func RegionHelpButtonHandler(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            var Message = "Help text not found."
            let MessageData = HelpMessages.filter({$0.Index == Button.tag})
            if MessageData.count == 1
            {
                Message = MessageData[0].Message
            }
            if let PopController = NSStoryboard(name: "PreferenceHelpViewer", bundle: nil).instantiateController(withIdentifier: "PreferenceHelpViewer") as? PreferenceHelpPopover
            {
                Pop = NSPopover()
                Pop?.contentSize = NSSize(width: 427, height: 237)
                Pop?.behavior = .semitransient
                Pop?.animates = true
                Pop?.contentViewController = PopController
                PopController.SetHelpText(Message)
                Pop?.show(relativeTo: Button.bounds, of: Button, preferredEdge: .maxY)
            }
            else
            {
                Debug.Print("Error creating help viewer.")
            }
        }
    }
    
    var Pop: NSPopover? = nil
    
    let HelpMessages: [(Index: Int, Message: String)] =
        [
            (1, "Enter your name for the region you are defining."),
            (2, "The minimum and maximum magnitudes to display in the region. If the maximum is lower than the minimum, the maximum is set to 9.9."),
            (3, "How long earthquakes should be displayed in the region, in days."),
            (4, "The color to use for the region."),
            (5, "Show notifications when new earthquakes happen in the region."),
            (6, "Enable or disable the region. If disabled, the region is ignored when plotting earthquakes."),
            (7, "Determines the shape of the region."),
            (8, "Define a rectangular region. The Upper left coordinate is to the north and west of the Lower right coordinate."),
            (9, "Define a circular region. The radius uses your system's default units (kilometers or miles)."),
            (10, "Add a new region."),
            (11, "Delete the selected region."),
            (12, "Clear/deletes all regions.")
        ]
    
    // MARK: - Interface builder outlets.
    
    @IBOutlet weak var UpperLeftLat: NSTextField!
    @IBOutlet weak var UpperLeftLon: NSTextField!
    @IBOutlet weak var LowerRightLat: NSTextField!
    @IBOutlet weak var LowerRightLon: NSTextField!
    @IBOutlet weak var CenterLat: NSTextField!
    @IBOutlet weak var CenterLon: NSTextField!
    @IBOutlet weak var CircularRadius: NSTextField!
    @IBOutlet weak var RegionTypeSegment: NSSegmentedControl!
    @IBOutlet weak var EnableRegionSwitch: NSSwitch!
    @IBOutlet weak var ShowNotificationSwitch: NSSwitch!
    @IBOutlet weak var RegionColorWell: NSColorWell!
    @IBOutlet weak var AgeCombo: NSComboBox!
    @IBOutlet weak var RegionTable: NSTableView!
    @IBOutlet weak var RegionNameField: NSTextField!
    @IBOutlet weak var MinMagField: NSTextField!
    @IBOutlet weak var MaxMagField: NSTextField!
    @IBOutlet weak var RectangleBox: NSBox!
    @IBOutlet weak var CircleBox: NSBox!
    @IBOutlet weak var SaveChangesButton: NSButton!
}
