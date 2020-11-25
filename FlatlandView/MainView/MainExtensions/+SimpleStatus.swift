//
//  +SimpleStatus.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/25/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainController
{
    // MARK: - Simple status handling.
    
    /// Initialize the simple status bar.
    func InitializeSimpleStatus()
    {
        StatusTextField.wantsLayer = true
        StatusTextField.layer?.zPosition = CGFloat(StatusBarConstants.TextZ.rawValue)
        StatusTextField.stringValue = ""
        StatusTextContainer.wantsLayer = true
        StatusTextContainer.layer?.zPosition = CGFloat(StatusBarConstants.ContainerZ.rawValue)
        StatusTextContainer.layer?.cornerRadius = CGFloat(StatusBarConstants.CornerRadius.rawValue)
        StatusTextContainer.layer?.borderColor = NSColor.Jet.cgColor
        StatusTextContainer.layer?.borderWidth = CGFloat(StatusBarConstants.BorderWidth.rawValue)
        StatusTextContainer.layer?.backgroundColor = NSColor.SpaceCadet.cgColor
        if Settings.GetBool(.ShowStatistics)
        {
            StatusTextContainerLeftConstraint.constant = CGFloat(StatusBarConstants.DebugMargin.rawValue)
            StatusTextContainerRightConstraint.constant = CGFloat(StatusBarConstants.DebugMargin.rawValue)
        }
        else
        {
            StatusTextContainerLeftConstraint.constant = CGFloat(StatusBarConstants.StandardMargin.rawValue)
            StatusTextContainerRightConstraint.constant = CGFloat(StatusBarConstants.StandardMargin.rawValue)
        }
        StartInsignificance(Duration: StatusBarConstants.Insignificance.rawValue)
    }
    
    /// Shows the simple status bar.
    /// - Note: Starts the insignificance timer as well.
    func ShowSimpleStatus()
    {
        StatusTextContainer.isHidden = false
        StartInsignificance(Duration: StatusBarConstants.Insignificance.rawValue)
    }
    
    /// Hide the simple status bar.
    /// - Note: The insignificance timer is canceled. It will be turned back on when `ShowSimpleStatus`
    ///         is called.
    func HideSimpleStatus()
    {
        StatusTextContainer.isHidden = true
        CancelInsignificanceFade()
    }
    
    /// Show text in the status bar. See also `ShowStatusText(Text, For)`.
    /// - Note: If the status bar is not visible, it is made visible. The insignificance timer is reset.
    /// - Parameter Text: The text to display.
    func ShowStatusText(_ Text: String)
    {
        RemoveTextTimer?.invalidate()
        RemoveTextTimer = nil
        StatusTextContainer.isHidden = false
        StatusTextContainer.alphaValue = 1.0
        StatusTextField.isHidden = false
        StatusTextField.stringValue = Text
        ResetInsignificance()
    }
    
    /// Show text in the status bar. See also `ShowStatusText(Text)`. The text shown will be removed after
    /// a caller-specified amount of time.
    /// - Notes:
    ///    - Shows text in the status bar using the polymorphic `ShowStatusText`, which in turn resets the
    ///      insignificance timer.
    ///    - If this function is called prior to the previous text's duration expiration, the previous text
    ///      will be replaced with the new text and the remove text timer will be started with the duration
    ///      specified in the second call.
    /// - Parameter Text: The text to display.
    /// - Parameter For: Number of seconds to display the text.
    /// - Parameter ID: The ID of the message.
    func ShowStatusText(_ Text: String, For Duration: Double, ID: UUID = UUID())
    {
        ShowStatusText(Text)
        CurrentMessageID = ID
        RemoveTextTimer = Timer.scheduledTimer(timeInterval: Duration,
                                               target: self,
                                               selector: #selector(RemoveTextLater),
                                               userInfo: nil,
                                               repeats: false)
    }
    
    /// Function that actually removes text after an amount of time has elapsed. Removal consists of setting
    /// the text field to empty.
    @objc func RemoveTextLater()
    {
        OperationQueue.main.addOperation
        {
            self.StatusTextField.stringValue = ""
            if let NextMessage = self.StatusMessageQueue.Dequeue()
            {
                self.ShowStatusText(NextMessage.Message, For: NextMessage.ExpiresIn)
            }
        }
    }
    
    /// Hide (remove) status text. This function also deletes the remove text timer.
    func HideStatusText()
    {
        RemoveTextTimer?.invalidate()
        RemoveTextTimer = nil
        StatusTextField.stringValue = ""
    }
    
    /// Reset the insignificance timer. Should be called everytime the text of the status bar is changed.
    func ResetInsignificance()
    {
        InsignificanceTimer?.invalidate()
        InsignificanceTimer = nil
        StartInsignificance(Duration: LastInsignificanceDuration)
    }
    
    /// Cancel the insignificance timer. Should be called when the status bar is hidden.
    func CancelInsignificanceFade()
    {
        InsignificanceTimer?.invalidate()
        InsignificanceTimer = nil
    }
    
    /// Start the insignificance timer. After a certain amount of time, the status bar will have its alpha
    /// value changed to lessen its significance.
    /// - Parameter Duration: The duration of the time before the status bar becomes insignificant.
    func StartInsignificance(Duration: Double)
    {
        LastInsignificanceDuration = Duration
        InsignificanceTimer = Timer.scheduledTimer(timeInterval: Duration,
                                                   target: self,
                                                   selector: #selector(DoChangeAlpha),
                                                   userInfo: nil,
                                                   repeats: false)
    }
    
    /// Updates the alpha value of the status bar to make it look less significant.
    @objc func DoChangeAlpha()
    {
        StatusTextContainer.alphaValue = CGFloat(StatusBarConstants.AlphaInsignificance.rawValue)
        InsignificanceTimer?.invalidate()
        InsignificanceTimer = nil
    }
    
    /// Add a message to the message queue.
    /// - Note: The message is displayed according to the following rules:
    ///   - **1**: If the timer is running, enqueue the message to be displayed in turn.
    ///   - **2**: Display the message.
    /// - Parameter Text: The message to enqueue.
    /// - Parameter ExpiresIn: How long to show the message.
    /// - Parameter ID: The ID of the message.
    func AddQueuedMessage(_ Text: String, ExpiresIn: Double, ID: UUID)
    {
        objc_sync_enter(StatusBarLock)
        defer{objc_sync_exit(StatusBarLock)}
        if InsignificanceTimer != nil
        {
            let QItem = QueuedMessage(Text, Expiry: ExpiresIn, ID: ID)
            StatusMessageQueue.Enqueue(QItem)
        }
        else
        {
            ShowStatusText(Text, For: ExpiresIn, ID: ID)
        }
    }
    
    /// Clear the message queue.
    func ClearMessageQueue()
    {
        StatusMessageQueue.Clear()
    }
}

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
}
