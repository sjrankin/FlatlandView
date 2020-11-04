//
//  POIPopover.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/3/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class POIPopover: NSViewController, NSPopoverDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Initialize()
    }
    
    func SetSelf(_ Ourself: NSPopover)
    {
        This = Ourself
    }
    
    var This: NSPopover? = nil
    
    func popoverShouldDetach(_ popover: NSPopover) -> Bool
    {
        return true
    }
    
    func Initialize()
    {
        LocationLabel.stringValue = ""
        LocationValue.stringValue = ""
        NumericLabel.stringValue = ""
        NumericValue.stringValue = ""
        NameLabel.stringValue = ""
        NameValue.stringValue = ""
        TypeLabel.stringValue = ""
        TypeValue.stringValue = ""
        DescriptionLabel.stringValue = ""
    }
    
    /// Sets the color of the value text.
    /// - Parameter To: The color to assign to the value text.
    func SetValueTextColor(To: NSColor)
    {
        DescriptionLabel.textColor = To
        LocationValue.textColor = To
        NumericValue.textColor = To
        NameValue.textColor = To
        TypeValue.textColor = To
    }
    
    /// Call to display information about what is under the mouse.
    /// - Parameter ItemToDisplay: The data for the item under the mouse.
    func DisplayItem(_ ItemToDisplay: DisplayItem)
    {
        if ItemToDisplay.ItemType == .Unknown
        {
            Initialize()
            return
        }
        TypeLabel.isHidden = false
        TypeLabel.stringValue = "Type"
        NumericValue.isHidden = false
        NumericLabel.isHidden = false
        LocationLabel.isHidden = false
        LocationLabel.stringValue = "Location"
        SetValueTextColor(To: NSColor.black)
        TypeValue.stringValue = ItemToDisplay.ItemType.rawValue
        if let Where = ItemToDisplay.Location
        {
            let Lat = Where.Latitude.RoundedTo(3)
            let Lon = Where.Longitude.RoundedTo(3)
            LocationLabel.isHidden = false
            let LatHemi = Lat >= 0.0 ? "N" : "S"
            let LonHemi = Lon < 0.0 ? "W" : "E"
            LocationValue.stringValue = "\(abs(Lat))\(LatHemi), \(abs(Lon))\(LonHemi)"
        }
        else
        {
            LocationLabel.isHidden = true
            LocationValue.stringValue = ""
        }
        DescriptionLabel.stringValue = ItemToDisplay.Description
        switch ItemToDisplay.ItemType
        {
            case .City:
                NameLabel.stringValue = "Name"
                NameValue.stringValue = ItemToDisplay.Name
                NumericLabel.stringValue = "Population"
                let FinalPop = Int(ItemToDisplay.Numeric).Delimited()
                NumericValue.stringValue = "\(FinalPop)"
                
            case .Earthquake:
                NumericLabel.stringValue = "Magnitude"
                NumericValue.stringValue = "\(ItemToDisplay.Numeric.RoundedTo(2))"
                NameLabel.stringValue = "Date"
                NameValue.stringValue = ItemToDisplay.Name
                
            case .WorldHeritageSite:
                NumericLabel.stringValue = "Year"
                NumericValue.stringValue = "\(Int(ItemToDisplay.Numeric))"
                NameLabel.stringValue = "Site"
                NameValue.stringValue = ItemToDisplay.Name
                
            case .UserPOI:
                NumericLabel.stringValue = ""
                NumericValue.stringValue = ""
                NameLabel.stringValue = "Name"
                NameValue.stringValue = ItemToDisplay.Name
                
            case .Home:
                NumericLabel.stringValue = ""
                NumericValue.stringValue = ""
                NameLabel.stringValue = "Name"
                NameValue.stringValue = ItemToDisplay.Name
                
            case .Miscellaneous:
                NameLabel.stringValue = "Name"
                NameValue.stringValue = ItemToDisplay.Name
                if ItemToDisplay.HasNumber
                {
                    NumericLabel.stringValue = "Value"
                    NumericValue.stringValue = "\(ItemToDisplay.Numeric)"
                }
                else
                {
                    NumericValue.isHidden = true
                    NumericLabel.isHidden = true
                }
                
            default:
                return
        }
    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        self.view.window?.close()
    }
    
    @IBOutlet weak var LocationValue: NSTextField!
    @IBOutlet weak var LocationLabel: NSTextField!
    @IBOutlet weak var NumericValue: NSTextField!
    @IBOutlet weak var NumericLabel: NSTextField!
    @IBOutlet weak var NameValue: NSTextField!
    @IBOutlet weak var NameLabel: NSTextField!
    @IBOutlet weak var TypeValue: NSTextField!
    @IBOutlet weak var TypeLabel: NSTextField!
    @IBOutlet weak var DescriptionLabel: NSTextField!
}