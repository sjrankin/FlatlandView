//
//  View2DSettingsWindow.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class View2DSettingsWindow: NSViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Initialize2DMap()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    func Initialize2DMap()
    {
        ShowShadowsSwitch.state = Settings.GetBool(.Show2DShadows) ? .on : .off
        Show2DNight.state = Settings.GetBool(.ShowNight) ? .on : .off
        Show2DPolarCircles.state = Settings.GetBool(.Show2DPolarCircles) ? .on : .off
        Show2DPrimeMeridians.state = Settings.GetBool(.Show2DPrimeMeridians) ? .on : .off
        Show2DNoonMeridians.state = Settings.GetBool(.Show2DNoonMeridians) ? .on : .off
        Show2DEquator.state = Settings.GetBool(.Show2DEquator) ? .on : .off
        Show2DTropics.state = Settings.GetBool(.Show2DTropics) ? .on : .off
        let DarkType = Settings.GetEnum(ForKey: .NightDarkness, EnumType: NightDarknesses.self, Default: .Light)
        var DarkIndex = 0
        switch DarkType
        {
            case .VeryLight:
                DarkIndex = 0
                
            case .Light:
                DarkIndex = 1
                
            case .Dark:
                DarkIndex = 2
                
            case .VeryDark:
                DarkIndex = 3
        }
        NightDarknessSegment.selectedSegment = DarkIndex
        QuakeShape.removeAllItems()
        for QuakeShapeName in QuakeShapes2D.allCases
        {
            QuakeShape.addItem(withObjectValue: QuakeShapeName.rawValue)
        }
        let QShape = Settings.GetEnum(ForKey: .EarthquakeShape2D, EnumType: QuakeShapes2D.self, Default: .Circle)
        QuakeShape.selectItem(withObjectValue: QShape.rawValue)
    }
    
    @IBAction func HandleShow2DNightChanged(_ sender: Any)
    {
        if let Button = sender as? NSSwitch
        {
            Settings.SetBool(.ShowNight, Button.state == .on ? true : false)
        }
    }
    
    @IBAction func Handle2DGridLinesChanged(_ sender: Any)
    {
        if let Check = sender as? NSButton
        {
            let IsChecked = Check.state == .on ? true: false
            switch Check
            {
                case Show2DEquator:
                    Settings.SetBool(.Show2DEquator, IsChecked)
                    
                case Show2DTropics:
                    Settings.SetBool(.Show2DTropics, IsChecked)
                    
                case Show2DNoonMeridians:
                    Settings.SetBool(.Show2DNoonMeridians, IsChecked)
                    
                case Show2DPrimeMeridians:
                    Settings.SetBool(.Show2DPrimeMeridians, IsChecked)
                    
                case Show2DPolarCircles:
                    Settings.SetBool(.Show2DPolarCircles, IsChecked)
                    
                default:
                    return
            }
        }
    }
    
    @IBAction func HandleShadowsChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.Show2DShadows, Switch.state == .on ? true : false)
        }
    }
    
    @IBAction func HandleNightDarknessChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            let Index = Segment.selectedSegment
            let DarkTypes = [NightDarknesses.VeryLight, NightDarknesses.Light, NightDarknesses.Dark, NightDarknesses.VeryDark]
            if Index > DarkTypes.count - 1
            {
                return
            }
            Settings.SetEnum(DarkTypes[Index], EnumType: NightDarknesses.self, ForKey: .NightDarkness)
        }
    }
    
    @IBAction func HandleQuakeShapeChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            if let Contents = Combo.objectValueOfSelectedItem as? String
            {
                if let NewShape = QuakeShapes2D(rawValue: Contents)
                {
                    Settings.SetEnum(NewShape, EnumType: QuakeShapes2D.self, ForKey: .EarthquakeShape2D)
                }
            }
        }
    }
    
    @IBOutlet weak var QuakeShape: NSComboBox!
    @IBOutlet weak var ShowShadowsSwitch: NSSwitch!
    @IBOutlet weak var Show2DNoonMeridians: NSSwitch!
    @IBOutlet weak var Show2DPolarCircles: NSSwitch!
    @IBOutlet weak var Show2DPrimeMeridians: NSSwitch!
    @IBOutlet weak var Show2DTropics: NSSwitch!
    @IBOutlet weak var Show2DEquator: NSSwitch!
    @IBOutlet weak var Show2DNight: NSSwitch!
    @IBOutlet weak var NightDarknessSegment: NSSegmentedControl!
}


