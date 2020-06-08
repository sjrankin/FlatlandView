//
//  +FlatView.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/25/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension MainView
{
    /// Initialize the Flatland (2D) mode controls.
    func InitializeFlatland()
    {
        FlatView.wantsLayer = true
        FlatView.layer?.zPosition = CGFloat(LayerZLevels.CurrentLayer.rawValue)
        FlatView.layer?.backgroundColor = NSColor.clear.cgColor
        CityView2D.wantsLayer = true
        CityView2D.layer?.backgroundColor = NSColor.clear.cgColor
        GridOverlay.wantsLayer = true
        GridOverlay.layer?.backgroundColor = NSColor.clear.cgColor
        HourLayer2D.wantsLayer = true
        HourLayer2D.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    /// Sets the visibility of either the 3D globe or 2D map depending on the passed boolean.
    /// - Parameter FlatIsVisible: If true, 2D maps are visible. If false, 3D maps are visible.
    func SetFlatlandVisibility(FlatIsVisible: Bool)
    {
        NightMaskImageView.isHidden = !FlatIsVisible
        FlatViewMainImage.isHidden = !FlatIsVisible
        GridOverlay.isHidden = !FlatIsVisible
        HourLayer2D.isHidden = !FlatIsVisible
        Show2DHours()
        if FlatIsVisible
        {
            //Set for 2D flat view.
            FlatView.layer?.zPosition = CGFloat(LayerZLevels.CurrentLayer.rawValue)
            World3DView.layer?.zPosition = CGFloat(LayerZLevels.InactiveLayer.rawValue)
            SunViewTop?.isHidden = false
            SunViewBottom?.isHidden = false
            SetNightMask()
            UpdateSunLocations()
        }
        else
        {
            //Set for 3D globe view.
            FlatView.layer?.zPosition = CGFloat(LayerZLevels.InactiveLayer.rawValue)
            World3DView.layer?.zPosition = CGFloat(LayerZLevels.CurrentLayer.rawValue)
            SunViewTop?.isHidden = true
            SunViewBottom?.isHidden = true
            MainTimeLabelBottom.isHidden = true
            MainTimeLabelTop.isHidden = false
        }
    }
    
    /// Resized the image to fit in the bounds of `FlatViewMainImage`.
    /// - Note: Required due to NSImageView aspect fitting bug.
    /// - Parameter Raw: The image to resize.
    /// - Returns: Resized image.
    func FinalizeImage(_ Raw: NSImage) -> NSImage
    {
        let FinalSize = FlatViewMainImage.bounds.size
        let FinalImage = Utility.ResizeImage(Image: Raw, Longest: max(FinalSize.width, FinalSize.height))
        return FinalImage
    }
    
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
    
    /// Convert the passed time (in terms of percent of a day) into a radian.
    /// - Parameter From: The percent of the day that has passed.
    /// - Parameter With: Offset value to subtract from the number of degrees intermediate value.
    /// - Returns: Radial equivalent of the time percent.
    func MakeRadialTime(From Percent: Double, With Offset: Double) -> Double
    {
        let Degrees = 360.0 * Percent - Offset
        return Degrees * Double.pi / 180.0
    }
    
    /// Rotates the Earth image to the passed number of degrees where Greenwich England is 0°.
    /// - Note: The code ported from iOS does not work with macOS. Instead I used code from [Rotating a View is Not Easy](https://nyrra33.com/2017/12/21/rotating-a-view-is-not-easy/)
    /// - Parameter Percent: Percent of the day, eg, if 0.25 is passed, it is 6:00 AM. This value
    ///                      is expected to be normalized.
    func RotateImageTo(_ Percent: Double)
    {
        PreviousPercent = Percent
        var FinalOffset = 0.0
        var Multiplier = -1.0
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .FlatSouthCenter
        {
            FinalOffset = 180.0
            Multiplier = 1.0
        }
        //Be sure to rotate the proper direction based on the map.
        let Radians = MakeRadialTime(From: Percent, With: FinalOffset) * Multiplier
        FlatViewMainImage.wantsLayer = true
        FlatViewMainImage.imageAlignment = .alignCenter
        FlatViewMainImage.imageScaling = .scaleProportionallyDown
        if let AnimatorLayer = FlatViewMainImage.animator().layer
        {
            //Code from Rotating a View is Not Easy.
            FlatViewMainImage.layer?.position = CGPoint(x: FlatViewMainImage.frame.midX,
                                                        y: FlatViewMainImage.frame.midY)
            FlatViewMainImage.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            NSAnimationContext.beginGrouping()
            NSAnimationContext.current.allowsImplicitAnimation = true
            AnimatorLayer.transform = CATransform3DMakeRotation(CGFloat(-Radians), 0.0, 0.0, 1.0)
            NSAnimationContext.endGrouping()
        }
        if Settings.GetEnum(ForKey: .HourType, EnumType: HourValueTypes.self, Default: .None) == .RelativeToLocation
        {
            if let HAnimatorLayer = HourLayer2D.animator().layer
            {
                HourLayer2D.layer?.position = CGPoint(x: HourLayer2D.frame.midX,
                                                      y: HourLayer2D.frame.midY)
                HourLayer2D.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                NSAnimationContext.beginGrouping()
                NSAnimationContext.current.allowsImplicitAnimation = true
                HAnimatorLayer.transform = CATransform3DMakeRotation(CGFloat(-Radians), 0.0, 0.0, 1.0)
                NSAnimationContext.endGrouping()
            }
        }
        if Settings.GetBool(.ShowGrid)
        {
            DrawGrid(Radians) 
        }
        if Settings.GetBool(.ShowCities)
        {
            PlotCities(InCityList: CityTestList, RadialTime: Radians, CityListChanged: true) 
        }
    }
}
