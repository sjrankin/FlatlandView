//
//  PolarRegionEntryController.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/22/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class PolarRegionEntryController: NSViewController, NSWindowDelegate, RegionMouseClickProtocol
{
    var ParentWindow: NSWindow? = nil
    public weak var ParentDelegate: RegionEntryProtocol? = nil
    public weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        PolarRegionColorWell.color = NSColor.Sunglow
        RegionNameField.stringValue = "New Polar Region"
        PolarRadiusField.stringValue = "1000.0"
        PoleSelector.selectedSegment = 0
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
    
    func MouseClicked(At: GeoPoint)
    {
        MouseClickPoint = At
        let Pole = PoleSelector.selectedSegment == 0 ? GeoPoint(90.0, 0.0) : GeoPoint(-90.0, 0.0)
        let Radius = Geometry.HaversineDistance(Point1: At, Point2: Pole) / 1000.0
        print("Clicked at \(At.Latitude.RoundedTo(1)),\(At.Longitude.RoundedTo(1)), Radius=\(Radius.RoundedTo(1))km")
        PolarRadiusField.stringValue = "\(Radius.RoundedTo(1))"
        ParentDelegate?.RemovePins()
        ParentDelegate?.SetEndPin()
        ParentDelegate?.PlotLowerRightCorner(Latitude: At.Latitude, Longitude: At.Longitude)
        UpdateTransient(NorthPole: PoleSelector.selectedSegment == 0 ? true : false,
                        Radius: Radius,
                        Color: PolarRegionColorWell.color)
        MainDelegate?.FocusWindow()
    }
    
    var MouseClickPoint: GeoPoint? = nil
    var PreviousRadius: Double? = nil
    
    @IBAction func PolarRegionColorHandler(_ sender: Any)
    {
        if let ColorWell = sender as? NSColorWell
        {
            RegionColor = ColorWell.color
            if let Radius = PreviousRadius
            {
                UpdateTransient(NorthPole: PoleSelector.selectedSegment == 0 ? true : false,
                                Radius: Radius,
                                Color: PolarRegionColorWell.color)
            }
            MainDelegate?.FocusWindow()
        }
    }
    
    /// Draw a transient region on the globe.
    func UpdateTransient(NorthPole: Bool, Radius: Double, Color: NSColor)
    {
        #if false
        TransientID = UUID()
        ParentDelegate?.RemoveTransientRegions()
        ParentDelegate?.PlotTransient(ID: TransientID!, NorthPole: NorthPole, Radius: Radius, Color: Color)
        #else
        if TransientID == nil
        {
            TransientID = UUID()
            print("Making new transient region, Radius=\(Radius)")
            ParentDelegate?.PlotTransient(ID: TransientID!, NorthPole: NorthPole, Radius: Radius, Color: Color)
        }
        else
        {
            ParentDelegate?.UpdateTransient(ID: TransientID!, NorthPole: NorthPole, Radius: Radius, Color: Color)
        }
        #endif
    }
    
    var TransientID: UUID? = nil
    
    var RegionColor = NSColor.Sunglow
    
    func GetRadius() -> Double?
    {
        let Raw = PolarRadiusField.stringValue
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
    
    func ShowAlertMessage(Message: String)
    {
        let Alert = NSAlert()
        Alert.messageText = Message
        Alert.informativeText = ""
        Alert.alertStyle = .warning
        Alert.addButton(withTitle: "OK")
        Alert.runModal()
    }
    
    @IBAction func PolarRegionResetHandler(_ sender: Any)
    {
        PolarRadiusField.stringValue = ""
        ParentDelegate?.SetStartPin()
        ParentDelegate?.RemoveTransientRegions()
        TransientID = nil
    }
    
    func CommonCleanUp()
    {
        if NSColorPanel.sharedColorPanelExists
        {
            if NSColorPanel.shared.isVisible
            {
                NSColorPanel.shared.close()
            }
        }
        ParentDelegate?.RemoveTransientRegions()
        ParentDelegate?.ClearMousePointer()
        ParentDelegate?.ResetMousePointer()
        ParentDelegate?.RemovePins()
    }
    
    @IBAction func PolarRegionOKHandler(_ sender: Any)
    {
        if RegionNameField.stringValue.isEmpty
        {
            ShowAlertMessage(Message: "Please add a region name.")
            return
        }
        guard let Radius = GetRadius() else
        {
            ShowAlertMessage(Message: "Invalid radius. Please double check.")
            return
        }
        CommonCleanUp()
        let IsNorthPole = PoleSelector.selectedSegment == 0 ? true : false
        ParentDelegate?.PolarRegionEntryCompleted(Name: RegionNameField.stringValue, Color: RegionColor,
                                                  Radius: Radius, NorthPole: IsNorthPole)
        self.view.window?.close()
    }
    
    @IBAction func PolarRegionCancelHandler(_ sender: Any)
    {
        CommonCleanUp()
        ParentDelegate?.RegionEntryCanceled()
        self.view.window?.close()
    }
    
    @IBAction func PolarRegionChangedHandler(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            if let Where = MouseClickPoint
            {
                let Pole = Segment.selectedSegment == 0 ? GeoPoint(90.0, 0.0) : GeoPoint(-90.0, 0.0)
                let Radius = Geometry.HaversineDistance(Point1: Where, Point2: Pole) / 1000.0
                PreviousRadius = Radius
                PolarRadiusField.stringValue = Radius.RoundedTo(2)
                UpdateTransient(NorthPole: Segment.selectedSegment == 0 ? true : false,
                                Radius: Radius,
                                Color: PolarRegionColorWell.color)
            }
            MainDelegate?.FocusWindow()
        }
    }
    
    @IBAction func HandleAllRegionButtonClicked(_ sender: Any)
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
    @IBOutlet weak var PolarRegionColorWell: NSColorWell!
    @IBOutlet weak var RegionNameField: NSTextField!
    @IBOutlet weak var PolarRadiusField: NSTextField!
    @IBOutlet weak var PoleSelector: NSSegmentedControl!
}
