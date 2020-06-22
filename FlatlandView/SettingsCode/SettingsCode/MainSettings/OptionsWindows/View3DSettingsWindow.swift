//
//  View3DSettingsWindow.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

class View3DSettingsWindow: NSViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Initialize3DMap()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    func Initialize3DMap()
    {
        let Gap = Settings.GetDouble(.MinorGrid3DGap)
        if let GapIndex = [5.0, 15.0, 30.0, 45.0].firstIndex(of: Gap)
        {
            MinorGridGapSegment.selectedSegment = GapIndex
        }
        else
        {
            //If we don't have a valid index, select 1, which corresponds to 15°.
            MinorGridGapSegment.selectedSegment = 1
        }
        let GlobeTransparency = Settings.GetDouble(.GlobeTransparencyLevel, 0.0)
        if let AlphaIndex = [0.0, 0.15, 0.35, 0.50].firstIndex(of: GlobeTransparency)
        {
            GlobeTransparencySegment.selectedSegment = AlphaIndex
        }
        else
        {
            //If we don't have a valid index, select 0 which corresponds to a fully opaque globe.
            GlobeTransparencySegment.selectedSegment = 0
        }
        Show3DTropics.state = Settings.GetBool(.Show3DTropics) ? .on : .off
        Show3DMinorGridLines.state = Settings.GetBool(.Show3DMinorGrid) ? .on : .off
        Show3DPrimeMeridians.state = Settings.GetBool(.Show3DPrimeMeridians) ? .on : .off
        Show3DPolarCircles.state = Settings.GetBool(.Show3DPolarCircles) ? .on : .off
        Show3DEquator.state = Settings.GetBool(.Show3DEquator) ? .on : .off
        ShowMoonlightSwitch.state = Settings.GetBool(.ShowMoonLight) ? .on : .off
        Show3DGridLines.state = Settings.GetBool(.Show3DGridLines) ? .on : .off
        PoleShapeCombo.removeAllItems()
        for PoleShape in PolarShapes.allCases
        {
            PoleShapeCombo.addItem(withObjectValue: PoleShape.rawValue)
        }
        let CurrentPole = Settings.GetEnum(ForKey: .PolarShape, EnumType: PolarShapes.self, Default: .None)
        PoleShapeCombo.selectItem(withObjectValue: CurrentPole.rawValue)
        if Settings.GetBool(.ShowMovingStars)
        {
            SampleStars.Show()
        }
        else
        {
            SampleStars.Hide()
        }
        switch Settings.GetEnum(ForKey: .StarSpeeds, EnumType: StarSpeeds.self, Default: .Medium)
        {
            case .Slow:
                StarSpeedSegment.selectedSegment = 0
            
            case .Medium:
                StarSpeedSegment.selectedSegment = 1
            
            case .Fast:
                StarSpeedSegment.selectedSegment = 2
        }
        #if DEBUG
        #else
        DebugButton.removeFromSuperview()
        #endif
        Background3DColorWell.color = Settings.GetColor(.BackgroundColor3D, NSColor.black)
        UseAmbientLight.state = Settings.GetBool(.UseAmbientLight) ? .on : .off
    }
    
    @IBAction func Handle3DGridLineChanged(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            let IsChecked = Button.state == .on ? true : false
            switch Button
            {
                case Show3DGridLines:
                    Settings.SetBool(.Show3DGridLines, IsChecked)
                
                case Show3DMinorGridLines:
                    Settings.SetBool(.Show3DMinorGrid, IsChecked)
                
                case Show3DPrimeMeridians:
                    Settings.SetBool(.Show3DPrimeMeridians, IsChecked)
                
                case Show3DPolarCircles:
                    Settings.SetBool(.Show3DPolarCircles, IsChecked)
                
                case Show3DTropics:
                    Settings.SetBool(.Show3DTropics, IsChecked)
                
                case Show3DEquator:
                    Settings.SetBool(.Show3DEquator, IsChecked)
                
                default:
                    return
            }
        }
    }
    
    @IBAction func HandleMovingStarChanged(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            Settings.SetBool(.ShowMovingStars, Button.state == .on ? true : false)
            if Settings.GetBool(.ShowMovingStars)
            {
                SampleStars.Show()
            }
            else
            {
                SampleStars.Hide()
            }
        }
    }
    
    @IBAction func HandleStarSpeedChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            switch Segment.selectedSegment
            {
                case 0:
                    SampleStars.Hide()
                    Settings.SetBool(.ShowMovingStars, false)
                
                case 1:
                    SampleStars.Show()
                    Settings.SetEnum(.Slow, EnumType: StarSpeeds.self, ForKey: .StarSpeeds)
                    Settings.SetBool(.ShowMovingStars, true)
                
                case 2:
                    SampleStars.Show()
                    Settings.SetEnum(.Medium, EnumType: StarSpeeds.self, ForKey: .StarSpeeds)
                    Settings.SetBool(.ShowMovingStars, true)
                
                case 3:
                    SampleStars.Show()
                    Settings.SetEnum(.Fast, EnumType: StarSpeeds.self, ForKey: .StarSpeeds)
                    Settings.SetBool(.ShowMovingStars, true)
                
                default:
                    return
            }
            if Settings.GetBool(.ShowMovingStars)
            {
                var NewSpeed = 1.0
                switch Settings.GetEnum(ForKey: .StarSpeeds, EnumType: StarSpeeds.self, Default: .Medium)
                {
                    case .Slow:
                        NewSpeed = 1.0
                    
                    case .Medium:
                        NewSpeed = 3.0
                    
                    case .Fast:
                        NewSpeed = 7.0
                }
                SampleStars.Show(SpeedMultiplier: NewSpeed)
            }
        }
    }
    
    @IBAction func HandleMoonLightChanged(_ sender: Any)
    {
        if let Button = sender as? NSSwitch
        {
            Settings.SetBool(.ShowMoonLight, Button.state == .on ? true : false)
        }
    }
    
    @IBAction func HandleTransparencyChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            if Segment.indexOfSelectedItem > 3
            {
                Settings.SetDouble(.MinorGrid3DGap, 0.0)
            }
            else
            {
                let Transparency = [0.0, 0.15, 0.35, 0.50][Segment.indexOfSelectedItem]
                Settings.SetDouble(.GlobeTransparencyLevel, Transparency)
            }
        }
    }
    
    @IBAction func HandleGridGapChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            if Segment.indexOfSelectedItem > 3
            {
                Settings.SetDouble(.MinorGrid3DGap, 15.0)
            }
            else
            {
                let Gap = [5.0, 15.0, 30.0, 45.0][Segment.indexOfSelectedItem]
                Settings.SetDouble(.MinorGrid3DGap, Gap)
            }
        }
    }
    
    @IBAction func HandlePoleShapeChanged(_ sender: Any)
    {
        if let Combo = sender as? NSComboBox
        {
            if let RawPole = Combo.objectValueOfSelectedItem as? String
            {
                if let Pole = PolarShapes(rawValue: RawPole)
                {
                    Settings.SetEnum(Pole, EnumType: PolarShapes.self, ForKey: .PolarShape)
                }
            }
        }
    }
    
    @IBAction func HandleDebugPressed(_ sender: Any)
    {
        #if DEBUG
        let Storyboard = NSStoryboard(name: "Settings", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "Debug3DWindow") as? ThreeDDebugWindow
        {
            let Window = WindowController.window
            self.view.window?.beginSheet(Window!, completionHandler: nil)
        }
        #endif
    }
    
    @IBAction func HandleBackground3DColorAction(_ sender: Any)
    {
        if let ColorWell = sender as? NSColorWell
        {
            Settings.SetColor(.BackgroundColor3D, ColorWell.color)
        }
    }
    
    @IBAction func HandleAmbientLightChanged(_ sender: Any)
    {
        if let Button = sender as? NSSwitch
        {
            Settings.SetBool(.UseAmbientLight, Button.state == .on ? true : false)
        }
    }
    
    @IBOutlet weak var Show3DMinorGridLines: NSSwitch!
    @IBOutlet weak var Show3DPolarCircles: NSSwitch!
    @IBOutlet weak var Show3DPrimeMeridians: NSSwitch!
    @IBOutlet weak var Show3DTropics: NSSwitch!
    @IBOutlet weak var Show3DEquator: NSSwitch!
    @IBOutlet weak var Show3DGridLines: NSSwitch!
    @IBOutlet weak var SampleStars: Starfield!
    @IBOutlet weak var StarSpeedSegment: NSSegmentedControl!
    @IBOutlet weak var UseAmbientLight: NSSwitch!
    @IBOutlet weak var Background3DColorWell: NSColorWell!
    @IBOutlet weak var PoleShapeCombo: NSComboBox!
    @IBOutlet weak var ShowMoonlightSwitch: NSSwitch!
    @IBOutlet weak var DebugButton: NSButton!
    @IBOutlet weak var GlobeTransparencySegment: NSSegmentedControl!
    @IBOutlet weak var MinorGridGapSegment: NSSegmentedControl!
}
