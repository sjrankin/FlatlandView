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
        CurrentMessageID = UUID.Empty
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
        CurrentMessageID = UUID.Empty
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
    /// - Parameter ID: The ID of the message.
    func ShowStatusText(_ Text: String, ID: UUID = UUID())
    {
        if Text.isEmpty
        {
            CurrentMessageID = UUID.Empty
            RemoveTextTimer?.invalidate()
            RemoveTextTimer = nil
            StatusTextField.stringValue = ""
            ShowPushedText(Pushed: PushedMessage)
            return
        }
        SuspendPushMessage()
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
    
    func ShowPushedText(Pushed: QueuedMessage?)
    {
        if let Message = Pushed
        {
                Message.PushStartTime = CACurrentMediaTime()
                Message.PushTimer = Timer.scheduledTimer(timeInterval: Message.ExpiresIn,
                                                         target: self,
                                                         selector: #selector(RemovePushedMessage),
                                                         userInfo: nil, repeats: false)
            CurrentMessageID = Message.ID
            RemoveTextTimer?.invalidate()
            RemoveTextTimer = nil
            StatusTextContainer.isHidden = false
            StatusTextContainer.alphaValue = 1.0
            StatusTextField.isHidden = false
            StatusTextField.stringValue = Message.Message
            ResetInsignificance()
        }
    }
    
    func SuspendPushMessage()
    {
        if let Message = PushedMessage
        {
            Message.PushTimer?.invalidate()
            Message.PushTimer = nil
            Message.ShownFor = CACurrentMediaTime() - Message.PushStartTime + Message.ShownFor
        }
    }
    
    @objc func RemovePushedMessage()
    {
        OperationQueue.main.addOperation
        {
            if let Message = self.PushedMessage
            {
                Message.PushTimer?.invalidate()
                Message.PushTimer = nil
            }
            self.PushedMessage = nil
            self.HideAndClear()
        }
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
                self.CurrentMessageID = UUID.Empty
                self.InsignificanceTimer?.invalidate()
                self.InsignificanceTimer = nil
                self.StartInsignificance(Duration: 2.0)
                self.ShowPushedText(Pushed: self.PushedMessage)
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
    
    /// Push a message to the status bar. A "pushed" message will appear when no other messages are
    /// available but only for the specified duration.
    /// - Note: Only one pushed message may exist at a time. Calling this function will delete any existing
    ///         pushed messages.
    /// - Parameter Text: The text of the message.
    /// - Parameter Duration: The duration of the message (in seconds).
    /// - Parameter ID: The ID of the message
    func PushMessage(_ Text: String, Duration: Double, ID: UUID)
    {
        if let Current = PushedMessage
        {
            if CurrentMessageID == Current.ID
            {
                ShowStatusText("", ID: UUID.Empty)
            }
            Current.PushTimer?.invalidate()
            Current.PushTimer = nil
        }
        PushedMessage = QueuedMessage(Text, Expiry: Duration, ID: ID)
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
    
    /// Timer used for push messages.
    var PushTimer: Timer? = nil
    
    /// The time the pushed message first appeared.
    var PushStartTime: Double = 0
    
    /// Time the message has been visible.
    var ShownFor: Double = 0
}
