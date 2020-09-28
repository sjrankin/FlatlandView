//
//  ItemViewerController.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ItemViewerController: NSViewController, ItemViewerProtocol, WindowManagement
{
    public weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ClearView()
    }
    
    @IBAction func HandleCloseButton(_ sender: Any)
    {
        MainDelegate?.ItemViewerClosed()
        self.view.window?.close()
    }
    
    func ClearView()
    {
        ItemDescription.stringValue = ""
        LocationValue.stringValue = ""
        NumericValue.stringValue = ""
        NumericLabel.stringValue = ""
        ItemNameLabel.stringValue = ""
        ItemTypeName.stringValue = ""
        ItemName.stringValue = ""
    }
    
    func DisplayItem(ItemToDisplay: DisplayItem)
    {
        if ItemToDisplay.ItemType == .Unknown
        {
            ClearView()
            return
        }
        ItemTypeName.stringValue = ItemToDisplay.ItemType.rawValue
        if let Where = ItemToDisplay.Location
        {
            let Lat = Where.Latitude.RoundedTo(3)
            let Lon = Where.Longitude.RoundedTo(3)
            LocationValue.stringValue = "\(Lat), \(Lon)"
        }
        ItemDescription.stringValue = ItemToDisplay.Description
        switch ItemToDisplay.ItemType
        {
            case .City:
                ItemNameLabel.stringValue = "Name"
                ItemName.stringValue = ItemToDisplay.Name
                NumericLabel.stringValue = "Population"
                let FinalPop = Int(ItemToDisplay.Numeric).Delimited()
                NumericValue.stringValue = "\(FinalPop)"
                
            case .Earthquake:
                NumericLabel.stringValue = "Magnitude"
                NumericValue.stringValue = "\(ItemToDisplay.Numeric.RoundedTo(2))"
                ItemNameLabel.stringValue = "Date"
                ItemName.stringValue = ItemToDisplay.Name
                
            case .WorldHeritageSite:
                NumericLabel.stringValue = "Year"
                NumericValue.stringValue = "\(Int(ItemToDisplay.Numeric))"
                
            case .UserPOI:
                NumericLabel.stringValue = ""
                NumericValue.stringValue = ""
                ItemNameLabel.stringValue = "Name"
                ItemName.stringValue = ItemToDisplay.Name
                
            case .Home:
                NumericLabel.stringValue = ""
                NumericValue.stringValue = ""
                ItemNameLabel.stringValue = "Name"
                ItemName.stringValue = ItemToDisplay.Name
                
            default:
                return
        }
    }
    
    func MainClosing()
    {
        self.view.window?.close()
    }
    
    @IBOutlet weak var ItemDescription: NSTextField!
    @IBOutlet weak var LocationValue: NSTextField!
    @IBOutlet weak var NumericValue: NSTextField!
    @IBOutlet weak var NumericLabel: NSTextField!
    @IBOutlet weak var ItemNameLabel: NSTextField!
    @IBOutlet weak var ItemName: NSTextField!
    @IBOutlet weak var ItemTypeName: NSTextField!
}
