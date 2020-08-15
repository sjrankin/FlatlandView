//
//  FlatlandNotification.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class FlatlandNotification
{
    var Text: String = ""
}

enum NotificationTypes: String, CaseIterable
{
    case Earthquakes = "Earthquakes"
    case Debug = "Debug"
}
