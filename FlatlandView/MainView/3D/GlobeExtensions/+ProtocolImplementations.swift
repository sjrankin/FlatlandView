//
//  +ProtocolImplementations.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/6/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension GlobeView: PointEntryProtocol
{
    func PointEntryComplete(Name: String, Color: NSColor, Point: GeoPoint)
    {
        ResetFromPointEntry()
    }
    
    func PointEntrySessionComplete(Name: String, Color: NSColor, Point: GeoPoint)
    {
        ResetFromPointEntry()
    }
    
    func PointEntryCanceled()
    {
        ResetFromPointEntry()
    }
    
    func PlotPoint(Latitude: Double, Longitude: Double)
    {
        MousePointerType = .StartPin
        UpperLeftNode = MakePlottedPin(Latitude, Longitude, Color: NSColor.green)
        EarthNode?.addChildNode(UpperLeftNode!)
    }
    
    func MovePlottedPoint(Latitude: Double, Longitude: Double)
    {
        RemovePins()
        PlotPoint(Latitude: Latitude, Longitude: Longitude)
    }
    
    func RemovePin()
    {
        RemovePins()
    }
    
    func DeletePOI()
    {
        
    }
    
    func ResetFromPointEntry()
    {
        Settings.SetBool(.WorldIsLocked, OldLockState)
        POIEditorOpen = false
        InPointCreationMode = false
        MouseClickReceiver = nil
        RemoveUpperLeftCorner()
    }
}


extension GlobeView: PopOverParent
{
    func EditHome()
    {
    }
    
    func EditUserPOI(_ ID: UUID)
    {
        var EditMe: POI2? = nil
        for SomePOI in DBIF.UserPOIs
        {
            if SomePOI.ID == ID
            {
                EditMe = SomePOI
                break
            }
        }
        if EditMe == nil
        {
            print("Did not find POI with ID \(ID.uuidString)")
            return
        }
        if POIEditorOpen
        {
            return
        }
        POIEditorOpen = true
        let Storyboard = NSStoryboard(name: "POIEntryUI", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "POIEntryWindow") as? POIEntryWindow
        {
            let Window = WindowController.window
            if let Controller = Window?.contentViewController as? POIEntryController
            {
                InPointCreationMode = true
                Settings.SetBool(.WorldIsLocked, true)
                Controller.ParentDelegate = self
                Controller.MainDelegate = MainDelegate
                MouseClickReceiver = Controller
                Controller.EditExistingPoint(EditMe!)
                WindowController.showWindow(nil)
            }
        }
        else
        {
            POIEditorOpen = false
        }
    }
}
