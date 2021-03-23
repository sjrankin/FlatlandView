//
//  QueuedMessage.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/23/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Holds one enqueued message.
class QueuedMessage
{
    /// Initializer.
    /// - Parameter Message: The message to display.
    /// - Parameter Expiry: How long to display the message in seconds.
    /// - Parameter ID: The ID of the message.
    init(_ Message: String, Expiry: Double, ID: UUID)
    {
        self.Message = Message
        ExpiresIn = Expiry
        self.ID = ID
    }
    
    /// The message to display.
    var Message: String = ""
    
    /// How long to display the text.
    var ExpiresIn: Double = 60.0
    
    /// ID of the message.
    var ID: UUID = UUID()
    
    /// Timer used for push messages.
    var PushTimer: Timer? = nil
    
    /// The time the pushed message first appeared.
    var PushStartTime: Double = 0
    
    /// Time the message has been visible.
    var ShownFor: Double = 0
}

