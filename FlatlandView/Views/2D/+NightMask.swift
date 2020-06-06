//
//  +NightMask.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainView
{
    /// Set the night mask for 2D maps.
    func SetNightMask()
    {
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: ViewTypes.FlatSouthCenter) == .Globe3D
        {
            return
        }
        NightMaskImageView.wantsLayer = true
        NightMaskImageView.layer?.zPosition = CGFloat(LayerZLevels.NightMaskLayer.rawValue)
        if !Settings.GetBool(.ShowNight)
        {
            NightMaskImageView.image = nil
            return
        }
        if let Image = GetNightMask(ForDate: Date())
        {
            NightMaskImageView.image = Image
        }
        else
        {
            print("No night mask for \(Date()) found.")
        }
    }
    
    /// Given a date, return a mask image for a flat map.
    /// - Parameter From: The date for the night mask.
    /// - Returns: Name of the night mask image file.
    func MakeNightMaskName(From: Date) -> String
    {
        let Day = Calendar.current.component(.day, from: From)
        let Month = Calendar.current.component(.month, from: From) - 1
        let MonthName = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][Month]
        var Prefix = ""
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .FlatNorthCenter
        {
            Prefix = ""
        }
        else
        {
            Prefix = "South_"
        }
        return "\(Prefix)\(Day)_\(MonthName)"
    }
    
    /// Get a night mask image for a flat map for the specified date.
    /// - Parameter ForDate: The date of the night mask.
    /// - Returns: Image for the passed date (and flat map orientation). Nil returned on error.
    func GetNightMask(ForDate: Date) -> NSImage?
    {
        let AlphaLevels: [NightDarknesses: CGFloat] =
            [
                .VeryLight: 0.25,
                .Light: 0.4,
                .Dark: 0.6,
                .VeryDark: 0.75
        ]
        let ImageName = MakeNightMaskName(From: ForDate)
        let DarkLevel = Settings.GetEnum(ForKey: .NightDarkness, EnumType: NightDarknesses.self, Default: .Light)
        let MaskAlpha = AlphaLevels[DarkLevel]!
        let MaskImage = NSImage(named: ImageName)!
        let Final = MaskImage.Alpha(CGFloat(MaskAlpha))
        return Final
    }
}
