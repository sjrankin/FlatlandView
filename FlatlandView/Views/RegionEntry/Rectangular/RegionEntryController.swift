//
//  RegionEntryController.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/12/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Note: See [windowShouldClose Never Called](https://stackoverflow.com/questions/44883592/windowshouldclose-never-called)
class RegionEntryController: NSViewController, NSWindowDelegate, RegionMouseClickProtocol
{
    public weak var ParentDelegate: RegionEntryProtocol? = nil
    public weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Message1.isHidden = false
        Message2.isHidden = true
        RegionColorWell.color = NSColor.TeaGreen
        RegionNameField.stringValue = "New Field Name"
        AllRegionsButton.toolTip = "View or edit all earthquake regions."
    }
    
    override func viewWillAppear()
    {
        super.viewWillAppear()
        ParentWindow = self.view.window
        ParentWindow?.delegate = self
        ParentDelegate?.ClearMousePointer()
        ParentDelegate?.SetStartPin()
    }
    
    var ParentWindow: NSWindow? = nil
    
    func windowDidMove(_ notification: Notification)
    {
        WindowMoved()
    }
    
    /// Make sure the window stays in front of the main window.
    /// - Note: See [How to Keep Window Always on the Top With Swift](https://stackoverflow.com/questions/38711406/how-to-keep-window-always-on-the-top-with-swift)
    override func viewDidAppear()
    {
        view.window?.level = .floating
        MainDelegate?.FocusWindow()
    }
    
    /// If the window was moved, make sure the main window still has the focus.
    func WindowMoved()
    {
        MainDelegate?.FocusWindow()
    }
    
    var ClickForFirst = true
    
    @IBAction func RegionColorChangedHandler(_ sender: Any)
    {
        if let ColorWell = sender as? NSColorWell
        {
            RegionColor = ColorWell.color
            if Point1 != nil && Point2 != nil
            {
                UpdateTransient(Point1: Point1!, Point2: Point2!, Color: RegionColor)
            }
        }
    }
    
    var RegionColor: NSColor = NSColor.TeaGreen
    
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
    
    func GetCoordinates() -> (Point1: GeoPoint, Point2: GeoPoint)?
    {
        guard let P1 = GetPoint(FromLat: Latitude1Field, FromLon: Longitude1Field) else
        {
            return nil
        }
        guard let P2 = GetPoint(FromLat: Latitude2Field, FromLon: Longitude2Field) else
        {
            return nil
        }
        return (P1, P2)
    }
    
    func ShowAlertMessage(Message: String)
    {
        let Alert = NSAlert()
        Alert.messageText = Message
        Alert.informativeText = ""
        Alert.alertStyle = .warning
        Alert.addButton(withTitle: "OK")
        Alert.runModal()
    }
    
    @IBAction func HandleOKButton(_ sender: Any)
    {
        if RegionNameField.stringValue.isEmpty
        {
            ShowAlertMessage(Message: "Please add a region name.")
            return
        }
        guard let (Point1, Point2) = GetCoordinates() else
        {
            ShowAlertMessage(Message: "Unable to read points - please verify for correctness.")
            return
        }
        OKClicked = true
        ParentDelegate?.RegionEntryCompleted(Name: RegionNameField.stringValue, Color: RegionColor,
                                             Corner1: Point1, Corner2: Point2)
        self.view.window?.close()
    }
    
    @IBAction func HandleCancelButton(_ sender: Any)
    {
        self.view.window?.close()
    }
    
    var OKClicked = false
    
    /// Clean up from the OK, Cancel, or close window buttons.
    override func viewWillDisappear()
    {
        super.viewWillDisappear()
        if NSColorPanel.shared.isVisible
        {
            NSColorPanel.shared.close()
        }
        ParentDelegate?.ClearMousePointer()
        ParentDelegate?.ResetMousePointer()
        ParentDelegate?.RemovePins()
        if !OKClicked
        {
            ParentDelegate?.RegionEntryCanceled()
        }
    }
    
    var ClickCount = 0
    
    var Point1: GeoPoint? = nil
    var Point2: GeoPoint? = nil
    
    func MouseClicked(At: GeoPoint)
    {
        if ClickCount == 0
        {
            let LatS = Utility.PrettyLatitude(At.Latitude)
            let LonS = Utility.PrettyLongitude(At.Longitude)
            Point1 = GeoPoint(At.Latitude, At.Longitude)
            Latitude1Field.stringValue = LatS
            Longitude1Field.stringValue = LonS
            Message1.isHidden = true
            Message2.isHidden = false
            ClickForFirst = false
            ParentDelegate?.PlotUpperLeftCorner(Latitude: At.Latitude, Longitude: At.Longitude)
            ClickCount = 1
            ParentDelegate?.SetEndPin()
            if let OldTransientID = TransientID
            {
                ParentDelegate?.RemoveTransientRegion(ID: OldTransientID)
            }
            TransientID = nil
        }
        else
        {
            if ClickCount == 1
            {
                let LatS = Utility.PrettyLatitude(At.Latitude)
                let LonS = Utility.PrettyLongitude(At.Longitude)
                Point2 = GeoPoint(At.Latitude, At.Longitude)
                Latitude2Field.stringValue = LatS
                Longitude2Field.stringValue = LonS
                ParentDelegate?.PlotLowerRightCorner(Latitude: At.Latitude, Longitude: At.Longitude)
                ClickCount = 2
                ParentDelegate?.ResetMousePointer()
                UpdateTransient(Point1: Point1!, Point2: Point2!, Color: RegionColor)
            }
        }
    }
    
    /// Draw a transient region on the globe.
    func UpdateTransient(Point1: GeoPoint, Point2: GeoPoint, Color: NSColor)
    {
        if TransientID == nil
        {
            TransientID = UUID()
            ParentDelegate?.PlotTransient(ID: TransientID!, Point1: Point1, Point2: Point2, Color: Color)
        }
        else
        {
            ParentDelegate?.UpdateTransient(ID: TransientID!, Point1: Point1, Point2: Point2, Color: Color)
        }
    }
    
    var TransientID: UUID? = nil
    
    @IBAction func ResetCoordinatesHandler(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            switch Button
            {
                case ResetUpperLeft:
                    ClickForFirst = true
                    Latitude1Field.stringValue = ""
                    Longitude1Field.stringValue = ""
                    Message1.isHidden = false
                    Message2.isHidden = true
                    ParentDelegate?.RemoveUpperLeftCorner()
                    ClickCount = 0
                    ParentDelegate?.SetStartPin()
                    
                case ResetLowerRight:
                    Latitude2Field.stringValue = ""
                    Longitude2Field.stringValue = ""
                    ParentDelegate?.RemoveLowerRightCorner()
                    ClickCount = 1
                    ParentDelegate?.SetEndPin()
                    
                default:
                    break
            }
        }
    }
    
    @IBAction func HandleAllRegionsButtonClicked(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "PreferencePanel", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "EarthquakeRegionWindow3") as? EarthquakeRegionWindow3
        {
            let Window = WindowController.window
            self.view.window?.beginSheet(Window!)
            {
                _ in
            }
        }
    }
    
    @IBOutlet weak var AllRegionsButton: NSButton!
    @IBOutlet weak var ResetLowerRight: NSButton!
    @IBOutlet weak var ResetUpperLeft: NSButton!
    @IBOutlet weak var Message2: NSTextField!
    @IBOutlet weak var Message1: NSTextField!
    @IBOutlet weak var Longitude2Field: NSTextField!
    @IBOutlet weak var Latitude2Field: NSTextField!
    @IBOutlet weak var Longitude1Field: NSTextField!
    @IBOutlet weak var Latitude1Field: NSTextField!
    @IBOutlet weak var RegionColorWell: NSColorWell!
    @IBOutlet weak var RegionNameField: NSTextField!
}
