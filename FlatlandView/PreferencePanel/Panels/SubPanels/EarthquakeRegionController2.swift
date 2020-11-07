//
//  EarthquakeRegionController2.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class EarthquakeRegionController2: NSViewController, NSTextFieldDelegate,
                                   NSTableViewDelegate, NSTableViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Regions = Settings.GetEarthquakeRegions()
    }
    
    override func viewDidLayout()
    {
        super.viewDidLayout()
        UpdateButton.toolTip = "Save your changes to the earthquake region."
        NewButton.toolTip = "Clears the input fields and lets you create a new region."
    }
    
    /// Call to initialize the edit fields with an initial set of data to create a region.
    func SetInitialData(Center: GeoPoint, Radius: Double)
    {
        
    }
    
    func SetInitialData(UpperLeft: GeoPoint, LowerRight: GeoPoint)
    {
        
    }
    
    var Regions = [EarthquakeRegion]()
    
    var DialogIsModal = false
    
    func IsModal(_ Modal: Bool)
    {
        DialogIsModal = Modal
        OKButton.isHidden = Modal
        CancelButton.isHidden = Modal
        CloseButton.isHidden = !Modal
    }
    
    func GetSelectedIndex() -> Int?
    {
        let Selected = RegionTable.selectedRow
        if Selected < 0
        {
            return nil
        }
        return Selected
    }
    
    @IBAction func HandleDeleteButton(_ sender: Any)
    {
        if let SelectedIndex = GetSelectedIndex()
        {
        let Storyboard = NSStoryboard(name: "SubPanels", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "DeleteConfirmationWindow") as? DeleteConfirmationWindow
        {
            let Window = WindowController.window
            if let Controller = Window?.contentViewController as? DeleteConfirmationController
            {
                let RegionName = Regions[SelectedIndex].RegionName
                Controller.SetConfirmationText("Really delete \"\(RegionName)\"? You cannot undo this operation.")
                self.view.window?.beginSheet(Window!)
                {
                    Result in
                    if Result == .OK
                    {
                        self.Regions.remove(at: SelectedIndex)
                        self.SaveRegions()
                        self.RegionTable.reloadData()
                    }
                }
            }
        }
        }
    }
    
    func SaveRegions()
    {
        Settings.SetEarthquakeRegions(Regions)
    }
    
    @IBAction func HandleNewButton(_ sender: Any)
    {
        RegionLeft.stringValue = ""
        RegionRight.stringValue = ""
        RegionUpper.stringValue = ""
        RegionLower.stringValue = ""
        RegionCenterLatitude.stringValue = ""
        RegionCenterLongitude.stringValue = ""
        RegionRadius.stringValue = ""
        MinMagText.stringValue = ""
        MaxMagText.stringValue = ""
        RegionName.stringValue = ""
        RegionColor.color = NSColor.white
        let SelectedRow = RegionTable.selectedRow
        if SelectedRow > -1
        {
            //            RegionTable.deselectRow(SelectedRow)
            RegionTable.deselectAll(self)
        }
    }
    
    func controlTextDidEndEditing(_ obj: Notification)
    {
        if let TextField = obj.object as? NSTextField
        {
            let Raw = TextField.stringValue
            switch TextField
            {
                case RegionName:
                    break
                    
                case MinMagText:
                    break
                    
                case MaxMagText:
                    break
                    
                case RegionUpper:
                    break
                    
                case RegionLower:
                    break
                    
                case RegionRight:
                    break
                    
                case RegionLeft:
                    break
                    
                case RegionCenterLatitude:
                    break
                    
                case RegionCenterLongitude:
                    break
                    
                case RegionRadius:
                    break
                    
                default:
                    return
            }
        }
    }
    
    @IBAction func HandleRectangularRegionSwitchChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            let IsRectangle = Switch.state == .on
            RegionCenterLongitude.isEnabled = !IsRectangle
            RegionCenterLatitude.isEnabled = !IsRectangle
            RegionRadius.isEnabled = !IsRectangle
            RegionLeft.isEnabled = IsRectangle
            RegionRight.isEnabled = IsRectangle
            RegionUpper.isEnabled = IsRectangle
            RegionLower.isEnabled = IsRectangle
        }
    }
    
    @IBAction func HandleRegionColorChanged(_ sender: Any)
    {
    }
    
    // MARK: - Table handling
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return Regions.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "RegionNameColumn"
            CellContents = Regions[row].RegionName
        }
        if tableColumn == tableView.tableColumns[1]
        {
            let Color = Regions[row].RegionColor
            let Swatch = NSView(frame: NSRect(x: 5, y: 2, width: 40, height: 20))
            Swatch.wantsLayer = true
            Swatch.layer?.backgroundColor = Color.cgColor
            Swatch.layer?.borderColor = NSColor.black.cgColor
            Swatch.layer?.borderWidth = 0.5
            Swatch.layer?.cornerRadius = 5.0
            return Swatch
        }
        
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification)
    {
        if let NewSelection = GetSelectedIndex()
        {
            print("Selected row \(NewSelection)")
        }
    }
    
    // MARK: Button handling.
    
    @IBAction func HandleCloseButton(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent?.endSheet(Window!, returnCode: .OK)
    }
    
    @IBAction func HandleCancelButton(_ sender: Any)
    {
        self.view.window?.close()
    }
    
    @IBAction func HandleOKButton(_ sender: Any)
    {
        self.view.window?.close()
    }
    
    @IBAction func HandleClearButtonPressed(_ sender: Any)
    {

    }
    
    @IBAction func HandleUpdateButton(_ sender: Any)
    {
    }
    
    @IBOutlet weak var NewButton: NSButton!
    @IBOutlet weak var UpdateButton: NSButton!
    @IBOutlet weak var RegionTable: NSTableView!
    @IBOutlet weak var RegionLeft: NSTextField!
    @IBOutlet weak var RegionRight: NSTextField!
    @IBOutlet weak var RegionCenterLongitude: NSTextField!
    @IBOutlet weak var RegionColor: NSColorWell!
    @IBOutlet weak var RegionUpper: NSTextField!
    @IBOutlet weak var RegionLower: NSTextField!
    @IBOutlet weak var RegionCenterLatitude: NSTextField!
    @IBOutlet weak var RegionRadius: NSTextField!
    @IBOutlet weak var RectangularRegionSwitch: NSSwitch!
    @IBOutlet weak var MaxMagText: NSTextField!
    @IBOutlet weak var MinMagText: NSTextField!
    @IBOutlet weak var RegionName: NSTextField!
    @IBOutlet weak var OKButton: NSButton!
    @IBOutlet weak var CloseButton: NSButton!
    @IBOutlet weak var CancelButton: NSButton!
}
