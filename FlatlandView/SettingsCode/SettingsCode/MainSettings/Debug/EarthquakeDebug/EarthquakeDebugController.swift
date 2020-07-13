//
//  EarthquakeDebugController.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/3/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class EarthquakeDebugController: NSViewController
{
    public weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        MagnitudeSegment.selectedSegment = 0
        LatitudeBox.stringValue = ""
        LongitudeBox.stringValue = ""
    }
    
    func GetDoubleFrom(_ Control: NSTextField) -> Double?
    {
        let RawValue = Control.stringValue
        if let DVal = Double(RawValue)
        {
            return DVal
        }
        return nil
    }
    
    @IBAction func HandleAddEarthquakeButton(_ sender: Any)
    {
        let Mag = MagnitudeSegment.selectedSegment + 5
        var LatVal: Double = 0.0
        var LonVal: Double = 0.0
        var HaveLocation = true
        if let Lat = GetDoubleFrom(LatitudeBox)
        {
            LatVal = Lat
        }
        else
        {
            HaveLocation = false
        }
        if let Lon = GetDoubleFrom(LongitudeBox)
        {
            LonVal = Lon
        }
        else
        {
            HaveLocation = false
        }
        if HaveLocation
        {
            MainDelegate?.InsertEarthquake(Latitude: LatVal, Longitude: LonVal, Magnitude: Double(Mag))
        }
        else
        {
            MainDelegate?.InsertEarthquake(Magnitude: Double(Mag))
        }
    }
    
    @IBAction func HandleForceFetch(_ sender: Any)
    {
        MainDelegate?.ForceFetchEarthquakes()
    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent?.endSheet(Window!, returnCode: .OK)
    }
    
    @IBAction func HandlePointingFingerButton(_ sender: Any)
    {
        MainDelegate?.InsertEarthquakeCluster(10) 
    }
    
    @IBOutlet weak var MagnitudeSegment: NSSegmentedControl!
    @IBOutlet weak var LatitudeBox: NSTextField!
    @IBOutlet weak var LongitudeBox: NSTextField!
}
