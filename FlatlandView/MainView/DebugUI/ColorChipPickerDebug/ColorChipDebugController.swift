//
//  ColorChipDebugController.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/25/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ColorChipDebugController: NSViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ColorChipTest.Color = TestColor
        ColorChipTest.IsStatic = false
    }
    
    var TestColor = NSColor.Sunglow
    
    @IBAction func HandleCloseButton(_ sender: Any)
    {
        self.view.window?.close()
    }
    
    @IBAction func HandleAlphaLevelChanged(_ sender: Any)
    {
        var Red: CGFloat = 0.0
        var Green: CGFloat = 0.0
        var Blue: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        TestColor.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
        let Index = AlphaSegment.selectedSegment
        Alpha = 0.25 * CGFloat(Index + 1)
        let NewColor = NSColor(red: Red, green: Green, blue: Blue, alpha: Alpha)
        ColorChipTest.Color = NewColor
        ColorChipTest.CallerTitle = "Test of color chips/color picker functionality" 
    }
    
    @IBOutlet weak var AlphaSegment: NSSegmentedControl!
    @IBOutlet weak var ColorChipTest: ColorChip!
}
