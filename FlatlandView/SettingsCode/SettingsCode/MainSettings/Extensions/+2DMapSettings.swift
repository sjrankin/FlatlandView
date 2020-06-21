//
//  +2DMapSettings.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainSettings
{
    func Initialize2DMap()
    {
        Show2DNight.state = Settings.GetBool(.ShowNight) ? .on : .off
        Show2DPolarCircles.state = Settings.GetBool(.Show2DPolarCircles) ? .on : .off
        Show2DPrimeMeridians.state = Settings.GetBool(.Show2DPrimeMeridians) ? .on : .off
        Show2DNoonMeridians.state = Settings.GetBool(.Show2DNoonMeridians) ? .on : .off
        Show2DEquator.state = Settings.GetBool(.Show2DEquator) ? .on : .off
        Show2DTropics.state = Settings.GetBool(.Show2DTropics) ? .on : .off
        let CurrentSun = Settings.GetEnum(ForKey: .SunType, EnumType: SunNames.self, Default: .Classic1)
        var Index = 0
        var SunIndex = -1
        for SomeSun in SunNames.allCases
        {
            if let ImageName = SunMap[SomeSun]
            {
                if SomeSun == CurrentSun
                {
                    SunIndex = Index
                }
                var SunImage = NSImage(named: ImageName)
                SunImage = Utility.ResizeImage(Image: SunImage!, Longest: 50.0)
                SunImageList.append((SomeSun, SunImage!))
            }
            Index = Index + 1
        }
        if SunIndex > -1
        {
            let ISet = IndexSet(integer: SunIndex)
            SunSelector.selectRowIndexes(ISet, byExtendingSelection: false)
            SunSelector.scrollRowToVisible(SunIndex)
        }
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
    }
    
    @IBAction func HandleShow2DNightChanged(_ sender: Any)
    {
        if let Button = sender as? NSButton
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
            MainDelegate?.Refresh("MainSettings.Handle2DGridLinesChanged")
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
            MainDelegate?.Refresh("MainSettings.HandleNightDarknessChanged")
        }
    }
}
