//
//  +MainEventHandling.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainController
{
    // MARK: - User interface messages and events
    
    override var acceptsFirstResponder: Bool
    {
        return true
    }
    
    override func scrollWheel(with event: NSEvent)
    {
        #if false
        if Settings.GetBool(.UseSystemCameraControl)
        {
            return
        }
        let WithOption = event.modifierFlags.contains(.option)
        let DeltaX = Int(event.deltaX)
        let DeltaY = Int(event.deltaY)
        if DeltaX == 0 && DeltaY == 0
        {
            return
        }
        Main3DView.HandleMouseScrollWheelChanged(DeltaX: DeltaX, DeltaY: DeltaY, Option: WithOption)
        #endif
    }
    
    override func mouseDragged(with event: NSEvent)
    {
        #if false
        if Settings.GetBool(.UseSystemCameraControl)
        {
            return
        }
        let DeltaX = Int(event.deltaX)
        let DeltaY = Int(event.deltaY)
        if DeltaX == 0 && DeltaY == 0
        {
            return
        }
        Main3DView.HandleMouseDragged(DeltaX: DeltaX, DeltaY: DeltaY)
        #endif
    }
    
    @objc func HandleDoubleClick()
    {
        #if false
        if Settings.GetBool(.UseSystemCameraControl)
        {
            return
        }
        Main3DView.ResetFlatlandCamera()
        #else
        Main3DView.ResetCamera()
        #endif
    }
}
