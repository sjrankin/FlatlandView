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
    
    /// Hide the current text and clear the message queue.
    func HideAndClear()
    {
        ClearMessageQueue()
        StatusTextField.stringValue = ""
        RemoveTextTimer?.invalidate()
        RemoveTextTimer = nil
    }
    
    /// Hide the status text. If there are more messages in the queue, they will be displayed in turn.
    func HideStatusText()
    {
        StatusTextField.stringValue = ""
        if RemoveTextTimer != nil
        {
            RemoveTextTimer?.invalidate()
            RemoveTextTimer = nil
        }
        RemoveTextLater()
    }
    
    /// If the current status message has the specified ID, it is removed and any messages in the message
    /// queue will be shown in order.
    /// - Parameter ForID: If the current message has the same value as this ID, it will be removed. Otherwise,
    ///                    no action is taken.
    /// - Parameter ClearQueue: If true, the message queue is cleared as long as the IDs match. Defaults to false.
    func HideStatusText(ForID: UUID, ClearQueue: Bool = false)
    {
        if CurrentMessageID == ForID
        {
            ClearMessageQueue()
            HideStatusText()
        }
    }
    
    /// Show text in the status bar. See also `ShowStatusText(Text, For)`.
    /// - Note: If the status bar is not visible, it is made visible. The insignificance timer is reset.
    /// - Parameter Text: The text to display.
    func ShowStatusText(_ Text: String, ID: UUID = UUID())
    {
        CurrentMessageID = ID
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
        ShowStatusText(Text, ID: ID)
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
                self.ShowStatusText(NextMessage.Message, For: NextMessage.ExpiresIn, ID: NextMessage.ID)
            }
            else
            {
                //No messages left - make the status bar insignificant.
                self.InsignificanceTimer?.invalidate()
                self.InsignificanceTimer = nil
                self.StartInsignificance(Duration: 2.0)
            }
        }
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
    
    /// Inserts a message into the status bar in place of the current message and ahead of the messages in
    /// the message queue. Queued messages are shown in order once this message expires.
    /// - Parameter Text: The message to display.
    /// - Parameter ExpiresIn: How long to show the message.
    /// - Parameter ID: The ID of the message.
    func InsertMessageAheadOfQueue(_ Text: String, ExpiresIn: Double, ID: UUID)
    {
        ShowStatusText(Text, For: ExpiresIn, ID: ID)
    }
    
    /// Remove the message in the message queue whose ID is passed to this function.
    /// - Parameter With: The ID of the message to delete.
    func RemoveQueuedMessage(With ID: UUID)
    {
        StatusMessageQueue.Remove(Where: {Element in Element.ID == ID})
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
