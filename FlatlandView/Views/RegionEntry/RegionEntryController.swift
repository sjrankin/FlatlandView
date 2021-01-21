//
//  RegionEntryController.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/12/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

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
    }
    
    override func viewWillAppear()
    {
        super.viewWillAppear()
        ParentWindow = self.view.window
        ParentWindow?.delegate = self
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
        print("Region entry controller window moved.")
        MainDelegate?.FocusWindow()
    }
    
    var ClickForFirst = true
    
    @IBAction func RegionColorChangedHandler(_ sender: Any)
    {
        if let ColorWell = sender as? NSColorWell
        {
            RegionColor = ColorWell.color
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
        if NSColorPanel.shared.isVisible
        {
            NSColorPanel.shared.close()
        }
        ParentDelegate?.RegionEntryCompleted(Name: RegionNameField.stringValue, Color: RegionColor,
                                             Corner1: Point1, Corner2: Point2)
        self.view.window?.close()
    }
    
    @IBAction func HandleCancelButton(_ sender: Any)
    {
        if NSColorPanel.shared.isVisible
        {
            NSColorPanel.shared.close()
        }
        ParentDelegate?.RegionEntryCanceled()
        self.view.window?.close()
    }
    
    var ClickCount = 0
    
    func MouseClicked(At: GeoPoint)
    {
        if ClickCount > 2
        {
            print("Ignoring spurious click.")
            return
        }
        print("Mouse clicked at \(At)")
        if ClickForFirst
        {
            let LatS = Utility.PrettyLatitude(At.Latitude)
            let LonS = Utility.PrettyLongitude(At.Longitude)
            Latitude1Field.stringValue = LatS
            Longitude1Field.stringValue = LonS
            Message1.isHidden = true
            Message2.isHidden = false
            ClickForFirst = false
            ParentDelegate?.PlotUpperLeftCorner(Latitude: At.Latitude, Longitude: At.Longitude)
            ClickCount = 1
            return
        }
        let LatS = Utility.PrettyLatitude(At.Latitude)
        let LonS = Utility.PrettyLongitude(At.Longitude)
        Latitude2Field.stringValue = LatS
        Longitude2Field.stringValue = LonS
        ParentDelegate?.PlotLowerRightCorner(Latitude: At.Latitude, Longitude: At.Longitude)
        ClickCount = 2
    }
    
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
                    
                case ResetLowerRight:
                    Latitude2Field.stringValue = ""
                    Longitude2Field.stringValue = ""
                    ParentDelegate?.RemoveLowerRightCorner()
                    ClickCount = 1
                    
                default:
                    break
            }
        }
    }
    
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