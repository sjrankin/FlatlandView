//
//  +WorldClock.swift
//  Flatland
//
//  Created by Stuart Rankin on 12/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension MainController
{
    /// Initialize the world clock.
    func InitializeWorldClock()
    {
        WorldClockStartTime = Date()
        CurrentWorldTime = 0.0//CACurrentMediaTime()
        Debug.Print("Starting World Time: \(CurrentWorldTime)")
        WorldClockTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                               target: self,
                                               selector: #selector(HandleWorldClockTick),
                                               userInfo: nil,
                                               repeats: true)
        WorldClockTimer?.tolerance = 0.01
        //RunLoop.current.add(WorldClockTimer!, forMode: .common)
        //RunLoop.current.run()
        HandleWorldClockTick()
    }
    
    /// Update the world clock.
    @objc func HandleWorldClockTick()
    {
        let Adder = 1.0 * WorldClockTimeMultiplier
        CurrentWorldTime = CurrentWorldTime + Adder
        let NewTime = Date(timeInterval: CurrentWorldTime, since: WorldClockStartTime!)
        Rect2DView.NewWorldClockTime(WorldDate: NewTime)
        Main2DView.NewWorldClockTime(WorldDate: NewTime)
        Main3DView.NewWorldClockTime(WorldDate: NewTime)
        OperationQueue.main.addOperation
        {
            let DateSeconds = Date().timeIntervalSince(self.WorldClockStartTime!)
            self.WorldClockTickCount.stringValue = "\(DateSeconds)"
//            self.WorldClockTickCount.stringValue = "\(Int(self.CurrentWorldTime))"
        }
    }
}
