//
//  RadialRegionEntryController.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/30/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class RadialRegionEntryController: NSViewController, NSTextFieldDelegate, NSWindowDelegate, RegionMouseClickProtocol
{
    var ParentWindow: NSWindow? = nil
    public weak var ParentDelegate: RegionEntryProtocol? = nil
    public weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        RadialRegionName.stringValue = "New Radial Region"
        RadialRegionRadiusField.stringValue = ""
        RadialRegionColorWell.color = NSColor.Pistachio
        AllRegionsButton.toolTip = "View or edit all current earthquake regions."
    }
    
    override func viewWillAppear()
    {
        super.viewWillAppear()
        ParentWindow = self.view.window
        ParentWindow?.delegate = self
        ParentDelegate?.ClearMousePointer()
        ParentDelegate?.SetStartPin()
    }
    
    override func viewDidAppear()
    {
        view.window?.level = .floating
        MainDelegate?.FocusWindow()
    }
    
    func windowDidMove(_ notification: Notification)
    {
        WindowMoved()
    }
    
    /// If the window was moved, make sure the main window still has the focus.
    func WindowMoved()
    {
        MainDelegate?.FocusWindow()
    }
    
    var ClickCount = 0
    var CenterPoint: GeoPoint? = nil
    var RadialPoint: GeoPoint? = nil
    var TransientID: UUID? = nil
    
    func MouseClicked(At: GeoPoint)
    {
        MouseClickPoint = At
        ClickCount = ClickCount + 1
        if ClickCount == 1
        {
            //Click is for the center.
            let LatS = Utility.PrettyLatitude(At.Latitude)
            let LonS = Utility.PrettyLongitude(At.Longitude)
            CenterPoint = GeoPoint(At.Latitude, At.Longitude)
            RadialRegionCenterLatitudeField.stringValue = LatS
            RadialRegionCenterLongitudeField.stringValue = LonS
            CenterLocationText.isHidden = true
            EnterRadiusText.isHidden = false
            ParentDelegate?.PlotUpperLeftCorner(Latitude: At.Latitude, Longitude: At.Longitude)
            ParentDelegate?.SetEndPin()
            if let OldTransientID = TransientID
            {
                ParentDelegate?.RemoveTransientRegion(ID: OldTransientID)
            }
            TransientID = nil
        }
        else
        {
            //Click is for the radial distance.
            RadialPoint = GeoPoint(At.Latitude, At.Longitude)
            let Distance = Geometry.HaversineDistance(Point1: CenterPoint!, Point2: RadialPoint!) / 1000.0
            RadialRegionRadiusField.stringValue = "\(Int(Distance.RoundedTo(1)))"
            ParentDelegate?.RemoveLowerRightCorner()
            UpdateTransient(Center: CenterPoint!, Radius: Distance, Color: RadialRegionColorWell.color)
        }
        MainDelegate?.FocusWindow()
    }
    
    func UpdateTransient(Center: GeoPoint, Radius: Double, Color: NSColor)
    {
        if TransientID == nil
        {
            TransientID = UUID()
            if let Radius = GetRadius()
            {
                ParentDelegate?.PlotTransient(ID: TransientID!, Center: CenterPoint!, Radius: Radius,
                                              Color: RadialRegionColorWell.color)
            }
        }
        else
        {
            if let Radius = GetRadius()
            {
                print("New transient radius=\(Radius)")
                ParentDelegate?.UpdateTransient(ID: TransientID!, Center: CenterPoint!, Radius: Radius,
                                                Color: RadialRegionColorWell.color)
            }
        }
    }
    
    var MouseClickPoint: GeoPoint? = nil
    
    func CommonClose()
    {
        if NSColorPanel.shared.isVisible
        {
            NSColorPanel.shared.close()
        }
        if let ID = TransientID
        {
            ParentDelegate?.RemoveRadialTransientRegion(ID: ID)
        }
        ParentDelegate?.ClearMousePointer()
        ParentDelegate?.ResetMousePointer()
        ParentDelegate?.RemovePins()
    }
    
    @IBAction func RadialRegionOKButtonHandler(_ sender: Any)
    {
        if RadialRegionName.stringValue.isEmpty
        {
            ShowAlertMessage(Message: "Please add a region name.")
            return
        }
        guard let CenterPoint = GetCoordinates() else
        {
            ShowAlertMessage(Message: "Unable to read center point - please verify for correctness.")
            return
        }
        guard let RadialValue = GetRadius() else
        {
            ShowAlertMessage(Message: "Error determining radius of region.")
            return
        }
        CommonClose()
        ParentDelegate?.RadialRegionEntryCompleted(Name: RadialRegionName.stringValue,
                                                   Color: RadialRegionColorWell.color,
                                                   Center: CenterPoint,
                                                   Radius: RadialValue)
        self.view.window?.close()
    }
    
    @IBAction func RadialRegionCancelButtonHandler(_ sender: Any)
    {
        CommonClose()
        ParentDelegate?.RegionEntryCanceled()
        self.view.window?.close()
    }
    
    func GetRadius() -> Double?
    {
        let Raw = RadialRegionRadiusField.stringValue
        let Value = InputValidation.DistanceValidation(Raw)
        switch Value
        {
            case .failure(let Why):
                Debug.Print("Input validation failed: \(Why)")
                return nil
                
            case .success(let (FinalValue, FinalUnits)):
                Debug.Print("Radius=\(FinalValue) \(FinalUnits)")
                return FinalValue
        }
    }
    
    @IBAction func RadialRegionAllRegionsButtonHandler(_ sender: Any)
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
    
    @IBAction func RadialRegionColorChangedHandler(_ sender: Any)
    {
        if let ColorWell = sender as? NSColorWell
        {
            if ClickCount > 1
            {
                if let Radius = GetRadius()
                {
                    ParentDelegate?.UpdateTransient(ID: TransientID!,
                                                    Center: CenterPoint!,
                                                    Radius: Radius,
                                                    Color: ColorWell.color)
                }
            }
        }
    }
    
    @IBAction func RadialRegionResetCenterButtonHandler(_ sender: Any)
    {
        ClickCount = 0
        EnterRadiusText.isHidden = true
        CenterLocationText.isHidden = false
        RadialRegionRadiusField.stringValue = ""
        RadialRegionCenterLatitudeField.stringValue = ""
        RadialRegionCenterLongitudeField.stringValue = ""
        CenterPoint = nil
        RadialPoint = nil
        ParentDelegate?.RemovePins()
        ParentDelegate?.SetStartPin()
    }
    
    @IBAction func RadialRegionResetRadiusButtonHandler(_ sender: Any)
    {
        RadialPoint = nil
        ParentDelegate?.RemoveLowerRightCorner()
        ParentDelegate?.SetEndPin()
        RadialRegionRadiusField.stringValue = ""
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
        guard let P1 = GetPoint(FromLat: RadialRegionCenterLatitudeField, FromLon: RadialRegionCenterLongitudeField) else
        {
            return nil
        }
        return P1
    }

    @IBOutlet weak var AllRegionsButton: NSButton!
    @IBOutlet weak var EnterRadiusText: NSTextField!
    @IBOutlet weak var CenterLocationText: NSTextField!
    @IBOutlet weak var RadialRegionCenterLongitudeField: NSTextField!
    @IBOutlet weak var RadialRegionCenterLatitudeField: NSTextField!
    @IBOutlet weak var RadialRegionRadiusField: NSTextField!
    @IBOutlet weak var RadialRegionName: NSTextField!
    @IBOutlet weak var RadialRegionColorWell: NSColorWell!
}
