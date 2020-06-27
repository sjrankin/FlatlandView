//
//  MainProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

protocol MainProtocol: class
{
    /// Called when the main window should be refreshed.
    func Refresh(_ From: String)
    /// Called when a window is closed.
    func DidClose(_ WhatClosed: String)
}
