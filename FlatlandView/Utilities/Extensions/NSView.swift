//
//  NSView.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/29/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension NSView
{
    //https://www.hackingwithswift.com/example-code/uikit/how-to-find-the-view-controller-responsible-for-a-view
    //Converted from iOS to macOS
    func ViewController() -> NSViewController?
    {
        if let NextRepsonder = self.nextResponder as? NSViewController
        {
            return NextRepsonder
        }
        else
        {
            if let NextResponder = self.nextResponder as? NSView
            {
                return NextResponder.ViewController()
            }
            else
            {
                return nil
            }
        }
    }
}
