//
//  ActionButton3.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/4/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ActionButton3: NSGridView
{
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        CommonInitialization()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        CommonInitialization()
    }
    
    func CommonInitialization()
    {
        //self.orientation = .horizontal
        //self.frame = NSRect(origin: CGPoint.zero, size: CGSize(width: 72, height: 48))
        
//        ActionButtonX = NSButton(frame: NSRect(origin: CGPoint.zero, size: CGSize(width: 48, height: 48)))
        ActionButtonX = NSButton(image: NSImage(named: "sun.max.svg")!, target: self, action: #selector(HandleButtonClicked))
        ActionButtonX.imageScaling = .scaleProportionallyUpOrDown
        ActionButtonX.frame = NSRect(origin: CGPoint.zero, size: CGSize(width: 48, height: 48))
        ActionButtonX.bezelStyle = .shadowlessSquare
        ActionButtonX.sizeToFit()
//        ActionButtonX.imageScaling = .scaleProportionallyUpOrDown
//        ActionButtonX.image = NSImage(named: "sun.max.svg")
//        ActionButtonX.image = NSImage(systemSymbolName: "sun.max", accessibilityDescription: nil)
//        ActionButtonX.target = self
//        ActionButtonX.action = #selector(HandleButtonClicked)
        ActionButtonX.focusRingType = .none
        ActionButtonX.isBordered = false
        ActionButtonX.contentTintColor = NSColor(named: "ControlBlack")
        ActionButtonX.wantsLayer = true
        ActionButtonX.layer?.backgroundColor = NSColor.systemYellow.cgColor
  
        Disclosure = NSButton(image: NSImage(named: "chevron.down.svg")!, target: self, action: #selector(HandleDisclosureClicked))
//        Disclosure = NSButton(frame: NSRect(origin: CGPoint.zero, size: CGSize(width: 24, height: 48)))
        Disclosure.bezelStyle = .disclosure
//        Disclosure.image = NSImage(named: "chevron.down.svg")
//        Disclosure.image = NSImage(systemSymbolName: "chevron.down", accessibilityDescription: nil)
        Disclosure.title = ""
//        Disclosure.target = self
//        Disclosure.action = #selector(HandleDisclosureClicked)
        Disclosure.focusRingType = .none
        Disclosure.isBordered = false
        Disclosure.contentTintColor = NSColor(named: "ControlBlack")
        Disclosure.wantsLayer = true
        Disclosure.layer?.backgroundColor = NSColor.systemOrange.cgColor
        
        //self.addView(ActionButtonX, in: .leading)
        //self.addView(Disclosure, in: .trailing)
        self.addColumn(with: [ActionButtonX])
        self.addColumn(with: [Disclosure])
    }
    
    var Disclosure: NSButton!
    var ActionButtonX: NSButton!
    
    @objc func HandleButtonClicked()
    {
        print("Button clicked")
    }
    
    @objc func HandleDisclosureClicked()
    {
        print("Disclosure clicked")
    }
}
