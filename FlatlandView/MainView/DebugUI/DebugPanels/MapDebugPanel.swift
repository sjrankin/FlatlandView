//
//  MapDebugPanel.swift
//  Flatland
//
//  Created by Stuart Rankin on 12/5/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class MapDebugPanel: PanelController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        KnownLocationSwitch.state = Settings.GetBool(.ShowKnownLocations) ? .on : .off
    }
    
    @IBAction func HandleKnownLocationSwitchChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.ShowKnownLocations, Switch.state == .on)
        }
    }
    
    @IBOutlet weak var KnownLocationSwitch: NSSwitch!
}
