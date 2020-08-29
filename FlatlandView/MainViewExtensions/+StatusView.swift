//
//  +StatusView.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/14/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainView
{
    /// Initialize the status view.
    func InitializeStatusView()
    {
        StatusViewText.wantsLayer = true
        StatusViewText.layer?.zPosition = 500
        StatusViewIndicator.wantsLayer = true
        StatusViewIndicator.layer?.zPosition = 500
        StatusContainer.wantsLayer = true
        StatusContainer.layer?.zPosition = CGFloat(LayerZLevels.StatusViewLayer.rawValue)
        StatusContainer.layer?.borderWidth = 4.0
        #if DEBUG
        StatusContainer.layer?.borderColor = NSColor.systemYellow.cgColor
        #else
        StatusContainer.layer?.borderColor = NSColor.gray.cgColor
        #endif
        StatusContainer.layer?.cornerRadius = 15.0
        SetStatusFont(NSFont.systemFont(ofSize: 14.0))
    }
    
    func SetStatusFont(_ Font: NSFont)
    {
        StatusViewText.font = Font
    }
    
    func HideStatus()
    {
        ShowingStatus = false
        AnimateStatusAlpha(To: 0.0, Duration: 0.5)
    }
    
    func ShowStatus()
    {
        ShowingStatus = true
        AnimateStatusAlpha(To: 1.0, Duration: 0.2)
    }
    
    func AnimateStatusAlpha(To: CGFloat, Duration: Double)
    {
        NSAnimationContext.runAnimationGroup
        {
            Context in
            Context.duration = Duration
            Context.allowsImplicitAnimation = true
            self.StatusContainer.animator().alphaValue = To
        } completionHandler:
        {
            if To == 0.0
            {
                self.StatusContainer.isHidden = true
                self.StatusContainer.alphaValue = 0.0
            }
            else
            {
                self.StatusContainer.isHidden = false
                self.StatusContainer.alphaValue = 1.0
            }
        }
    }
    
    func DisplayStatusText(_ Text: String, ShowIfNotVisible: Bool = true)
    {
        if ShowIfNotVisible
        {
            if !ShowingStatus
            {
                ShowStatus()
            }
        }
        StatusViewText.stringValue = Text
    }
    
    func DisplayStatusText(_ Text: String, Hide After: Double, ShowIfNotVisible: Bool = true,
                           Completed: (() -> ())? = nil)
    {
        if ShowIfNotVisible
        {
            if !ShowingStatus
            {
                ShowStatus()
            }
        }
        StatusViewText.stringValue = Text
        perform(#selector(HideStatusBox), with: Completed, afterDelay: After)
    }
    
    @objc func HideStatusBox(Closure: (() -> ())? = nil)
    {
        HideStatus()
        Closure?()
    }
}

