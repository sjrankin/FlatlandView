//
//  GeneralIndicator.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/14/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class GeneralIndicator: NSView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        CommonInitialization()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        CommonInitialization()
    }
    
    func CommonInitialization()
    {
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.clear.cgColor
        self.layer?.isOpaque = true
    }
    
    private var _BGColor: NSColor = NSColor.clear
    {
        didSet
        {
            self.setNeedsDisplay(self.bounds)
        }
    }
    @IBInspectable public var BGColor: NSColor
    {
        get
        {
            return _BGColor
        }
        set
        {
            _BGColor = newValue
        }
    }
    
    private var _IndicatorType: String = Indicators.ClockIndicator.rawValue
    {
        didSet
        {
            if let NewType = Indicators(rawValue: _IndicatorType)
            {
                Indicator = NewType
            }
        }
    }
    @IBInspectable public var IndicatorType: String
    {
        get
        {
            return _IndicatorType
        }
        set
        {
            _IndicatorType = newValue
        }
    }
    
    private var _Indicator: Indicators = .ClockIndicator
        {
            didSet
            {
                
            }
        }
    public var Indicator: Indicators
    {
        get
        {
            return _Indicator
        }
        set
        {
            _Indicator = newValue
        }
    }
    
    override func draw(_ dirtyRect: NSRect)
    {
        self.layer?.backgroundColor = _BGColor.cgColor
    }
}

enum Indicators: String, CaseIterable
{
    case Indefinite = "Indefinite"
    case ClockIndicator = "ClockIndicator"
    case PiePercent = "PiePercent"
}
