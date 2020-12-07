//
//  MouseInfoController.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/9/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Controller for the Mouse Info UI.
class MouseInfoController: NSViewController, MouseInfoProtocol
{
    public weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        SetLocation(Latitude: "", Longitude: "")
        LocationLabel.stringValue = ""
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.gray.cgColor
        self.view.layer?.borderWidth = 3.0
        self.view.layer?.cornerRadius = 5.0
        self.view.layer?.borderColor = NSColor.white.cgColor
        LatitudeValue.textColor = NSColor(calibratedRed: 0.05, green: 0.05, blue: 0.2, alpha: 1.0)
        LongitudeValue.textColor = NSColor(calibratedRed: 0.05, green: 0.05, blue: 0.2, alpha: 1.0)
        LocationManager = Locations()
        LocationManager?.Main = MainDelegate
    }
    
    /// Set the main delegate. Ensure the location manager has the same delegate.
    /// - Parameter Main: The main delegate.
    func SetMainDelegate(_ Main: MainProtocol?)
    {
        MainDelegate = Main
        LocationManager?.Main = Main
    }
    
    var LocationManager: Locations? = nil
    
    /// "Sets" the location.
    /// - Parameter Latitude: String representation of the latitude.
    /// - Parameter Longitude: String representation of the longitude.
    func SetLocation(Latitude: String, Longitude: String)
    {
        LatitudeValue.stringValue = Latitude
        LongitudeValue.stringValue = Longitude
    }
    
    /// Sets the location. If the proper user setting is enabled, nearby locations will be searched for.
    /// - Parameter Latitude: The latitude of the location.
    /// - Parameter Longitude: The longitude of the location.
    func SetLocation(Latitude: Double, Longitude: Double)
    {
        LatitudeValue.stringValue = Utility.PrettyLatitude(Latitude, Precision: 3)
        LongitudeValue.stringValue = Utility.PrettyLongitude(Longitude, Precision: 3)
        if Settings.GetBool(.SearchForLocation)
        {
            let LookForTypes: [LocationTypes] = [.City, .Home, .UNESCO, .UserPOI]
            if var NearBy = LocationManager?.WhatIsCloseTo(Latitude: Latitude, Longitude: Longitude,
                                                           CloseIs: 100.0, ForLocations: LookForTypes)
            {
                if NearBy.count > 0
                {
                    NearBy.sort(by: {$0.Distance < $1.Distance})
                    let DisplayCount = min(NearBy.count, 3)
                    var CloseBy = ""
                    for Index in 0 ..< DisplayCount
                    {
                        CloseBy.append(NearBy[Index].Name)
                        if Index < DisplayCount - 1
                        {
                            CloseBy.append("\n")
                        }
                    }
                    LocationLabel.stringValue = CloseBy
                }
                else
                {
                    LocationLabel.stringValue = ""
                }
            }
            else
            {
                LocationLabel.stringValue = ""
            }
        }
    }
    
    @IBOutlet weak var LocationLabel: NSTextField!
    @IBOutlet weak var LatitudeValue: NSTextField!
    @IBOutlet weak var LongitudeValue: NSTextField!
}
