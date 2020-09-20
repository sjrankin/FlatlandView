//
//  +Main2TimeAndSun.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension Main2Controller
{
    /// Update the location of the sun. The sun can be on top or on the bottom and swaps places
    /// with the time label.
    func UpdateSunLocations()
    {
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .Globe3D ||
            Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .CubicWorld
        {
            return
        }
        
        let SunToDisplay = Settings.GetEnum(ForKey: .SunType, EnumType: SunNames.self, Default: .None)
        if PreviousSunType != SunToDisplay
        {
            switch SunToDisplay
            {
                case .None:
                    SunViewTop.isHidden = true
                    SunViewBottom.isHidden = true
                    SunViewTop.image = nil
                    SunViewBottom.image = nil
                    
                case .Classic1:
                    SunViewTop.image = NSImage(named: "SunX")
                    SunViewBottom.image = NSImage(named: "SunY")
                    
                case .Classic2:
                    SunViewTop.image = NSImage(named: "Sun2Up")
                    SunViewBottom.image = NSImage(named: "Sun2Down")
                    
                case .Durer:
                    SunViewTop.image = NSImage(named: "DurerSunUp")
                    SunViewBottom.image = NSImage(named: "DurerSunDown")
                    
                case .NaomisSun:
                    SunViewTop.image = NSImage(named: "NaomiSun1Up")
                    SunViewBottom.image = NSImage(named: "NaomiSun1Down")
                    
                case .PlaceHolder:
                    SunViewTop.image = NSImage(named: "SunPlaceHolder")
                    SunViewBottom.image = NSImage(named: "SunPlaceHolder")
                    
                case .Shining:
                    SunViewTop.image = NSImage(named: "StarShine")
                    SunViewBottom.image = NSImage(named: "StarShine")
                    
                case .Simple:
                    SunViewTop.image = NSImage(named: "SimpleSun")
                    SunViewBottom.image = NSImage(named: "SimpleSun")
                    
                case .Generic:
                    SunViewTop.image = NSImage(named: "GenericSun")
                    SunViewBottom.image = NSImage(named: "GenericSun")
            }
            PreviousSunType = SunToDisplay
        }
        
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .FlatNorthCenter
        {
            SunViewTop.isHidden = true
            SunViewBottom.isHidden = false
            if Settings.GetEnum(ForKey: .TimeLabel, EnumType: TimeLabels.self, Default: .None) == .None
            {
                MainTimeLabelTop.isHidden = true
                MainTimeLabelBottom.isHidden = true
            }
            else
            {
                MainTimeLabelTop.isHidden = false
                MainTimeLabelBottom.isHidden = true
            }
        }
        else
        {
            SunViewTop.isHidden = false
            SunViewBottom.isHidden = true
            if Settings.GetEnum(ForKey: .TimeLabel, EnumType: TimeLabels.self, Default: .UTC) == .None
            {
                MainTimeLabelTop.isHidden = true
                MainTimeLabelBottom.isHidden = true
            }
            else
            {
                MainTimeLabelBottom.isHidden = false
                MainTimeLabelTop.isHidden = true
            }
        }
    }
    
    /// Update certain text on the main view with the passed color.
    /// - Note: This is used to ensure the text is visible regardless of the background color. Callers should
    ///         pass a high-contrast variant of the background color to this function.
    func UpdateScreenText(With Color: NSColor)
    {
        MainTimeLabelTop.textColor = Color
        MainTimeLabelBottom.textColor = Color
        #if DEBUG
        VersionLabel.textColor = Color
        VersionValue.textColor = Color
        BuildLabel.textColor = Color
        BuildValue.textColor = Color
        BuildDateValue.textColor = Color
        BuildDateLabel.textColor = Color
        UptimeLabel.textColor = Color
        UptimeValue.textColor = Color
        #endif
    }
}
