//
//  +ConfirmationProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension MainSettings: ConfirmProtocol
{
    func GetConfirmationMessage(ID: UUID) -> String
    {
        return ConfirmMessage
    }
    
    func GetButtonTitle(_ ForButton: ConfirmationButtons, ID: UUID) -> String?
    {
        switch ForButton
        {
            case .LeftButton:
                return "OK"
            
            case .RightButton:
                return "No"
        }
    }
    
    func GetInstanceID() -> UUID
    {
        return UUID()
    }
    
    func HandleButtonPressed(PressedButton: ConfirmationButtons, ID: UUID)
    {
    }
}
