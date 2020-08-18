//
//  NASAMapConfirmation.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/17/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class NASAMapConfirmation: NSViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction func HandleYesButton(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent!.endSheet(Window!, returnCode: .OK)
    }
    
    @IBAction func HandleNoButton(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent!.endSheet(Window!, returnCode: .cancel)
    }
}
