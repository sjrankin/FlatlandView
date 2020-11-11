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
    override func viewDidLoad()
    {
        super.viewDidLoad()
        SetLocation(Latitude: "", Longitude: "")
        ActualX.stringValue = ""
        ActualY.stringValue = ""
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.gray.cgColor
        self.view.layer?.borderWidth = 3.0
        self.view.layer?.cornerRadius = 5.0
        self.view.layer?.borderColor = NSColor.white.cgColor
        LatitudeValue.textColor = NSColor(calibratedRed: 0.05, green: 0.05, blue: 0.2, alpha: 1.0)
        LongitudeValue.textColor = NSColor(calibratedRed: 0.05, green: 0.05, blue: 0.2, alpha: 1.0)
    }
    
    func SetLocation(Latitude: String, Longitude: String, _ X: Double? = nil, _ Y: Double? = nil)
    {
        LatitudeValue.stringValue = Latitude
        LongitudeValue.stringValue = Longitude
        if let XValue = X
        {
            ActualX.stringValue = "\(XValue.RoundedTo(3))"
        }
        if let YValue = Y
        {
            ActualY.stringValue = "\(YValue.RoundedTo(3))"
        }
    }
    
    @IBOutlet weak var ActualX: NSTextField!
    @IBOutlet weak var ActualY: NSTextField!
    @IBOutlet weak var LatitudeValue: NSTextField!
    @IBOutlet weak var LongitudeValue: NSTextField!
}
