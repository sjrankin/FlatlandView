//
//  RegionEntryController.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/12/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class RegionEntryController: NSViewController, RegionMouseClickProtocol
{
    public weak var ParentDelegate: RegionEntryProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Message1.isHidden = false
        Message2.isHidden = true
        RegionColorWell.color = NSColor.TeaGreen
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
        ParentDelegate?.RegionEntryCompleted(Name: RegionNameField.stringValue, Color: RegionColor,
                                             Corner1: Point1, Corner2: Point2)
        self.view.window?.close()
    }
    
    @IBAction func HandleCancelButton(_ sender: Any)
    {
        ParentDelegate?.RegionEntryCanceled()
        self.view.window?.close()
    }
    
    func MouseClicked(At: GeoPoint)
    {
        if !ClickForFirst
        {
            let LatS = Utility.PrettyLatitude(At.Latitude)
            let LonS = Utility.PrettyLongitude(At.Longitude)
            Latitude1Field.stringValue = LatS
            Longitude1Field.stringValue = LonS
            Message1.isHidden = true
            Message2.isHidden = false
            ClickForFirst = false
            return
        }
        let LatS = Utility.PrettyLatitude(At.Latitude)
        let LonS = Utility.PrettyLongitude(At.Longitude)
        Latitude2Field.stringValue = LatS
        Longitude2Field.stringValue = LonS
    }

    @IBOutlet weak var Message2: NSTextField!
    @IBOutlet weak var Message1: NSTextField!
    @IBOutlet weak var Longitude2Field: NSTextField!
    @IBOutlet weak var Latitude2Field: NSTextField!
    @IBOutlet weak var Longitude1Field: NSTextField!
    @IBOutlet weak var Latitude1Field: NSTextField!
    @IBOutlet weak var RegionColorWell: NSColorWell!
    @IBOutlet weak var RegionNameField: NSTextField!
}
