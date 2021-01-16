//
//  +DynamicInfoDisplay.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/9/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainController
{
    // MARK: - Geographic coordinate display
    
    /// Update the location of the mouse information window. Called in response to window size changes.
    func UpdateMouseWindowLocation()
    {
        if Settings.GetBool(.FollowMouse)
        {
            if let Controller = MouseLocationController
            {
                let ViewWidth = Controller.view.frame.width
                Controller.view.frame = NSRect(x: self.view.frame.size.width - ViewWidth - 10,
                                               y: 40.0,
                                               width: ViewWidth,
                                               height: 100.0)
            }
        }
    }
    
    /// Show or hide the mouse location view.
    /// - Parameter Visible: If true, the mouse location is shown. If false, it is hidden. Calling this function
    ///                      with `Visible` set to true twice (or more) in a row results in no action being
    ///                      taken.
    func SetMouseLocationVisibility(Visible: Bool)
    {
        if Visible
        {
            if MouseInfoView != nil
            {
                return
            }
            let Storyboard = NSStoryboard(name: "FloatingViews", bundle: nil)
            if let Controller = Storyboard.instantiateController(withIdentifier: "MouseInfoController") as? MouseInfoController
            {
                MouseLocationController = Controller
                Controller.view.wantsLayer = true
                Controller.view.layer?.zPosition = 100000
                Controller.view.alphaValue = 0.0
                let ViewWidth = Controller.view.frame.width
                Controller.view.frame = NSRect(x: self.view.frame.size.width - ViewWidth - 10,
                                               y: 40.0,
                                               width: ViewWidth,
                                               height: 100)
                self.view.addSubview(Controller.view)
                MouseInfoDelegate = Controller
                MouseInfoView = Controller
                Controller.SetMainDelegate(self)
                NSAnimationContext.runAnimationGroup
                {
                    Context in
                    Context.duration = 0.15
                    self.MouseInfoView?.view.animator().alphaValue = 1.0
                }
            }
        }
        else
        {
            NSAnimationContext.runAnimationGroup
            {
                Context in
                Context.duration = 0.3
                self.MouseInfoView?.view.animator().alphaValue = 0.0
            } completionHandler:
            {
                self.MouseInfoView?.removeFromParent()
                self.MouseInfoView = nil
            }
        }
    }
    
    /// Processes the raw geographic coordinates and sends them to the display for viewing.
    /// - Parameter Latitude: The latitude of the location where the mouse is.
    /// - Parameter Longitude: The longitude of the location where the mouse is.
    /// - Parameter Caller: The caller of the function.
    func ShowMouseLocation(Latitude: Double, Longitude: Double, Caller: String)
    {
        MouseInfoDelegate?.SetLocation(Latitude: Latitude, Longitude: Longitude, Caller: Caller)
    }
}
