//
//  ClockIndicator.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/13/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ClockIndicator: GeneralIndicator
{
    init(Frame: CGRect)
    {
        super.init(frame: Frame)
        LocalInitialization()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        LocalInitialization()
    }
    
    func LocalInitialization()
    {
        let MinuteInterval: Double = 0.01
        let HourInterval: Double = MinuteInterval * 60.0
        
        HourPoint = HourPoint(For: 0.0)
        
        let _ = Timer.scheduledTimer(timeInterval: HourInterval, target: self,
                                     selector: #selector(UpdateHours),
                                     userInfo: nil, repeats: true)
        
        let _ = Timer.scheduledTimer(timeInterval: MinuteInterval, target: self,
                                     selector: #selector(UpdateMinutes),
                                     userInfo: nil, repeats: true)
    }
    
    func MinutePoint(For Degrees: Double) -> CGPoint
    {
        let MinuteRadius: Double = Double(Radius) * 0.8
        let Radians = (Degrees - 90.0) * Double.pi / 180.0
        let X = MinuteRadius * cos(Radians)
        let Y = MinuteRadius * sin(Radians)
        return CGPoint(x: X, y: Y)
    }
    
    func HourPoint(For Degrees: Double) -> CGPoint
    {
        let MinuteRadius: Double = Double(Radius) * 0.6
        let Radians = (Degrees - 90.0) * Double.pi / 180.0
        let X = MinuteRadius * cos(Radians)
        let Y = MinuteRadius * sin(Radians)
        return CGPoint(x: X - Double(RingThickness),
                       y: Y - Double(RingThickness))
    }
    
    @objc func UpdateHours()
    {
        let HourAngle = 360.0 * (Double(CurrentHour) / 12.0)
        HourPoint = HourPoint(For: HourAngle)
        CurrentHour = CurrentHour - 1
        if CurrentHour < 0
        {
            CurrentHour = 11
        }
        
        setNeedsDisplay(self.bounds)
    }
    
    @objc func UpdateMinutes()
    {
        let MinuteAngle = 360.0 * (Double(CurrentMinute) / 60.0)
        MinutePoint = MinutePoint(For: MinuteAngle)
        CurrentMinute = CurrentMinute - 1
        if CurrentMinute < 0
        {
            CurrentMinute = 60
        }
        
        setNeedsDisplay(self.bounds)
    }
    
    var CurrentMinute = 0
    var CurrentHour = 0
    
    var HourPoint: CGPoint = CGPoint()
    var MinutePoint: CGPoint = CGPoint()
    
    var RingColor: NSColor = NSColor.black
    var RingFillColor: NSColor = NSColor.systemYellow
    var HourColor: NSColor = NSColor.brown
    var MinuteColor: NSColor = NSColor.blue
    var RingThickness: CGFloat = 4.0
    var HourThickness: CGFloat = 3.5
    var MinuteThickness: CGFloat = 2.0
    var Center = CGPoint()
    var Radius: CGFloat = 0.0
    
    override func draw(_ rect: CGRect)
    {
        let Context = NSGraphicsContext.current?.cgContext
        Radius = min(frame.size.width, frame.size.height) * 0.5
        Center = CGPoint(x: bounds.size.width / 2.0 + RingThickness,
                         y: bounds.size.height / 2.0 + RingThickness)
        let RingOffset = RingThickness * 2.0
        let Container = CGRect(x: Center.x - Radius,
                               y: Center.y - Radius,
                               width: Radius * 2 - RingOffset,
                               height: Radius * 2 - RingOffset)
        
        Context?.setFillColor(RingFillColor.cgColor)
        Context?.setStrokeColor(RingColor.cgColor)
        Context?.setLineWidth(RingThickness)
        Context?.fillEllipse(in: Container)
        Context?.addEllipse(in: Container)
        Context?.strokePath()
        
        Context?.move(to: CGPoint(x: Center.x - RingThickness, y: Center.y))
        let FinalMinutePoint = CGPoint(x: Center.x + MinutePoint.x,
                                       y: Center.y + MinutePoint.y)
        Context?.addLine(to: FinalMinutePoint)
        Context?.setStrokeColor(MinuteColor.cgColor)
        Context?.setLineWidth(MinuteThickness * 2)
        Context?.strokePath()
        
        Context?.move(to: CGPoint(x: Center.x - RingThickness, y: Center.y))
        let FinalHourPoint = CGPoint(x: Center.x + HourPoint.x,
                                     y: Center.y + HourPoint.y)
        Context?.addLine(to: FinalHourPoint)
        Context?.setStrokeColor(HourColor.cgColor)
        Context?.setLineWidth(HourThickness * 2)
        Context?.strokePath()
    }
}
