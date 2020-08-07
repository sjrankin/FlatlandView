//
//  ResetConfirmController.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/5/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ResetConfirmController: NSViewController
{
    @IBAction func HandleYesPressed(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent?.endSheet(Window!, returnCode: .OK)
    }
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent?.endSheet(Window!, returnCode: .cancel)
    }
}
