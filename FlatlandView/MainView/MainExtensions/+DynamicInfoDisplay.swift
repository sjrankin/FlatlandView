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
    func ShowMouseLocation(Latitude: Double, Longitude: Double, _ X: Double? = nil, _ Y: Double? = nil,
                           _ Z: Double? = nil)
    {
        #if true
        MouseInfoDelegate?.SetLocation(Latitude: "\(Latitude.RoundedTo(3))", Longitude: "\(Longitude.RoundedTo(3))",
                                       X, Y, Z)
        #else
        var LatString = "\(abs(Latitude.RoundedTo(3)))"
        var LonString = "\(abs(Longitude.RoundedTo(3)))"
        if Latitude >= 0.0
        {
            LatString.append(" N")
        }
        else
        {
            LatString.append(" S")
        }
        if Longitude >= 0.0
        {
            LonString.append(" E")
        }
        else
        {
            LonString.append(" W")
        }
        MouseInfoDelegate?.SetLocation(Latitude: LatString, Longitude: LonString, X, Y)
        #endif
    }
}
