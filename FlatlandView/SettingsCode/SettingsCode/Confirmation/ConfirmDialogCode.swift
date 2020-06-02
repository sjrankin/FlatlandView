//
//  ConfirmDialogCode.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/2/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ConfirmDialogCode: NSViewController
{
    public weak var ConfirmDelegate: ConfirmProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        CallerID = (ConfirmDelegate?.GetInstanceID())!
        if let LeftButtonText = ConfirmDelegate?.GetButtonTitle(.LeftButton, ID: CallerID)
        {
            LeftButton.title = LeftButtonText
        }
        else
        {
            LeftButton.removeFromSuperview()
        }
        if let RightButtonText = ConfirmDelegate?.GetButtonTitle(.RightButton, ID: CallerID)
        {
            RightButton.title = RightButtonText
        }
        else
        {
            RightButton.removeFromSuperview()
        }
        let Message = (ConfirmDelegate?.GetConfirmationMessage(ID: CallerID))!
        MessageLabel.stringValue = Message
    }
    
    @IBAction func HandlRightButtonPressed(_ sender: Any)
    {
        ConfirmDelegate?.HandleButtonPressed(PressedButton: .RightButton, ID: CallerID)
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent!.endSheet(Window!, returnCode: .OK)
    }
    
    @IBAction func HandleLeftButtonPressed(_ sender: Any)
    {
        ConfirmDelegate?.HandleButtonPressed(PressedButton: .LeftButton, ID: CallerID)
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent!.endSheet(Window!, returnCode: .OK)
    }
    
    var CallerID: UUID = UUID()
    
    @IBOutlet weak var RightButton: NSButton!
    @IBOutlet weak var LeftButton: NSButton!
    @IBOutlet weak var MessageLabel: NSTextField!
}
