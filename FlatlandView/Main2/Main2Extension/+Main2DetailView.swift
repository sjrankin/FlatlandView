//
//  +Main2DetailView.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/29/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension Main2Controller
{
    // MARK: - Code to run the item viewer.
    
    /// Initialize the item viewer.
    func InitializeItemViewer()
    {
        POIView.wantsLayer = true
        POIView.layer?.zPosition = 1000000
        POIView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.5).cgColor
        POIView.layer?.borderWidth = 0.5
        POIView.layer?.borderColor = NSColor.gray.withAlphaComponent(0.5).cgColor
        POIView.layer?.cornerRadius = 5.0
        ClearView()
        let ShowViewer = Settings.GetBool(.ShowDetailedInformation)
        print("ShowViewer=\(ShowViewer)")
        POIView.isHidden = !ShowViewer
       if ShowViewer
        {
            ShowEmptyView()
        }
        if let Window = self.view.window?.windowController as? Main2Window
        {
            let NewImageName = ShowViewer ? "BinocularsIconShowing" : "Binoculars"
            print("NewImageName=\(NewImageName)")
            Window.ChangeShowInfoImage(To: NSImage(named: NewImageName)!)
        }
    }
    
    /// Show an empty item view.
    func ShowEmptyView()
    {
        ClearView()
        TypeLabel.isHidden = true
        LocationLabel.isHidden = true
        POIView.isHidden = false
    }
    
    /// Clera the item view.
    func ClearView()
    {
        DescriptionValue.stringValue = ""
        LocationValue.stringValue = ""
        NumericValue.stringValue = ""
        NumericLabel.stringValue = ""
        NameValue.stringValue = ""
        NameLabel.stringValue = ""
        TypeValue.stringValue = ""
        SetValueTextColor(To: NSColor.black)
    }
    
    /// Sets the color of the value text.
    /// - Parameter To: The color to assign to the value text.
    func SetValueTextColor(To: NSColor)
    {
        DescriptionValue.textColor = To
        LocationValue.textColor = To
        NumericValue.textColor = To
        NameValue.textColor = To
        TypeValue.textColor = To
    }
    
    /// Call to display information about what is under the mouse.
    /// - Parameter ItemToDisplay: The data for the item under the mouse.
    func DisplayItem(ItemToDisplay: DisplayItem)
    {
        if ItemToDisplay.ItemType == .Unknown
        {
            ClearView()
            return
        }
        TypeLabel.isHidden = false
        NumericValue.isHidden = false
        NumericLabel.isHidden = false
        LocationLabel.isHidden = false
        SetValueTextColor(To: NSColor.white)
        TypeValue.stringValue = ItemToDisplay.ItemType.rawValue
        if let Where = ItemToDisplay.Location
        {
            let Lat = Where.Latitude.RoundedTo(3)
            let Lon = Where.Longitude.RoundedTo(3)
            LocationLabel.isHidden = false
            let LatHemi = Lat >= 0.0 ? "N" : "S"
            let LonHemi = Lon >= 180.0 ? "W" : "E"
            LocationValue.stringValue = "\(abs(Lat))\(LatHemi), \(abs(Lon))\(LonHemi)"
        }
        else
        {
            LocationLabel.isHidden = true
            LocationValue.stringValue = ""
        }
        DescriptionValue.stringValue = ItemToDisplay.Description
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
}
