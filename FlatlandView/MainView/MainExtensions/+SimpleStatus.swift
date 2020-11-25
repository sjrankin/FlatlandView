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
    func InitializeSimpleStatus()
    {
        StatusTextField.wantsLayer = true
        StatusTextField.layer?.zPosition = 5000000
        StatusTextField.stringValue = ""
        StatusTextContainer.wantsLayer = true
        StatusTextContainer.layer?.zPosition = 1000000
        StatusTextContainer.layer?.cornerRadius = 5.0
        StatusTextContainer.layer?.borderColor = NSColor.Jet.cgColor
        StatusTextContainer.layer?.borderWidth = 2.0
        StatusTextContainer.layer?.backgroundColor = NSColor.SpaceCadet.cgColor
        if Settings.GetBool(.ShowStatistics)
        {
            StatusTextContainerLeftConstraint.constant = 180
            StatusTextContainerRightConstraint.constant = 180
        }
        else
        {
            StatusTextContainerLeftConstraint.constant = 80
            StatusTextContainerRightConstraint.constant = 80
        }
        StartInsignificance(Duration: 60.0)
    }
    
    func ShowSimpleStatus()
    {
        //        StatusTextContainer.alphaValue = 1.0
        StatusTextContainer.isHidden = false
        StartInsignificance(Duration: 60.0)
    }
    
    func HideSimpleStatus()
    {
        StatusTextContainer.isHidden = true
        //        StatusTextContainer.alphaValue = 0.0
        CancelInsignificanceFade()
    }
    
    func ShowStatusText(_ Text: String)
    {
        RemoveTextTimer?.invalidate()
        RemoveTextTimer = nil
        StatusTextContainer.isHidden = false
        StatusTextField.isHidden = false
        //        StatusTextContainer.alphaValue = 1.0
        //        StatusTextField.alphaValue = 1.0
        StatusTextField.stringValue = Text
        ResetInsignificance()
    }
    
    func ShowStatusText(_ Text: String, For Duration: Double)
    {
        ShowStatusText(Text)
        RemoveTextTimer = Timer.scheduledTimer(timeInterval: Duration,
                                               target: self,
                                               selector: #selector(RemoveTextLater),
                                               userInfo: nil,
                                               repeats: false)
    }
    
    @objc func RemoveTextLater()
    {
        OperationQueue.main.addOperation
        {
            //            self.StatusTextField.alphaValue = 0.0
            self.StatusTextField.stringValue = ""
        }
    }
    
    func HideStatusText()
    {
        RemoveTextTimer?.invalidate()
        RemoveTextTimer = nil
        StatusTextField.stringValue = ""
        //        StatusTextField.alphaValue = 0.0
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
        StatusTextContainer.alphaValue = 0.6
    }
}
