//
//  UserPOIEditorController.swift
//  Flatland
//
//  Created by Stuart Rankin on 2/6/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class UserPOIEditorController: NSViewController, NSTableViewDelegate, NSTableViewDataSource
{
    public weak var MainDelegate: MainProtocol? = nil
    var Parent: NSWindow? = nil
    var Window: NSWindow? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidLayout()
    {
        super.viewDidLayout()
        Window = self.view.window
        Parent = Window?.sheetParent
        ResetEditor()
        LoadData()
    }
    
    // MARK: - Table handling.
    
    func LoadData()
    {
        let POIs = MainDelegate?.GetUserPOIData()
        let Cities = MainDelegate?.GetAdditionalCityData()
        UserTable.removeAll()
        if let POIData = POIs
        {
            for POI in POIData
            {
                UserTable.append(LocationContainer(With: POI))
            }
        }
        if let CityData = Cities
        {
            for City in CityData
            {
                UserTable.append(LocationContainer(With: City))
            }
        }
        UserTable.sort(by: {$0.LocationName < $1.LocationName})
        POITable.reloadData()
    }
    
    var UserTable = [LocationContainer]()
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return UserTable.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "NameColumn"
            CellContents = UserTable[row].LocationName
        }
        if tableColumn == tableView.tableColumns[1]
        {
            CellIdentifier = "TypeColumn"
            CellContents = UserTable[row].IsCity ? "City" : "POI"
        }
        var TextColor = NSColor.controlTextColor
        if UserTable[row].Deleted
        {
            TextColor = NSColor.disabledControlTextColor
        }
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        Cell?.textField?.stringValue = CellContents
        Cell?.textField?.textColor = TextColor
        return Cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification)
    {
        let Index = POITable.selectedRow
    }
    
    // MARK: - Button handling.
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        Parent?.endSheet(Window!, returnCode: .cancel)
    }
    
    func GetDataFromContainer(DirtyCity: inout Bool, DirtyPOI: inout Bool) -> ([City2], [POI2])
    {
        DirtyCity = false
        DirtyPOI = false
        var Cities = [City2]()
        var POIs = [POI2]()
        for Container in UserTable
        {

            if Container.IsCity
            {
                Cities.append(Container.City!)
                if Container.IsDirty
                {
                    DirtyCity = true
                }
            }
            else
            {
                POIs.append(Container.POI!)
                if Container.IsDirty
                {
                    DirtyPOI = true
                }
            }
        }
        return (Cities, POIs)
    }
    
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        var DirtyCities: Bool = false
        var DirtyPOIs: Bool = false
        let (CityList, POIList) = GetDataFromContainer(DirtyCity: &DirtyCities, DirtyPOI: &DirtyPOIs)
        if DirtyCities
        {
            MainDelegate?.SetAdditionalCityData(CityList)
        }
        if DirtyPOIs
        {
            MainDelegate?.SetUserPOIData(POIList)
        }
        Parent?.endSheet(Window!, returnCode: .OK)
    }
    
    @IBAction func HandleEditButton(_ sender: Any)
    {
    }
    
    @IBAction func HandleNewButton(_ sender: Any)
    {
        SaveNewDataButton.isHidden = false
    }
    
    @IBAction func HandleDeleteButton(_ sender: Any)
    {
        let Index = POITable.selectedRow
        guard Index > -1 else
        {
            return
        }
        let Message = "Do you really want to delete the selected item?"
        let IsCity = UserTable[Index].IsCity ? "city" : "POI"
        let Name = UserTable[Index].LocationName
        let InfoMessage = "This action will remove the \(IsCity) \"\(Name)\"."
        if !RunMessageBoxOK(Message: Message, InformationMessage: InfoMessage)
        {
            UserTable[Index].Deleted = true
            UserTable[Index].IsDirty = true
        }
        POITable.reloadData()
    }
    
    @IBAction func HandleSaveNewDataButton(_ sender: Any)
    {
        SaveNewDataButton.isHidden = true
    }
    
    // MARK: - Editor handling.
    
    //https://stackoverflow.com/questions/29433487/create-an-nsalert-with-swift
    @discardableResult func RunMessageBoxOK(Message: String, InformationMessage: String) -> Bool
    {
        let Alert = NSAlert()
        Alert.messageText = Message
        Alert.informativeText = InformationMessage
        Alert.alertStyle = .warning
        Alert.addButton(withTitle: "Cancel")
        Alert.addButton(withTitle: "OK")
        return Alert.runModal() == .alertFirstButtonReturn
    }
    
    func ResetEditor()
    {
        NameField.stringValue = ""
        POITypeSegement.selectedSegment = 0
        LatitudeField.stringValue = ""
        LongitudeField.stringValue = ""
        POIColorWell.color = NSColor.TeaGreen
        PopulationField.isHidden = false
        PopulationField.stringValue = ""
        PopulationLabel.isHidden = false
        ShowSwitch.state = .on
        SaveNewDataButton.isHidden = true
    }
    
    @IBAction func HandlePOITypeChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            PopulationLabel.isHidden = Segment.selectedSegment == 0 ? false : true
            PopulationField.isHidden = Segment.selectedSegment == 0 ? false : true
        }
    }
    
    // MARK: - Interface builder outlets.
    
    @IBOutlet weak var ShowSwitch: NSSwitch!
    @IBOutlet weak var POIColorWell: NSColorWell!
    @IBOutlet weak var PopulationLabel: NSTextField!
    @IBOutlet weak var PopulationField: NSTextField!
    @IBOutlet weak var LongitudeField: NSTextField!
    @IBOutlet weak var LatitudeField: NSTextField!
    @IBOutlet weak var POITypeSegement: NSSegmentedControl!
    @IBOutlet weak var NameField: NSTextField!
    @IBOutlet weak var SaveNewDataButton: NSButton!
    @IBOutlet weak var POITable: NSTableView!
}
