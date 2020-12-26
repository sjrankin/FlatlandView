//
//  HomeLocationController.swift
//  Flatland
//
//  Created by Stuart Rankin on 12/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class HomeLocationController: NSViewController, NSTextFieldDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        NameBox.wantsLayer = true
        NameBox.layer?.backgroundColor = NSColor(HexString: "#d0d0d0")!.cgColor
        NameBox.stringValue = Settings.GetSecureString(.UserHomeName) ?? ""
        LatitudeBox.stringValue = ""
        if let RawLat = Settings.GetSecureString(.UserHomeLatitude)
        {
            if let ActualLat = Double(RawLat)
            {
                let PrettyLat = Utility.PrettyLatitude(ActualLat)
                LatitudeBox.stringValue = PrettyLat
            }
        }
        LongitudeBox.stringValue = ""
        if let RawLon = Settings.GetSecureString(.UserHomeLongitude)
        {
            if let ActualLon = Double(RawLon)
            {
                let PrettyLon = Utility.PrettyLongitude(ActualLon)
                LongitudeBox.stringValue = PrettyLon
            }
        }
        LongitudeErrorButton.isHidden = true
        LatitudeErrorButton.isHidden = true
    }
    
    func controlTextDidEndEditing(_ obj: Notification)
    {
        guard let TextField = obj.object as? NSTextField else
        {
            return
        }
        let TextValue = TextField.stringValue
        switch TextField
        {
            case LatitudeBox:
                let Result = InputValidation.LatitudeValidation(TextValue)
                switch Result
                {
                    case .success(let Value):
                        LatitudeErrorButton.isHidden = true
                        
                    case .failure(let ErrorResult):
                        LatitudeBox.stringValue = ""
                        LatitudeErrorButton.isHidden = false
                        ValidationErrorMessage = "Latitude validation error: \(ErrorResult.rawValue)"
                }
                
            case LongitudeBox:
                let Result = InputValidation.LongitudeValidation(TextValue)
                switch Result
                {
                    case .success(let Value):
                        LongitudeErrorButton.isHidden = true
                        
                    case .failure(let ErrorResult):
                        LongitudeBox.stringValue = ""
                        LongitudeErrorButton.isHidden = false
                        ValidationErrorMessage = "Longitude validation error: \(ErrorResult.rawValue)"
                }
                
            default:
                return
        }
    }
    
    @IBAction func HandleOKButton(_ sender: Any)
    {
        Settings.SetSecureString(.UserHomeName, NameBox.stringValue)
        let FinalLatitude = InputValidation.LatitudeValidation(LatitudeBox.stringValue)
        var ActualLatitude: Double = 0.0
        switch FinalLatitude
        {
            case .success(let Value):
                ActualLatitude = Value
                
            case .failure(let Reason):
                return
        }
        Settings.SetSecureString(.UserHomeLatitude, "\(ActualLatitude)")
        let FinalLongitude = InputValidation.LongitudeValidation(LongitudeBox.stringValue)
        var ActualLongitude: Double = 0.0
        switch FinalLongitude
        {
            case .success(let Value):
                ActualLongitude = Value
                
            case .failure(let Reason):
                return
        }
        Settings.SetSecureString(.UserHomeLongitude, "\(ActualLongitude)")
        
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent!.endSheet(Window!, returnCode: .cancel)
    }
    
    var ValidationErrorMessage = ""
    
    @IBAction func HandleCancelButton(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent!.endSheet(Window!, returnCode: .cancel)
    }
    
    var Pop: NSPopover? = nil
    
    @IBAction func HandleHomeHelp(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            if let PopController = NSStoryboard(name: "PreferenceHelpViewer", bundle: nil).instantiateController(withIdentifier: "PreferenceHelpViewer") as? PreferenceHelpPopover
            {
                Pop = NSPopover()
                Pop?.contentSize = NSSize(width: 427, height: 237)
                Pop?.behavior = .semitransient
                Pop?.animates = true
                Pop?.contentViewController = PopController
                var Message = ""
                switch Button
                {
                    case LatitudeErrorButton, LongitudeErrorButton:
                        Message = ValidationErrorMessage
                        
                    case HomeLongitudeHelpButton:
                        Message = """
Enter the longitude of your home location here. You can use negative values for the western hemisphere or add |font type=bold|W|font type=system| to the end of your value for the same effect. (You can also use |font type=bold|E|font type=system| for the eastern hemisphere, but that is not necessary.)
This value is stored in your system's keychain and is not visible to anyone else.
"""
                        
                    case HomeLatitudeHelpButton:
                        Message = """
Enter the latitude of your home location here. You can use negative values for southern latitudes, or add |font type=bold|S|font type=system| to the end of your value for the southern hemisphere. (You can also use |font type=bold|N|font type=system| for north, but that is not necessary.)
This value is stored in your system's keychain and is not visible to anyone else.
"""
                        
                    case HomeNameHelpButton:
                        Message = """
Enter the name of your home location here. This value is stored in your system's keychain and is not visible to anyone else.
"""
                    default:
                        return
                }
                PopController.SetHelpText(Message)
                Pop?.show(relativeTo: Button.bounds, of: Button, preferredEdge: .maxX)
            }
        }
    }
    
    @IBOutlet weak var LongitudeBox: NSTextField!
    @IBOutlet weak var LatitudeBox: NSTextField!
    @IBOutlet weak var NameBox: NSTextField!
    @IBOutlet weak var HomeLongitudeHelpButton: NSButton!
    @IBOutlet weak var HomeLatitudeHelpButton: NSButton!
    @IBOutlet weak var HomeNameHelpButton: NSButton!
    @IBOutlet weak var LatitudeErrorButton: NSButton!
    @IBOutlet weak var LongitudeErrorButton: NSButton!
}