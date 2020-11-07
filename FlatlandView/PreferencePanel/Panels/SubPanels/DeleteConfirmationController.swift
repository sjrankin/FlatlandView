//
//  DeleteConfirmationController.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/5/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class DeleteConfirmationController: NSViewController
{
    var Parent: NSWindow? = nil
    var Window: NSWindow? = nil
    
    override func viewDidLayout()
    {
        Window = self.view.window
        Parent = Window?.sheetParent
        let YesAttributes: [NSAttributedString.Key: Any] =
            [
                .foregroundColor: NSColor.Maroon
            ]
        YesButton.attributedTitle = NSMutableAttributedString(string: "Yes", attributes: YesAttributes)
        let NoAttributes: [NSAttributedString.Key: Any] =
        [
            .font: NSFont.boldSystemFont(ofSize: 13.0)
        ]
        NoButton.attributedTitle = NSMutableAttributedString(string: "No", attributes: NoAttributes)
    }
    
    func SetConfirmationText(_ Raw: String)
    {
        ConfirmationTextView.stringValue = Raw
    }
    
    @IBAction func HandleYesButton(_ sender: Any)
    {
        Parent?.endSheet(Window!, returnCode: .OK)
    }
    
    @IBAction func HandleNoButton(_ sender: Any)
    {
        Parent?.endSheet(Window!, returnCode: .cancel)
    }
    
    @IBOutlet weak var ConfirmationTextView: NSTextField!
    @IBOutlet weak var NoButton: NSButton!
    @IBOutlet weak var YesButton: NSButton!
}
