//
//  DebuggerController.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/8/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class DebuggerController: NSViewController, WindowManagement
{
    public weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    var ParentWindow: DebuggerWindow? = nil
    
    override func viewDidLayout()
    {
        ParentWindow = self.view.window?.windowController as? DebuggerWindow
        MakePanels()
        ParentWindow?.Highlight(ParentWindow!.DebugLogButton)
        SelectPanel(.DebugLog)
    }
    
    override func viewWillDisappear()
    {
        MainDelegate?.ChildWindowClosed(.DebuggerWindow)
        super.viewWillDisappear()
    }
    
    func SelectPanel(_ Panel: DebugPanels)
    {
        for SomeView in DebugContainer.subviews
        {
            SomeView.removeFromSuperview()
        }
        Panels[Panel]!.Controller?.view.frame = DebugContainer.bounds
        DebugContainer.addSubview(Panels[Panel]!.Controller!.view)
    }
    
    func MakePanels()
    {
        Panels[.TimeControl] = DebugPanelBase(CreatePanelDialog("TimeControlUI"))
        Panels[.DebugLog] = DebugPanelBase(CreatePanelDialog("DebugLogViewer"))
        Panels[.CommandLine] = DebugPanelBase(CreatePanelDialog("CommandLineUI"))
        Panels[.Debug3D] = DebugPanelBase(CreatePanelDialog("Debug3D"))
        Panels[.MapDebug] = DebugPanelBase(CreatePanelDialog("MapDebug"))
    }
    
    var Panels = [DebugPanels: DebugPanelBase]()
    
    func CreatePanelDialog(_ IDName: String) -> NSViewController?
    {
        if let Controller = NSStoryboard(name: "Debug", bundle: nil).instantiateController(withIdentifier: IDName) as? NSViewController
        {
            if let PController = Controller as? PanelController
            {
                PController.Main = MainDelegate
                return PController
            }
        }
        fatalError("Error creating \(IDName)")
    }
    
    @IBAction func HandleTimeControl(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            ParentWindow?.Highlight(Button)
            SelectPanel(.TimeControl)
        }
    }
    
    @IBAction func HandleDebugLog(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            ParentWindow?.Highlight(Button)
            SelectPanel(.DebugLog)
        }
    }
    
    @IBAction func HandleCommandLine(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            ParentWindow?.Highlight(Button)
            SelectPanel(.CommandLine)
        }
    }
    
    @IBAction func HandleDebug3D(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            ParentWindow?.Highlight(Button)
            SelectPanel(.Debug3D)
        }
    }
    
    @IBAction func HandleMapDebug(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            ParentWindow?.Highlight(Button)
            SelectPanel(.MapDebug)
        }
    }
    
    func MainClosing()
    {
        self.view.window?.close()
    }
    
    @IBOutlet weak var DebugContainer: ContainerController!
}

enum DebugPanels
{
    case TimeControl
    case DebugLog
    case CommandLine
    case Debug3D
    case MapDebug
}
