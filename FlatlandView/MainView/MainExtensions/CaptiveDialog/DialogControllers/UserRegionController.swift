//
//  UserRegionController.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/18/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

@IBDesignable class UserRegionController: NSViewController, CaptiveDialogPanelProtocol
{
    public weak var ParentDelegate: CaptiveDialogManagementProtocol? = nil
    public weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        RegionColorWell.color = NSColor.TeaGreen
        RegionNameField.stringValue = "New Region"
        P1LongitudeField.stringValue = ""
        P1LatitudeField.stringValue = ""
        P2LatitudeField.stringValue = ""
        P2LongitudeField.stringValue = ""
    }
    
    override func viewDidAppear()
    {
        super.viewDidAppear()
        NWLabel.wantsLayer = true
        NWLabel.layer?.transform = CATransform3DMakeRotation(CGFloat(180.0).Radians, 0.0, 0.0, 1.0)
    }
    
    func WillClose(FromCaptive: Bool)
    {
        if FromCaptive
        {
            Debug.Print("Closing from self")
            return
        }
        //tell the main view that the user canceled user region creation
    }
    
    @IBAction func RegionEditorOKButtonHandler(_ sender: Any)
    {
        Debug.Print("OK button clicked")
        ParentDelegate?.CloseCaptiveDialog()
    }

    @IBAction func RegionEditorCancelButtonHandler(_ sender: Any)
    {
        Debug.Print("Cancel button clicked")
        ParentDelegate?.CloseCaptiveDialog()
    }
    
    @IBAction func ResetNorthWestButtonHandler(_ sender: Any)
    {
        P1LongitudeField.stringValue = ""
        P1LatitudeField.stringValue = ""
    }
    
    @IBAction func ResetSouthEastButtonHandler(_ sender: Any)
    {
        P2LatitudeField.stringValue = ""
        P2LongitudeField.stringValue = ""
    }
    
    @IBOutlet weak var SELabel: NSTextField2!
    @IBOutlet weak var NWLabel: NSTextField2!
    @IBOutlet weak var P2LongitudeField: NSTextField!
    @IBOutlet weak var P2LatitudeField: NSTextField!
    @IBOutlet weak var P1LongitudeField: NSTextField!
    @IBOutlet weak var P1LatitudeField: NSTextField!
    @IBOutlet weak var RegionColorWell: NSColorWell!
    @IBOutlet weak var RegionNameField: NSTextField!
}
