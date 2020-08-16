//
//  StatusViewController.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/14/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class StatusViewController: NSViewController, StatusProtocol
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ResetUI()
        ResetTextUI()
        ResetSubTextUI()
    }
    
    override func becomeFirstResponder() -> Bool
    {
        return true
    }
    
    func TextBackground() -> CAGradientLayer
    {
        let Layer = CAGradientLayer()
        Layer.frame = TextContainer.frame
        Layer.bounds = TextContainer.frame
        Layer.colors = [
            NSColor(calibratedRed: 0.6, green: 0.6, blue: 0.6, alpha: 1.0).cgColor,
            NSColor(calibratedRed: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor,
            NSColor(calibratedRed: 0.4, green: 0.4, blue: 0.4, alpha: 1.0).cgColor,
            NSColor(calibratedRed: 0.2, green: 0.2, blue: 0.2, alpha: 1.0).cgColor,
            NSColor(calibratedRed: 0.09, green: 0.09, blue: 0.09, alpha: 1.0).cgColor
        ]
        Layer.locations = [
            NSNumber(value: 0.0),
            NSNumber(value: 0.5),
            NSNumber(value: 0.8),
            NSNumber(value: 0.95),
            NSNumber(value: 1.0)
        ]
        return Layer
    }
    
    // MARK: - Status delegate functions.
    
    func ResetUI()
    {
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor(calibratedRed: 0.1, green: 0.1, blue: 0.1, alpha: 0.75).cgColor
        self.view.layer?.zPosition = CGFloat(LayerZLevels.StatusViewLayer.rawValue)
        self.view.alphaValue = 1.0
    }
    
    func SetUIBackground(To Color: NSColor)
    {
        self.view.layer?.backgroundColor = Color.cgColor
    }
    
    func ResetTextUI()
    {
        TextContainer.wantsLayer = true
        TextContainer.layer?.borderColor = NSColor(calibratedRed: 0.25, green: 0.25, blue: 0.25, alpha: 0.85).cgColor
        TextContainer.layer?.borderWidth = 2.0
        TextContainer.layer?.cornerRadius = 10.0
        let BG = TextBackground()
        TextContainer.layer?.addSublayer(BG)
        TextField.textColor = NSColor.white
        TextField.font = NSFont.systemFont(ofSize: 20.0)
        TextField.stringValue = ""
    }
    
    func ResetSubTextUI()
    {
        SubTextField.textColor = NSColor.white
        SubTextField.font = NSFont.systemFont(ofSize: 14.0)
        SubTextField.stringValue = ""
    }
    
    func SetSubTextFont(_ Font: NSFont)
    {
        SubTextField.font = Font
    }
    
    func SetTextBackground(To Color: NSColor)
    {
        TextContainer.layer?.sublayers?.removeAll()
        TextContainer.layer?.backgroundColor = Color.cgColor
    }
    
    func ShowText(_ TextString: String)
    {
        TextField.stringValue = TextString
    }
    
    func ShowSubText(_ SubText: String)
    {
        SubTextField.stringValue = SubText
    }
    
    func SetTextFont(_ Font: NSFont)
    {
        TextField.font = Font
    }
    
    var CurrentIndicator: Indicators = .PiePercent
    
    func DisplayIndicator(_ Indicator: Indicators)
    {
    }
    
    func HideIndicator()
    {
        IndicatorView.isHidden = true
    }
    
    func ShowIndicator()
    {
        IndicatorView.isHidden = false
    }
    
    func SetIndicatorPercent(_ Percent: Double)
    {
        if CurrentIndicator == .PiePercent
        {
            
        }
    }
    
    override func mouseDown(with event: NSEvent)
    {
        super.mouseDown(with: event)
        print("Mouse down in StatusViewController.")
    }
    
    @IBOutlet weak var SubTextField: NSTextField!
    @IBOutlet weak var TextField: NSTextField!
    @IBOutlet weak var MainGrid: NSGridView!
    @IBOutlet weak var IndicatorView: GeneralIndicator!
    @IBOutlet weak var TextContainer: NSView!
}
