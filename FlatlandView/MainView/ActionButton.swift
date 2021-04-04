//
//  ActionButton.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/4/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ActionButton: NSPopUpButton
{
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        CommonInitialization()
    }
    
    override init(frame buttonFrame: NSRect, pullsDown flag: Bool)
    {
        super.init(frame: buttonFrame, pullsDown: flag)
        CommonInitialization()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        CommonInitialization()
    }
    
    func CommonInitialization()
    {
        self.frame = NSRect(origin: CGPoint.zero, size: CGSize(width: 48, height: 48))
        self.pullsDown = true
        self.translatesAutoresizingMaskIntoConstraints = false
        let Cell = self.cell as? NSButtonCell
        Cell?.imagePosition = .imageOnly
        //Cell?.imageScaling = .scaleProportionallyUpOrDown
        Cell?.bezelStyle = .texturedRounded
        Cell?.imageDimsWhenDisabled = false
        self.action = #selector(HandleButtonPressed)
        
        self.removeAllItems()
        
        let ActionItem = NSMenuItem()
        ActionItem.image = NSImage(systemSymbolName: "sun.max", accessibilityDescription: nil)
        self.menu?.insertItem(ActionItem, at: 0)
        
        let NoonItem = NSMenuItem(title: "Noon", action: #selector(HandleNoonCenter), keyEquivalent: "")
        NoonItem.target = self
        NoonItem.image = NSImage(systemSymbolName: "sun.max", accessibilityDescription: nil)
        let HomeItem = NSMenuItem(title: "Home", action: #selector(HandleHomeCenter), keyEquivalent: "")
        HomeItem.target = self
        HomeItem.image = NSImage(systemSymbolName: "house.circle", accessibilityDescription: nil)
        self.menu?.addItem(NoonItem)
        self.menu?.addItem(HomeItem)
    }
    
    @objc func HandleNoonCenter()
    {
        self.removeItem(at: 0)
        let ActionItem = NSMenuItem()
        ActionItem.image = NSImage(systemSymbolName: "sun.max", accessibilityDescription: nil)
        self.menu?.insertItem(ActionItem, at: 0)
    }
    
    @objc func HandleHomeCenter()
    {
        self.removeItem(at: 0)
        let ActionItem = NSMenuItem()
        ActionItem.image = NSImage(systemSymbolName: "house.circle", accessibilityDescription: nil)
        self.menu?.insertItem(ActionItem, at: 0)
    }
    
    @objc func HandleButtonPressed()
    {
        
    }
}
