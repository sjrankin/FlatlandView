//
//  ConfirmProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/2/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

protocol ConfirmProtocol: class
{
    func GetConfirmationMessage(ID: UUID) -> String
    func GetButtonTitle(_ ForButton: ConfirmationButtons, ID: UUID) -> String?
    func GetInstanceID() -> UUID
    func HandleButtonPressed(PressedButton: ConfirmationButtons, ID: UUID)
}

enum ConfirmationButtons: String, CaseIterable
{
    case LeftButton = "Left Button"
    case RightButton = "Right Button"
}
