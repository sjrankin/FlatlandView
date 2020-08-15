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
    func InitializeStatusView()
    {
        StatusContainer.wantsLayer = true
        StatusContainer.layer?.zPosition = CGFloat(LayerZLevels.StatusViewLayer.rawValue)
        StatusContainer.layer?.borderWidth = 4.0
        StatusContainer.layer?.borderColor = NSColor.gray.cgColor
        StatusContainer.layer?.cornerRadius = 15.0
        
        let StatusUIStoryboard = NSStoryboard(name: "StatusView", bundle: nil)
        if let StatusUI = StatusUIStoryboard.instantiateController(withIdentifier: "StatusViewUI") as? NSViewController
        {
            StatusDelegate = StatusUI as? StatusViewController
            StatusContainer.addSubview(StatusUI.view)
        }
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
        let Animator = StatusContainer.animator()
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.allowsImplicitAnimation = true
        NSAnimationContext.current.duration = Duration
        Animator.alphaValue = To
        NSAnimationContext.endGrouping()
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
        StatusDelegate?.ShowText(Text)
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
        StatusDelegate?.ShowText(Text)
        perform(#selector(HideStatusBox), with: Completed, afterDelay: After)
    }
    
    @objc func HideStatusBox(Closure: (() -> ())? = nil)
    {
        HideStatus()
        Closure?()
    }
    
    func DisplaySubText(_ Text: String, ShowIfNotVisible: Bool = true)
    {
        if ShowIfNotVisible
        {
            if !ShowingStatus
            {
                ShowStatus()
            }
        }
        StatusDelegate?.ShowSubText(Text)
    }
}
