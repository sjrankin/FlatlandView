//
//  POIEntryController.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/6/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class POIEntryController: NSViewController, NSWindowDelegate, RegionMouseClickProtocol
{
    public weak var ParentDelegate: PointEntryProtocol? = nil
    public weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        UpdateButton.toolTip = "Update the location on the map"
    }
    
    override func viewDidAppear()
    {
        view.window?.level = .floating
        MainDelegate?.FocusWindow()
    }
    
    var ParentWindow: NSWindow? = nil
    
    public func EditExistingPoint(_ ThePOI: POI2)
    {
        TitleText.stringValue = "Edit User Point-of-Interest"
        DeleteButton.isHidden = false
        DeleteButton.isEnabled = true
        NameField.stringValue = ThePOI.Name
        ColorWell.color = ThePOI.Color
        LatitudeField.stringValue = "\(ThePOI.Latitude)"
        LongitudeField.stringValue = "\(ThePOI.Longitude)"
        EditingExistingPoint = true
        POIID = ThePOI.ID
    }
    
    var POIID: UUID? = nil
    
    public func CreateNewPoint(ClickPoint: GeoPoint)
    {
        TitleText.stringValue = "Add New User Point-of-Interest"
        DeleteButton.isHidden = true
        DeleteButton.isEnabled = false
        NameField.stringValue = ""
        ColorWell.color = NSColor.red
        LatitudeField.stringValue = "\(ClickPoint.Latitude.RoundedTo(3))"
        LongitudeField.stringValue = "\(ClickPoint.Longitude.RoundedTo(3))"
        ParentDelegate?.PlotPoint(Latitude: ClickPoint.Latitude, Longitude: ClickPoint.Longitude)
        EditingExistingPoint = false
    }
    
    var EditingExistingPoint: Bool = false
    
    func windowDidMove(_ notification: Notification)
    {
        WindowMoved()
    }
    
    /// If the window was moved, make sure the main window still has the focus.
    func WindowMoved()
    {
        MainDelegate?.FocusWindow()
    }
    
    func GetPoint(FromLat: NSTextField, FromLon: NSTextField) -> GeoPoint?
    {
        var FinalLat = 0.0
        let LatVal = InputValidation.LatitudeValidation(FromLat.stringValue)
        switch LatVal
        {
            case .success(let Value):
                FinalLat = Value
                
            case .failure(let Why):
                Debug.Print("Latitude validation error: \(Why.rawValue)")
                return nil
        }
        var FinalLon = 0.0
        let LonValue = InputValidation.LongitudeValidation(FromLon.stringValue)
        switch LonValue
        {
            case .success(let Value):
                FinalLon = Value
                
            case .failure(let Why):
                Debug.Print("Longitude validation error: \(Why.rawValue)")
                return nil
        }
        return GeoPoint(FinalLat, FinalLon)
    }
    
    func GetCoordinates() -> GeoPoint?
    {
        guard let P1 = GetPoint(FromLat: LatitudeField, FromLon: LongitudeField) else
        {
            return nil
        }
        return P1
    }
    
    func ShowAlertMessage(Message: String)
    {
        let Alert = NSAlert()
        Alert.messageText = Message
        Alert.informativeText = ""
        Alert.alertStyle = .informational
        Alert.addButton(withTitle: "OK")
        Alert.runModal()
    }
    
    func ShowConfirmationMessage(Message: String, Information: String? = nil) -> Bool
    {
        let Alert = NSAlert()
        Alert.messageText = Message
        if let Info = Information
        {
            Alert.informativeText = Info
        }
        Alert.alertStyle = .warning
        Alert.addButton(withTitle: "OK")
        Alert.addButton(withTitle: "Cancel")
        let Response = Alert.runModal()
        if Response == .alertFirstButtonReturn
        {
            return true
        }
        return false
    }
    
    func MouseClicked(At: GeoPoint)
    {
        ParentDelegate?.RemovePin()
        let LatS = Utility.PrettyLatitude(At.Latitude)
        let LonS = Utility.PrettyLongitude(At.Longitude)
        LatitudeField.stringValue = LatS
        LongitudeField.stringValue = LonS
        ParentDelegate?.PlotPoint(Latitude: At.Latitude, Longitude: At.Longitude)
    }
    
    @IBAction func HandleOKButton(_ sender: Any)
    {
        if NameField.stringValue.isEmpty
        {
            ShowAlertMessage(Message: "Please add a name for your point-of-interest.")
            return
        }
        guard let Location = GetCoordinates() else
        {
            ShowAlertMessage(Message: "Unable to read location of point-of-interest. Please verify for correctness.")
            return
        }
        OKClicked = true
        ParentDelegate?.PointEntryComplete(Name: NameField.stringValue, Color: ColorWell.color,
                                           Point: Location, ID: POIID)
        self.view.window?.close()
    }
    
    var OKClicked: Bool = false
    
    @IBAction func HandleCancelButton(_ sender: Any)
    {
        self.view.window?.close()
    }
    
    override func viewWillDisappear()
    {
        super.viewWillDisappear()
        if NSColorPanel.shared.isVisible
        {
            NSColorPanel.shared.close()
        }
        ParentDelegate?.ClearMousePointer()
        ParentDelegate?.ResetMousePointer()
        ParentDelegate?.RemovePin()
        if !OKClicked
        {
            ParentDelegate?.PointEntryCanceled()
        }
    }
    
    @IBAction func HandleDeleteButton(_ sender: Any)
    {
        if let ActualID = POIID
        {
            let ReallyDelete = ShowConfirmationMessage(Message: "Do you really want to delete this point-of-interest (\(NameField.stringValue))?",
                                                       Information: "Deleting the point-of-interest will take effect immediately.")
            if ReallyDelete
            {
                OKClicked = false
                ParentDelegate?.DeletePOI(ID: ActualID)
                self.view.window?.close()
            }
        }
    }
    
    @IBAction func HandleUpdateButton(_ sender: Any)
    {
        if let Location = GetCoordinates()
        {
            ParentDelegate?.MovePlottedPoint(Latitude: Location.Latitude, Longitude: Location.Longitude)
        }
    }
    
    @IBOutlet weak var LongitudeField: NSTextField!
    @IBOutlet weak var LatitudeField: NSTextField!
    @IBOutlet weak var UpdateButton: NSButton!
    @IBOutlet weak var DeleteButton: NSButton!
    @IBOutlet weak var TitleText: NSTextField!
    @IBOutlet weak var ColorWell: NSColorWell!
    @IBOutlet weak var NameField: NSTextField!
}
