//
//  POIPreferences.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/3/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class POIPreferences: NSViewController, PreferencePanelProtocol
{
    weak var Parent: PreferencePanelControllerProtocol? = nil
    weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidLayout()
    {
        super.viewDidLayout()
        ShowBuiltInPOIsSwitch.state = Settings.GetBool(.ShowBuiltInPOIs) ? .on : .off
        let PreviousScale = Settings.GetEnum(ForKey: .POIScale, EnumType: MapNodeScales.self, Default: .Normal)
        switch PreviousScale
        {
            case .Small:
                POIScaleSegment.selectedSegment = 0
                
            case .Normal:
                POIScaleSegment.selectedSegment = 1
                
            case .Large:
                POIScaleSegment.selectedSegment = 2
        }
        ShowHomeSwitch.state = Settings.GetState(.ShowHomeLocation)
        ShowUserPOISwitch.state = Settings.GetState(.ShowUserPOIs)
        ShowUnescoSwitch.state = Settings.GetState(.ShowWorldHeritageSites)
        let UnescoType = Settings.GetEnum(ForKey: .WorldHeritageSiteType, EnumType: WorldHeritageSiteTypes.self, Default: .Natural)
        switch UnescoType
        {
            case .AllSites:
                UnescoSitesSegment.selectedSegment = 3
                
            case .Cultural:
                UnescoSitesSegment.selectedSegment = 0
                
            case .Mixed:
                UnescoSitesSegment.selectedSegment = 2
                
            case .Natural:
                UnescoSitesSegment.selectedSegment = 1
        }

        HelpButtons.append(EditUserPOIHelpButton)
        HelpButtons.append(ShowUserPOIHelpButton)
        HelpButtons.append(EditHomeLocationHelpButton)
        HelpButtons.append(ShowHomeHelpButton)
        HelpButtons.append(POIScaleHelpButton)
        HelpButtons.append(ShowBuiltInPOIs)
        HelpButtons.append(ShowListofBuiltInPOIs)
        HelpButtons.append(UNESCOHelpButton)
        HelpButtons.append(ShowWorldHeritageSiteHelpButton)
        HelpButtons.append(ResetPaneHelp)
        
        SetHelpVisibility(To: Settings.GetBool(.ShowUIHelp))
    }
    
    @IBAction func HandleShowAllBuiltInPOIsButton(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "UserPOIEditor", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "BuiltInPOIWindow") as?
            BuiltInPOIWindow
        {
            let Window = WindowController.window
            self.view.window?.beginSheet(Window!)
            {
                Result in
            }
        }
    }
    
    @IBAction func HandleHelpButton(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            switch Button
            {
                case ShowHomeHelpButton:
                    Parent?.ShowHelp(For: .ShowHome, Where: Button.bounds, What: ShowHomeHelpButton)
                    
                case EditHomeLocationHelpButton:
                    Parent?.ShowHelp(For: .EditHome, Where: Button.bounds, What: EditHomeLocationHelpButton)
                    
                case ShowUserPOIHelpButton:
                    Parent?.ShowHelp(For: .ShowUserPOIs, Where: Button.bounds, What: ShowUserPOIHelpButton)
                    
                case EditUserPOIHelpButton:
                    Parent?.ShowHelp(For: .EditUserPOIs, Where: Button.bounds, What: EditUserPOIHelpButton)
            
                case POIScaleHelpButton:
                    Parent?.ShowHelp(For: .POIScale, Where: Button.bounds, What: POIScaleHelpButton)
                    
                case ShowBuiltInPOIs:
                    Parent?.ShowHelp(For: .ShowBuiltInPOIs, Where: Button.bounds, What: ShowBuiltInPOIs)
                    
                case ShowListofBuiltInPOIs:
                    Parent?.ShowHelp(For: .ShowListofBuiltInPOIs, Where: Button.bounds, What: ShowListofBuiltInPOIs)
                    
                case ResetPaneHelp:
                    Parent?.ShowHelp(For: .POIResetPaneHelp, Where: Button.bounds, What: ResetPaneHelp)
                    
                default:
                    return
            }
        }
    }
    
    @IBAction func HandleShowBuiltInPOIsChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.ShowBuiltInPOIs, Switch.state == .on ? true: false)
        }
    }
    
    @IBAction func HandleShowHomeChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.ShowHomeLocation, Switch.state == .on ? true : false)
        }
    }
    
    @IBAction func HandleEditHomeLocationButton(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "HelperPanels", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "HomeLocationWindow") as?
            HomeLocationWindow
        {
            let Window = WindowController.window
            let VController = WindowController.window?.contentViewController as? HomeLocationController
            VController?.MainDelegate = MainDelegate
            self.view.window?.beginSheet(Window!)
            {
                Result in
            }
        }
    }
    
    @IBAction func HandleShowUserPOIsChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.ShowUserPOIs, Switch.state == .on ? true : false)
        }
    }
    
    @IBAction func HandleUnescoSiteTypeChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            var SiteType = WorldHeritageSiteTypes.Natural
            switch Segment.selectedSegment
            {
                case 0:
                    SiteType = .Cultural
                    
                case 1:
                    SiteType = .Natural
                    
                case 2:
                    SiteType = .Mixed
                    
                case 3:
                    SiteType = .AllSites
                    
                default:
                    return
            }
            Settings.SetEnum(SiteType, EnumType: WorldHeritageSiteTypes.self, ForKey: .WorldHeritageSiteType)
        }
    }
    
    @IBAction func HandleShowUnescoSitesChanged(_ sender: Any)
    {
        if let Switch = sender as? NSSwitch
        {
            Settings.SetBool(.ShowWorldHeritageSites, Switch.state == .on ? true : false)
        }
    }
    
    @IBAction func HandleEditUserPOIs(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "UserPOIEditor", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "UserPOIEditorWindow") as?
            UserPOIEditorWindow
        {
            let Window = WindowController.window
            let VController = WindowController.window?.contentViewController as? UserPOIEditorController 
            VController?.MainDelegate = MainDelegate
            self.view.window?.beginSheet(Window!)
            {
                Result in
            }
        }
    }
    
    @IBAction func POIScaleChangedHandler(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            let Index = Segment.selectedSegment
            if Index <= MapNodeScales.allCases.count - 1
            {
                let NewScale = MapNodeScales.allCases[Index]
                Settings.SetEnum(NewScale, EnumType: MapNodeScales.self, ForKey: .POIScale)
            }
        }
    }
    
    func SetDarkMode(To: Bool)
    {
        
    }
    
    @IBAction func HandleResetPane(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            let DoReset = RunMessageBoxOK(Message: "Reset settings on this pane?",
                                          InformationMessage: "You will lose all of the changes you have made to the settings on this panel.")
            if DoReset
            {
                ResetToFactorySettings()
            }
        }
    }
    
    func SetHelpVisibility(To: Bool)
    {
        for HelpButton in HelpButtons
        {
            HelpButton.alphaValue = To ? 1.0 : 0.0
            HelpButton.isEnabled = To ? true : false
        }
    }
    
    //https://stackoverflow.com/questions/29433487/create-an-nsalert-with-swift
    @discardableResult func RunMessageBoxOK(Message: String, InformationMessage: String) -> Bool
    {
        let Alert = NSAlert()
        Alert.messageText = Message
        Alert.informativeText = InformationMessage
        Alert.alertStyle = .warning
        Alert.addButton(withTitle: "Reset Values")
        Alert.addButton(withTitle: "Cancel")
        return Alert.runModal() == .alertFirstButtonReturn
    }
    
    func ResetToFactorySettings()
    {
        Settings.SetSecureString(.UserHomeName, "")
        Settings.SetSecureString(.UserHomeLatitude, "")
        Settings.SetSecureString(.UserHomeLongitude, "")
        Settings.SetBool(.ShowHomeLocation, false)
        ShowHomeSwitch.state = .off
        Settings.SetBool(.ShowBuiltInPOIs, false)
        ShowBuiltInPOIsSwitch.state = .off
        Settings.SetEnum(.Normal, EnumType: MapNodeScales.self, ForKey: .POIScale)
        POIScaleSegment.selectedSegment = 1
        Settings.SetBool(.ShowWorldHeritageSites, false)
        ShowUnescoSwitch.state = .off
        Settings.SetEnum(.Cultural, EnumType: WorldHeritageSiteTypes.self, ForKey: .WorldHeritageSiteType)
        UnescoSitesSegment.selectedSegment = 0
    }
    
    var HelpButtons: [NSButton] = [NSButton]()
    
    // MARK: - Interface builder outlets
    @IBOutlet weak var ShowHomeSwitch: NSSwitch!
    @IBOutlet weak var ShowUserPOISwitch: NSSwitch!
    @IBOutlet weak var POIScaleSegment: NSSegmentedControl!
    @IBOutlet weak var ShowBuiltInPOIsSwitch: NSSwitch!
    @IBOutlet weak var ShowUnescoSwitch: NSSwitch!
    @IBOutlet weak var UnescoSitesSegment: NSSegmentedControl!
    
    // MARK: - Help buttons
    @IBOutlet weak var EditUserPOIHelpButton: NSButton!
    @IBOutlet weak var ShowUserPOIHelpButton: NSButton!
    @IBOutlet weak var EditHomeLocationHelpButton: NSButton!
    @IBOutlet weak var ShowHomeHelpButton: NSButton!
    @IBOutlet weak var POIScaleHelpButton: NSButton!
    @IBOutlet weak var ShowBuiltInPOIs: NSButton!
    @IBOutlet weak var ShowListofBuiltInPOIs: NSButton!
    @IBOutlet weak var UNESCOHelpButton: NSButton!
    @IBOutlet weak var ShowWorldHeritageSiteHelpButton: NSButton!
    @IBOutlet weak var ResetPaneHelp: NSButton!
}
