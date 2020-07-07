//
//  3DDebugController.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/13/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ThreeDDebugController: NSViewController
{
    public weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Settings.QueryBool(.ShowWireframes)
        {
            Show in
            self.WireframeSwitch.state = Show ? .on : .off
        }
        Settings.QueryBool(.ShowBoundingBoxes)
        {
            Show in
            self.BoundingBoxSwitch.state = Show ? .on : .off
        }
        Settings.QueryBool(.ShowSkeletons)
        {
            Show in
            self.SkeletonSwitch.state = Show ? .on : .off
        }
        Settings.QueryBool(.ShowConstraints)
        {
            Show in
            self.ConstraintSwitch.state = Show ? .on : .off
        }
        Settings.QueryBool(.ShowLightInfluences)
        {
            Show in
            self.LightInfluenceSwitch.state = Show ? .on : .off
        }
        Settings.QueryBool(.ShowLightExtents)
        {
            Show in
            self.LightExtentsSwitch.state = Show ? .on : .off
        }
        Settings.QueryBool(.ShowStatistics)
        {
            Show in
            self.ShowStatsSwitch.state = Show ? .on : .off
        }
    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent?.endSheet(Window!, returnCode: .OK)
    }
    
    @IBAction func HandleSwitchChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            switch Switch
            {
                case WireframeSwitch:
                    Settings.SetBool(.ShowWireframes, Switch.state == .on ? true : false)
                
                case BoundingBoxSwitch:
                    Settings.SetBool(.ShowBoundingBoxes, Switch.state == .on ? true : false)
                
                case SkeletonSwitch:
                    Settings.SetBool(.ShowSkeletons, Switch.state == .on ? true : false)
                
                case LightExtentsSwitch:
                    Settings.SetBool(.ShowLightExtents, Switch.state == .on ? true : false)
                
                case LightInfluenceSwitch:
                    Settings.SetBool(.ShowLightInfluences, Switch.state == .on ? true : false)
                
                case ConstraintSwitch:
                    Settings.SetBool(.ShowConstraints, Switch.state == .on ? true : false)
                    
                case ShowStatsSwitch:
                    Settings.SetBool(.ShowStatistics, Switch.state == .on ? true : false)
                
                default:
                    return
            }
            MainDelegate?.Refresh("ThreeDDebugController.HandleSwitchChanged")
        }
    }
    
    @IBOutlet weak var ShowStatsSwitch: NSSwitch!
    @IBOutlet weak var LightExtentsSwitch: NSSwitch!
    @IBOutlet weak var LightInfluenceSwitch: NSSwitch!
    @IBOutlet weak var ConstraintSwitch: NSSwitch!
    @IBOutlet weak var SkeletonSwitch: NSSwitch!
    @IBOutlet weak var BoundingBoxSwitch: NSSwitch!
    @IBOutlet weak var WireframeSwitch: NSSwitch!
}
