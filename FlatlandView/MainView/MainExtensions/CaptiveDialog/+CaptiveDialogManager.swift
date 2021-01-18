//
//  +CaptiveDialogManager.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/18/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainController: CaptiveDialogManagementProtocol
{
    func ShowCaptiveDialog(_ CaptiveType: CaptiveDialogTypes)
    {
        LoadCaptiveDialog(CaptiveType)
        ShowingCaptiveDialog = true
        CaptiveDialogPanel.wantsLayer = true
        CaptiveDialogPanel.isHidden = false
        ContentTop.constant = CGFloat(CaptiveDialogConstants.VisibleMargin.rawValue)
    }
    
    func HideCaptiveDialog(FromCaptiveDialog: Bool = false)
    {
        CurrentCaptiveDialog?.WillClose(FromCaptive: FromCaptiveDialog)
        ShowingCaptiveDialog = false
        CaptiveDialogPanel.layer?.zPosition = CGFloat(-LayerZLevels.CaptiveDialogLayer.rawValue)
        CaptiveDialogPanel.isHidden = true
        ContentTop.constant = CGFloat(CaptiveDialogConstants.InvisibleMargin.rawValue)
        CurrentCaptiveDialog = nil
    }
    
    func CloseCaptiveDialog()
    {
        HideCaptiveDialog(FromCaptiveDialog: true)
    }
    
    func LoadCaptiveDialog(_ CaptiveType: CaptiveDialogTypes)
    {
        switch CaptiveType
        {
            case .RegionCreation:
                if let Controller = NSStoryboard(name: "CaptiveDialogs", bundle: nil).instantiateController(withIdentifier: "CaptiveUserRegionDialog") as? NSViewController
                {
                    guard let AController = Controller as? CaptiveDialogPanelProtocol else
                    {
                        Debug.FatalError("Error casting captive dialog to CaptiveDialogPanelProtocol")
                    }
                    AController.ParentDelegate = self
                    AController.MainDelegate = self
                    for SomeView in CaptiveDialogContainer.subviews
                    {
                        SomeView.removeFromSuperview()
                    }
                    Controller.view.frame = CaptiveDialogContainer.bounds
                    CaptiveDialogContainer.addSubview(Controller.view)
                    CurrentCaptiveDialog = AController
                    if CaptiveDialogList[CaptiveType] == nil
                    {
                        CaptiveDialogList[CaptiveType] = AController
                    }
                }
        }
    }
}

enum CaptiveDialogTypes: String, CaseIterable
{
    case RegionCreation = "RegionCreation"
}
