//
//  StarField3DCode.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/28/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class StarField3DCode: NSViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        switch Settings.GetEnum(ForKey: .StarSpeeds, EnumType: StarSpeeds.self, Default: .Medium)
        {
            case .Off:
                SampleStars.Hide()
                StarSpeedSegment.selectedSegment = 0
                
            case .Slow:
                SampleStars.Show()
                StarSpeedSegment.selectedSegment = 1
                
            case .Medium:
                SampleStars.Show()
                StarSpeedSegment.selectedSegment = 2
                
            case .Fast:
                SampleStars.Show()
                StarSpeedSegment.selectedSegment = 3
        }
    }
    
    @IBAction func HandleStarSpeedChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            switch Segment.selectedSegment
            {
                case 0:
                    SampleStars.Hide()
                    Settings.SetEnum(.Off, EnumType: StarSpeeds.self, ForKey: .StarSpeeds)
                    
                case 1:
                    SampleStars.Show()
                    Settings.SetEnum(.Slow, EnumType: StarSpeeds.self, ForKey: .StarSpeeds)
                    
                case 2:
                    SampleStars.Show()
                    Settings.SetEnum(.Medium, EnumType: StarSpeeds.self, ForKey: .StarSpeeds)
                    
                case 3:
                    SampleStars.Show()
                    Settings.SetEnum(.Fast, EnumType: StarSpeeds.self, ForKey: .StarSpeeds)
                    
                default:
                    return
            }
            var NewSpeed = 1.0
            switch Settings.GetEnum(ForKey: .StarSpeeds, EnumType: StarSpeeds.self, Default: .Medium)
            {
                case .Off:
                    return
                    
                case .Slow:
                    NewSpeed = 1.0
                    
                case .Medium:
                    NewSpeed = 3.0
                    
                case .Fast:
                    NewSpeed = 7.0
            }
            SampleStars.Show(SpeedMultiplier: NewSpeed)
        }
    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent?.endSheet(Window!, returnCode: .OK)
    }
    
    @IBOutlet weak var SampleStars: Starfield!
    @IBOutlet weak var StarSpeedSegment: NSSegmentedControl!
}
