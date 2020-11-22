//
//  MapSceneProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/22/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

protocol MapSceneProtocol: class
{
    func Hide(_ Duration: Double)
    func Show(_ Duration: Double)
    func LockView()
    func UnlockView()
    func ResetCamera()
    func SetMapTime(_ Percent: Double)
}
