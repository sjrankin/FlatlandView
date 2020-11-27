//
//  ErrorReporter.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ErrorReporter: NSViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        TextLabel.stringValue = ""
    }
    
    func SetText(_ Text: String)
    {
        TextLabel.stringValue = Text
    }
    
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent!.endSheet(Window!, returnCode: .OK)
    }
    
    @IBOutlet weak var TextLabel: NSTextField!
}
