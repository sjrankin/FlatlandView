//
//  StatusBar3D.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/21/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

class StatusBar3D: SCNView
{
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        CommonInitialization()
    }
    
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
    var CurrentText: SCNNode2? = nil
    var CameraNode: SCNNode2 = SCNNode2()
    
    func InitializeView()
    {
        //Initialize the layer.
        self.wantsLayer = true
        self.layer?.zPosition = 1000000
        self.layer?.borderWidth = 4
        self.layer?.cornerRadius = 5
        #if DEBUG
        self.layer?.borderColor = NSColor.systemYellow.cgColor
        #else
        self.layer?.borderColor = NSColor.Jet.cgColor
        #endif
        self.layer?.backgroundColor = NSColor.clear.cgColor
        
        //Initialize the 3D view.
        let Scene = SCNScene()
        self.scene = Scene
        self.showsStatistics = false
        #if DEBUG
        self.scene?.background.contents = NSColor.systemBlue
        #else
        self.scene?.background.contents = NSColor.black
        #endif
        self.allowsCameraControl = false
        let Camera = SCNCamera()
        Camera.usesOrthographicProjection = true
        Camera.orthographicScale = 1.6
        CameraNode = SCNNode2()
        CameraNode.camera = Camera
        CameraNode.position = SCNVector3(0.0, 0.0, 25.0)
        self.scene?.rootNode.addChildNode(CameraNode)

        self.isHidden = false
        
        let BaseWidth = Settings.GetBool(.ShowStatistics) ? 640.0 : 800.0
        Ratio = self.frame.width / CGFloat(BaseWidth)
        print("Initial ratio=\(Ratio), BaseWidth=\(BaseWidth)")
    }
    
    func CommonInitialization()
    {
        InitializeView()
        CurrentMessageID = UUID.Empty
        StartInsignificance(Duration: StatusBarConstants.Insignificance.rawValue)
    }
    
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
    
    func ShowSimpleStatus()
    {
        self.isHidden = false
        StartInsignificance(Duration: StatusBarConstants.Insignificance.rawValue)
    }
    
    func HideSimpleStatus()
    {
        self.isHidden = true
        CancelInsignificanceFade()
    }
    
    func HideAndClear()
    {
        ClearMessageQueue()
        CurrentMessageID = UUID.Empty
        CurrentText = nil
        RemoveTextTimer?.invalidate()
        RemoveTextTimer = nil
    }
    
    func HideStatusText()
    {
        CurrentText?.removeFromParentNode()
        CurrentText = nil
        if RemoveTextTimer != nil
        {
            RemoveTextTimer?.invalidate()
            RemoveTextTimer = nil
        }
        RemoveTextLater()
    }
    
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
        self.isHidden = false
        DrawText(Text)
        ResetInsignificance()
    }
    
    func ShowStatusText(_ Text: String, For Duration: Double, ID: UUID = UUID())
    {
        ShowStatusText(Text, ID: ID)
        RemoveTextTimer = Timer.scheduledTimer(timeInterval: Duration,
                                               target: self,
                                               selector: #selector(RemoveTextLater),
                                               userInfo: nil,
                                               repeats: false)
    }
    
    func ParentWindowSizeChanged(NewSize: NSSize)
    {
        if Settings.GetBool(.ShowStatistics)
        {
            Ratio = 640.0 / NewSize.width
        }
        else
        {
            Ratio = 800.0 / NewSize.width
        }
        UpdateTextWithNewPosition()
    }
    
    private func UpdateTextWithNewPosition()
    {
        let X = (-33 * Ratio) + 0.5
        CurrentText?.position = SCNVector3(X, -1.2, 0.0)
    }
    
    var Ratio: CGFloat = 1.0
    
    private func DrawText(_ Text: String)
    {
        print("status width = \(self.frame.width)")
        CurrentText?.removeFromParentNode()
        let TextShape = SCNText(string: Text, extrusionDepth: 0.5)
        TextShape.font = NSFont.systemFont(ofSize: 20.0)
        CurrentText = SCNNode2()
        CurrentText?.geometry = TextShape
        CurrentText?.scale = SCNVector3(0.09)
        //CurrentText?.opacity = 0.0
        //let FadeIn = SCNAction.fadeIn(duration: 0.1)
        //CurrentText?.runAction(FadeIn)
        let X = (-33 * Ratio) + 0.5
        CurrentText?.position = SCNVector3(X, -1.15, 0.0)
        self.scene?.rootNode.addChildNode(CurrentText!)
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
            self.isHidden = false
            DrawText(Message.Message)
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
    
    @objc func RemoveTextLater()
    {
        OperationQueue.main.addOperation
        {
            self.CurrentText?.removeFromParentNode()
            self.CurrentText = nil
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
    
    func ResetInsignificance()
    {
        InsignificanceTimer?.invalidate()
        InsignificanceTimer = nil
        StartInsignificance(Duration: LastInsignificanceDuration)
    }
    
    func CancelInsignificanceFade()
    {
        InsignificanceTimer?.invalidate()
        InsignificanceTimer = nil
    }
    
    func StartInsignificance(Duration: Double)
    {
        LastInsignificanceDuration = Duration
        InsignificanceTimer = Timer.scheduledTimer(timeInterval: Duration,
                                                    target: self,
                                                    selector: #selector(DoChangeAlpha),
                                                    userInfo: nil,
                                                    repeats: false)
    }
    
    @objc func DoChangeAlpha()
    {
        self.alphaValue = CGFloat(StatusBarConstants.AlphaInsignificance.rawValue)
        InsignificanceTimer?.invalidate()
        InsignificanceTimer = nil
    }
    
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
    
    func InsertMessageAheadOfQueue(_ Text: String, ExpiresIn: Double, ID: UUID)
    {
        ShowStatusText(Text, For: ExpiresIn, ID: ID)
    }
    
    func RemoveQueuedMessage(With ID: UUID)
    {
        StatusMessageQueue.Remove(Where: {Element in Element.ID == ID})
    }
    
    func ClearMessageQueue()
    {
        StatusMessageQueue.Clear()
    }
    
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
