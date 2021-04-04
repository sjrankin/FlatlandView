//
//  ActionButton2.swift
//  Flatland
//
//  Created by Stuart Rankin on 4/4/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ActionButton2: NSGridView
{
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    func CommonInitialization()
    {
        self.yPlacement = .center
        
        ActionButtonX = NSButton(frame: NSRect(origin: CGPoint.zero, size: CGSize(width: 32, height: 32)))
        ActionButtonX.image = NSImage(systemSymbolName: "sun.max", accessibilityDescription: nil)
        ActionButtonX.target = self
        ActionButtonX.action = #selector(HandleButtonClicked)
        
        Disclosure = NSButton(frame: NSRect(origin: CGPoint.zero, size: CGSize(width: 24, height: 32)))
        Disclosure.bezelStyle = .disclosure
        Disclosure.state = .off
        Disclosure.target = self
        Disclosure.action = #selector(HandleDisclosureClicked)
        
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
