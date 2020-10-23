//
//  RoundTextTestController.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

class RoundTextTestController: NSViewController, NSTextFieldDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        TextEntry.stringValue = "Please Wait"
        RadiusText.stringValue = "5.0"
        ROffset.stringValue = "0.33"
        AnimDurText.stringValue = "0.02"
        SpacingBox.stringValue = "20.0"
        ClockwiseSwitch.state = .off
        AnimateSwitch.state = .on
        BottomInSwitch.state = .on
        Initialize()
    }
    
    override func viewDidLayout()
    {
        TestView.ShowText("Please Wait")
    }
    
    func Initialize()
    {
        TestView.SetBackground(To: NSColor.black)
        TestView.SetTextColor(To: NSColor.yellow)
    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        self.view.window?.close()
    }
    
    @IBAction func HandleTextUpdated(_ sender: Any)
    {
    }
    
    func controlTextDidEndEditing(_ obj: Notification)
    {
        if let TextField = obj.object as? NSTextField
        {
            switch TextField
            {
                case TextEntry:
                    let Raw = TextField.stringValue
                    TestView.ShowText(Raw)
                    print("Set text to \(Raw)")
                    
                case ROffset:
                    let Raw = TextField.stringValue
                    if let RawOffset = Double(Raw)
                    {
                        TestView.SetRotationalOffset(To: RawOffset)
                    }
                    
                case RadiusText:
                    let Raw = TextField.stringValue
                    if let RawRadius = Double(Raw)
                    {
                        TestView.SetRadius(To: RawRadius)
                    }
                    
                case AnimDurText:
                    let Raw = TextField.stringValue
                    if let RawDuration = Double(Raw)
                    {
                        TestView.SetRadialDuration(To: RawDuration)
                    }
                    
                case SpacingBox:
                    let Raw = TextField.stringValue
                    if let RawSpacing = Double(Raw)
                    {
                        TestView.SetSpacing(To: RawSpacing)
                    }
                    
                default:
                    return
            }
        }
    }
    
    @IBAction func HandleAnimateChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            TestView.AnimateText = Switch.state == .on ? true : false
        }
    }
    
    @IBAction func HandleClockwiseChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            TestView.RotateClockwise = Switch.state == .on ? true : false
        }
    }
    
    @IBAction func HandleBottomInChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            TestView.BaseToCenter = Switch.state == .on ? true : false
        }
    }
    
    @IBOutlet weak var SpacingBox: NSTextField!
    @IBOutlet weak var AnimDurText: NSTextField!
    @IBOutlet weak var BottomInSwitch: NSSwitch!
    @IBOutlet weak var ClockwiseSwitch: NSSwitch!
    @IBOutlet weak var AnimateSwitch: NSSwitch!
    @IBOutlet weak var RadiusText: NSTextField!
    @IBOutlet weak var ROffset: NSTextField!
    @IBOutlet weak var TextEntry: NSTextField!
    @IBOutlet weak var TestView: RoundTextIndicator!
}
