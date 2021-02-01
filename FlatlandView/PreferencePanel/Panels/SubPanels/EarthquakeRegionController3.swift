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
                                   NSControlTextEditingDelegate, SettingChangedProtocol
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
        
        HelpButtons.append(RegionTypeHelpButton)
        HelpButtons.append(EnableRegionHelpButton)
        HelpButtons.append(ShowNotificationsHelpButton)
        HelpButtons.append(RegionColorHelpButton)
        HelpButtons.append(QuakeAgeHelpButton)
        HelpButtons.append(MagRangeHelpButton)
        HelpButtons.append(RegionNameHelpButton)
        HelpButtons.append(PolarRegionsHelpButton)
        HelpButtons.append(RectangularRegionHelpButton)
        HelpButtons.append(ClearRegionsHelpButton)
        HelpButtons.append(DeleteRegionHelpButton)
        HelpButtons.append(NewRegionHelpButton)
        SetHelpVisibility(To: Settings.GetBool(.ShowUIHelp))
    }
    
    var QuakeWindowID: UUID = UUID()
    func SubscriberID() -> UUID
    {
        return QuakeWindowID
    }
    
    func SettingChanged(Setting: SettingKeys, OldValue: Any?, NewValue: Any?)
    {
        switch Setting
        {
            case .ShowUIHelp:
                SetHelpVisibility(To: Settings.GetBool(.ShowUIHelp))
                
            default:
                break
        }
    }
    
    var IsDirty = false
    
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
    @discardableResult func RunMessageBoxOK(Message: String, InformationMessage: String) -> Bool
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
    
    func ValidateRawCoordinate(_ RawLat: String, _ RawLon: String, _ Which: String) -> (Double, Double)?
    {
        var WorkingLat: Double = 0.0
        var WorkingLon: Double = 0.0
        let LatResults = InputValidation.LatitudeValidation(RawLat)
        switch LatResults
        {
            case .failure(let Why):
                RunMessageBoxOK(Message: "Invalid latitude for \(Which). Please enter a valid latitude.", InformationMessage: "\(Why)")
                return nil
                
            case .success(let OKLat):
                WorkingLat = OKLat
        }
        let LonResults = InputValidation.LongitudeValidation(RawLon)
        switch LonResults
        {
            case .failure(let Why):
                RunMessageBoxOK(Message: "Invalid longitude for \(Which). Please enter a valid longitude.", InformationMessage: "\(Why)")
                return nil
                
            case .success(let OKLon):
                WorkingLon = OKLon
        }
        return (WorkingLat, WorkingLon)
    }
    
    func PopulateRegionFromUI() -> Bool
    {
        if let Region = CurrentRegion
        {
            let RegionName = RegionNameField.stringValue
            if RegionName.isEmpty
            {
                RunMessageBoxOK(Message: "Region name is empty. Please enter a valid name.",
                                InformationMessage: "Every region must have a name.")
                return false
            }
            Region.RegionName = RegionName
            let RawRadius = CircularRadius.stringValue
            let RadiusResult = InputValidation.DistanceValidation(RawRadius)
            switch RadiusResult
            {
                case .failure(let Why):
                    RunMessageBoxOK(Message: "Invalid radius. Please enter a number greater than 0.0", InformationMessage: "\(Why)")
                    return false
                    
                case .success(let (Value, Units)):
                    if Units == .Kilometers
                    {
                        Region.Radius = Value
                    }
                    else
                    {
                        Region.Radius = Value * PhysicalConstants.MilesToKilometers.rawValue
                    }
            }
            Region.RegionColor = RegionColorWell.color
            Region.IsRectangular = RegionTypeSegment.selectedSegment == 0
            Region.IsEnabled = EnableRegionSwitch.state == .on ? true : false
            Region.NotifyOnNewEarthquakes = ShowNotificationSwitch.state == .on ? true : false
            Region.Age = AgeCombo.indexOfSelectedItem
            let RawMinMag = MinMagField.stringValue
            let RawMaxMag = MaxMagField.stringValue
            if let MinMag = Double(RawMinMag)
            {
                if var MaxMag = Double(RawMaxMag)
                {
                    if MinMag > MaxMag
                    {
                        MaxMag = 9.99
                    }
                    Region.MinimumMagnitude = MinMag
                    Region.MaximumMagnitude = MaxMag
                }
                else
                {
                    RunMessageBoxOK(Message: "Invalid maximum magnitude value.", InformationMessage: "Please enter a valid number.")
                }
            }
            else
            {
                RunMessageBoxOK(Message: "Invalid minimum magnitude value.", InformationMessage: "Please enter a valid number.")
            }
            if Region.IsRectangular
            {
                if let (ULLat, ULLon) = ValidateRawCoordinate(UpperLeftLat.stringValue, UpperLeftLon.stringValue, "upper-left corner")
                {
                    Region.UpperLeft.Latitude = ULLat
                    Region.UpperLeft.Longitude = ULLon
                }
                else
                {
                    return false
                }
                if let (LRLat, LRLon) = ValidateRawCoordinate(LowerRightLat.stringValue, LowerRightLon.stringValue, "lower-right corner")
                {
                    Region.LowerRight.Latitude = LRLat
                    Region.LowerRight.Longitude = LRLon
                }
                else
                {
                    return false
                }
            }
        }
        return true
    }
    
    /// Close the color panel if it is visible.
    func CloseColorPanel()
    {
        if NSColorPanel.sharedColorPanelExists
        {
            if NSColorPanel.shared.isVisible
            {
                NSColorPanel.shared.close()
            }
        }
    }
    
    @IBAction func OKButtonHandler(_ sender: Any)
    {
        if RegionTable.selectedRow > -1
        {
            if PopulateRegionFromUI()
            {
                CloseColorPanel()
                let Window = self.view.window
                let Parent = Window?.sheetParent
                Settings.SetEarthquakeRegions(RegionList)
                Parent?.endSheet(Window!, returnCode: .OK)
            }
        }
        else
        {
            CloseColorPanel()
            let Window = self.view.window
            let Parent = Window?.sheetParent
            Settings.SetEarthquakeRegions(RegionList)
            Parent?.endSheet(Window!, returnCode: .OK)
        }
    }
    
    @IBAction func CancelButtonHandler(_ sender: Any)
    {
        CloseColorPanel()
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
            CircularRadius.stringValue = "\(Item.Radius.RoundedTo(1))"
            CircularLatitude.stringValue = Utility.PrettyLatitude(Item.Center.Latitude)
            CircularLongitude.stringValue = Utility.PrettyLongitude(Item.Center.Longitude)
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
        CircularLatitude.stringValue = ""
        CircularLongitude.stringValue = ""
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
            CloseColorPanel()
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
                        let Result = InputValidation.LatitudeValidation(TextValue)
                        switch Result
                        {
                            case .success(let Final):
                                Region.UpperLeft.Latitude = Final
                                IsDirty = true
                                
                            default:
                                break
                        }
                        
                    case UpperLeftLon:
                        let Result = InputValidation.LongitudeValidation(TextValue)
                        switch Result
                        {
                            case .success(let Final):
                                Region.UpperLeft.Longitude = Final
                                IsDirty = true
                                
                            default:
                                break
                        }
                        
                    case LowerRightLat:
                        let Result = InputValidation.LatitudeValidation(TextValue)
                        switch Result
                        {
                            case .success(let Final):
                                Region.LowerRight.Latitude = Final
                                IsDirty = true
                                
                            default:
                                break
                        }
                        
                    case LowerRightLon:
                        let Result = InputValidation.LongitudeValidation(TextValue)
                        switch Result
                        {
                            case .success(let Final):
                                Region.LowerRight.Longitude = Final
                                IsDirty = true
                                
                            default:
                                break
                        }
                        
                    case CircularRadius:
                        if let Radius = Double(TextValue)
                        {
                            if Radius > 0.0
                            {
                                print("Setting new radius: \(Radius)")
                                Region.Radius = Radius
                                IsDirty = true
                            }
                        }
                        
                    case CircularLatitude:
                        let Result = InputValidation.LatitudeValidation(TextValue)
                        switch Result
                        {
                            case .success(let Final):
                                Region.Center.Latitude = Final
                                IsDirty = true
                                
                            default:
                                break
                        }
                        
                    case CircularLongitude:
                        let Result = InputValidation.LongitudeValidation(TextValue)
                        switch Result
                        {
                            case .success(let Final):
                                Region.Center.Longitude = Final
                                IsDirty = true
                                
                            default:
                                break
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
    
    var HelpButtons: [NSButton] = [NSButton]()
    
    func SetHelpVisibility(To: Bool)
    {
        for Button in HelpButtons
        {
            Button.alphaValue = To ? 1.0 : 0.0
            Button.isEnabled = To ? true : false
        }
    }
    
    // MARK: - Interface builder outlets.
    
    @IBOutlet weak var CircularLongitude: NSTextField!
    @IBOutlet weak var CircularLatitude: NSTextField!
    @IBOutlet weak var UpperLeftLat: NSTextField!
    @IBOutlet weak var UpperLeftLon: NSTextField!
    @IBOutlet weak var LowerRightLat: NSTextField!
    @IBOutlet weak var LowerRightLon: NSTextField!
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
    
    // MARK: - Help buttons
    
    @IBOutlet weak var RegionTypeHelpButton: NSButton!
    @IBOutlet weak var EnableRegionHelpButton: NSButton!
    @IBOutlet weak var ShowNotificationsHelpButton: NSButton!
    @IBOutlet weak var RegionColorHelpButton: NSButton!
    @IBOutlet weak var QuakeAgeHelpButton: NSButton!
    @IBOutlet weak var MagRangeHelpButton: NSButton!
    @IBOutlet weak var RegionNameHelpButton: NSButton!
    @IBOutlet weak var PolarRegionsHelpButton: NSButton!
    @IBOutlet weak var RectangularRegionHelpButton: NSButton!
    @IBOutlet weak var ClearRegionsHelpButton: NSButton!
    @IBOutlet weak var DeleteRegionHelpButton: NSButton!
    @IBOutlet weak var NewRegionHelpButton: NSButton!
}
