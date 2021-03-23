//
//  StatusBar2D.swift
//  Flatland
//
//  Created by Stuart Rankin on 3/22/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

/// Small 2D view that presents text status.
class StatusBar2D: NSView
{
    /// Initializer.
    /// - Parameter frame: The frame for the view.
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        CommonInitialization()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        CommonInitialization()
    }
    
    var CurrentMessageID: UUID = UUID()
    var RemoveTextTimer: Timer? = nil
    var InsignificanceTimer: Timer? = nil
    var LastInsignificanceDuration: Double = 60.0
    var StatusMessageQueue = Queue<QueuedMessage>()
    var StatusBarLock: NSObject = NSObject()
    var PushedMessage: QueuedMessage? = nil
    
    /// Initialize the view.
    func InitializeView()
    {
        postsFrameChangedNotifications = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(NewFrame),
                                               name: NSView.frameDidChangeNotification,
                                               object: nil)
        
        //Initialize the layer.
        self.wantsLayer = true
        self.layer?.zPosition = CGFloat(StatusBarConstants.ContainerZ.rawValue)
        self.layer?.borderWidth = CGFloat(StatusBarConstants.BorderWidth.rawValue)
        self.layer?.cornerRadius = CGFloat(StatusBarConstants.CornerRadius.rawValue)
        self.layer?.borderColor = NSColor(RGB: Colors3D.StatusBorder.rawValue).cgColor
        self.layer?.backgroundColor = NSColor.clear.cgColor
        
        self.isHidden = false
        self.wantsLayer = true
        BackingView = StatusTextLayer()
        BackingView.frame = NSRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        BackingView.backgroundColor = NSColor.black.cgColor
        self.layer?.addSublayer(BackingView)
    }
    
    /// The frame of the view changes during initialization and when the user resizes the main window. Update
    /// the backing layer when that happens.
    @objc func NewFrame(_ notification: Notification)
    {
        BackingView.frame = NSRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
    
    var BackingView: StatusTextLayer = StatusTextLayer()
    
    /// Initialization common to all initializers.
    func CommonInitialization()
    {
        InitializeView()
        CurrentMessageID = UUID.Empty
        StartInsignificance(Duration: StatusBarConstants.Insignificance.rawValue)
    }
    
    /// Set contraints for the left and right side. The actual constraints depend on whether statistics are
    /// showing or not.
    /// - Parameter Left: The left-side ("leading") constraint to set.
    /// - Parameter Right: The right-side ("trailing") constraint to set.
    func SetConstraints(Left: NSLayoutConstraint, Right: NSLayoutConstraint)
    {
        if Settings.GetBool(.ShowStatistics)
        {
            Left.constant = CGFloat(StatusBarConstants.DebugMargin.rawValue)
            Right.constant = CGFloat(StatusBarConstants.DebugMargin.rawValue)
        }
        else
        {
            Left.constant = CGFloat(StatusBarConstants.StandardMargin.rawValue)
            Right.constant = CGFloat(StatusBarConstants.StandardMargin.rawValue)
        }
    }
    
    /// Shows the simple status bar.
    /// - Note: Starts the insignificance timer as well.
    func ShowSimpleStatus()
    {
        if !IsVisible
        {
            return
        }
        self.isHidden = false
        StartInsignificance(Duration: StatusBarConstants.Insignificance.rawValue)
    }
    
    /// Hide the simple status bar.
    /// - Note: The insignificance timer is canceled. It will be turned back on when `ShowSimpleStatus`
    ///         is called.
    func HideSimpleStatus()
    {
        if !IsVisible
        {
            return
        }
        self.isHidden = true
        CancelInsignificanceFade()
    }
    
    /// Hide the current text and clear the message queue.
    func HideAndClear()
    {
        ClearMessageQueue()
        CurrentMessageID = UUID.Empty
        RemoveTextTimer?.invalidate()
        RemoveTextTimer = nil
    }
    
    /// Hide the status text. If there are more messages in the queue, they will be displayed in turn.
    func HideStatusText()
    {
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
            if ClearQueue
            {
                ClearMessageQueue()
            }
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
            ShowPushedText(Pushed: PushedMessage)
            return
        }
        SuspendPushMessage()
        CurrentMessageID = ID
        RemoveTextTimer?.invalidate()
        RemoveTextTimer = nil
        if IsVisible
        {
            self.isHidden = false
        }
        DrawText(Text)
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
    
    /// Handle window resize events.
    /// - Parameter NewSize: The new size of the window.
    public func ParentWindowSizeChanged(NewSize: NSSize)
    {
        //Handled by way of the notification system.
    }
    
    /// Create a text node with the passed text. The node is faded in and displayed.
    /// - Parameter Text: The text to display.
    private func MakeTextNode(_ Text: String)
    {
        let Font = NSFont.GetFont(InOrder: ["SFProText-Bold", "HelveticaNeue-Bold", "Avenir-Black", "ArialMT"],
                                  Size: 18.0)
        BackingView.font = Font
        BackingView.fontSize = 18.0
        BackingView.foregroundColor = NSColor.white.cgColor
        BackingView.string = "  \(Text)"
        BackingView.contentsScale = NSScreen.main!.backingScaleFactor
        self.toolTip = Text
    }
    
    /// Draw the text. Manages old text to new text transitions.
    /// - Parameter Text: The text to draw.
    private func DrawText(_ Text: String)
    {
        MakeTextNode(Text)
    }
    
    /// Push a message to the message queue.
    /// - Parameter Pushed: The message to display when it is at the top of the queue.
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
            if IsVisible
            {
                self.isHidden = false
            }
            DrawText(Message.Message)
            ResetInsignificance()
        }
    }
    
    /// Suspends the timer for a pushed message. Time-elapsed is stored in the message.
    func SuspendPushMessage()
    {
        if let Message = PushedMessage
        {
            Message.PushTimer?.invalidate()
            Message.PushTimer = nil
            Message.ShownFor = CACurrentMediaTime() - Message.PushStartTime + Message.ShownFor
        }
    }
    
    /// Called after a pushed message's time limit has expired. The message is removed from the status box.
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
        let Alpha = GetAppropriateAlpha(CGFloat(StatusBarConstants.AlphaInsignificance.rawValue))
        self.alphaValue = Alpha
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
    /// - Parameter ID: The ID of the message.
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
    
    /// Determines whether the status bar is visible or not.
    /// - Note: Regardless of the visibility, the status bar will still function - if not visible, it will
    ///         function invisibly.
    /// - Parameter Show: If true, the status bar is visible. If false, the status bar is invisible.
    func SetVisibility(_ Show: Bool)
    {
        _IsVisible = Show
        if Show
        {
            #if true
            self.isHidden = false
            #else
            let FadeIn = SCNAction.fadeIn(duration: 0.25)
            self.scene?.rootNode.runAction(FadeIn)
            {
                self.isHidden = false
                DispatchQueue.main.async
                {
                    self.alphaValue = 1.0
                }
            }
            #endif
        }
        else
        {
            #if true
            self.isHidden = true
            #else
            let FadeOut = SCNAction.fadeOut(duration: 1.0)
            self.scene?.rootNode.runAction(FadeOut)
            {
                self.isHidden = true
                DispatchQueue.main.async
                {
                    self.alphaValue = 0.0
                }
            }
            #endif
        }
    }
    
    /// Returns an alpha level appropriate to the state of overall visibility.
    /// - Parameter Potential: The alpha level to return (unless `IsVisible` is `false`).
    /// - Returns: A level to use for alpha. If `IsVisible` is true, `Potential` is returned. If `IsVisible`
    ///            is false, `0.0` is returned.
    private func GetAppropriateAlpha(_ Potential: CGFloat) -> CGFloat
    {
        return _IsVisible ? Potential : 0.0
    }
    
    private var _IsVisible: Bool = true
    var IsVisible: Bool
    {
        get
        {
            return _IsVisible
        }
    }
}

