//
//  +WorldClock.swift
//  Flatland
//
//  Created by Stuart Rankin on 12/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainController
{
    func InitializeWorldClock()
    {
        WorldClockStartTime = Date()
        CurrentWorldTime = CACurrentMediaTime()
        Debug.Print("Starting World Time: \(CurrentWorldTime)")
        WorldClockTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                               target: self,
                                               selector: #selector(HandleWorldClockTick),
                                               userInfo: nil,
                                               repeats: true)
        HandleWorldClockTick()
    }
    
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
            self.WorldClockTickCount.stringValue = "\(Int(self.CurrentWorldTime))"
        }
    }
}
