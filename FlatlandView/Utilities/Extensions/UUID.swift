//
//  UUID.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/19/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension UUID
{
    /// Returns an empty UUID.
    /// - Note: "Empty" means a UUID with all `0` values.
    public static var Empty: UUID
    {
        get
        {
            return UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        }
    }
}
