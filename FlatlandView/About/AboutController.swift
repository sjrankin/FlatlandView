//
//  AboutController.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

class AboutController: NSViewController, SCNSceneRendererDelegate, WindowManagement
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.systemGray.cgColor
        
        InitializeAboutView()
    }
    
    func InitializeAboutView()
    {
        AboutWorld.allowsCameraControl = true
        AboutWorld.autoenablesDefaultLighting = false
        AboutWorld.scene = SCNScene()
        AboutWorld.backgroundColor = NSColor.black
        
        let Camera = SCNCamera()
        Camera.fieldOfView = 90.0
        Camera.usesOrthographicProjection = true
        Camera.orthographicScale = 14
        Camera.zFar = 500
        Camera.zNear = 0.1
        CameraNode = SCNNode()
        CameraNode.camera = Camera
        //The camera's position is higher up in the scene to help show the shadows.
        CameraNode.position = SCNVector3(0.0, 10.0, 16.0)
        
        let Light = SCNLight()
        Light.type = .directional
        Light.intensity = 800
        Light.castsShadow = true
        Light.shadowColor = NSColor.black.withAlphaComponent(0.80)
        Light.shadowMode = .forward
        Light.shadowRadius = 3.0
        Light.color = NSColor.white
        LightNode = SCNNode()
        LightNode.light = Light
        LightNode.position = SCNVector3(0.0, 0.0, 80.0)
        
        let MoonLight = SCNLight()
        MoonLight.type = .directional
        MoonLight.intensity = 300
        MoonLight.castsShadow = true
        MoonLight.shadowColor = NSColor.black.withAlphaComponent(0.80)
        MoonLight.shadowMode = .forward
        MoonLight.shadowRadius = 6.0
        MoonLight.color = NSColor.cyan
        MoonNode = SCNNode()
        MoonNode.light = MoonLight
        MoonNode.position = SCNVector3(0.0, 0.0, -100.0)
        MoonNode.eulerAngles = SCNVector3(180.0 * CGFloat.pi / 180.0, 0.0, 0.0)
        
        AboutWorld.scene?.rootNode.addChildNode(CameraNode)
        AboutWorld.scene?.rootNode.addChildNode(LightNode)
        AboutWorld.scene?.rootNode.addChildNode(MoonNode)
        
        DrawWorld()
        StartEarthClock()
        //Make sure the camera is pointed to the Earth.
        CameraNode.look(at: SCNVector3(0.0, 0.0, 0.0))
    }
    
    var CameraNode = SCNNode()
    var LightNode = SCNNode()
    var MoonNode = SCNNode()
    
    func StartEarthClock()
    {
        let SomeTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                             target: self,
                                             selector: #selector(UpdateAboutEarth),
                                             userInfo: nil,
                                             repeats: true)
        SomeTimer.tolerance = 0.1
    }
    
    @objc func UpdateAboutEarth()
    {
        let Now = Date()
        let TZ = TimeZone(abbreviation: "UTC")
        var Cal = Calendar(identifier: .gregorian)
        Cal.timeZone = TZ!
        let Hour = Cal.component(.hour, from: Now)
        let Minute = Cal.component(.minute, from: Now)
        let Second = Cal.component(.second, from: Now)
        let ElapsedSeconds = Second + (Minute * 60) + (Hour * 60 * 60)
        let Percent = Double(ElapsedSeconds) / Double(Date.SecondsIn(.Day))
        let PrettyPercent = Double(Int(Percent * 1000.0)) / 1000.0
        UpdateEarth(With: PrettyPercent)
    }
    
    func UpdateEarth(With Percent: Double)
    {
        let Degrees = 180.0 - (360.0) * Percent
        let Radians = Degrees.Radians
        let Rotate = SCNAction.rotateTo(x: 0.0, y: CGFloat(-Radians), z: 0.0, duration: 1.0)
        EarthNode?.runAction(Rotate)
    }
    
    /// Draw the world. Depending on the user, draw a spherical or cubical world.
    func DrawWorld()
    {
        if CurrentView == ViewTypes.Globe3D
        {
            DrawGlobeWorld()
        }
        else
        {
            DrawAboutCube()
        }
    }
    
    /// Draw a spherical world.
    func DrawGlobeWorld()
    {
        EarthNode?.removeAllActions()
        EarthNode?.removeFromParentNode()
        EarthNode = nil
        SystemNode?.removeAllActions()
        SystemNode?.removeFromParentNode()
        SystemNode = nil
        
        let Surface = SCNSphere(radius: 10.0)
        Surface.segmentCount = 100
        let BaseMap = NSImage(named: "AboutMap")
        if BaseMap == nil
        {
            fatalError("Error retrieving base map in About.")
        }
        EarthNode = SCNNode(geometry: Surface)
        EarthNode?.position = SCNVector3(0.0, 0.0, 0.0)
        EarthNode?.geometry?.firstMaterial?.diffuse.contents = BaseMap!
        SystemNode = SCNNode()
        AboutWorld.prepare([EarthNode!], completionHandler:
            {
                success in
                if success
                {
                    self.SystemNode!.addChildNode(self.EarthNode!)
                    self.AboutWorld.scene?.rootNode.addChildNode(self.SystemNode!)
                }
        })
        
        let Declination = Sun.Declination(For: Date())
        SystemNode!.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
        AddAboutText()
    }
    
    /// Draws a cubical Earth for no other reason than being silly.
    func DrawAboutCube()
    {
        EarthNode?.removeAllActions()
        EarthNode?.removeFromParentNode()
        SystemNode?.removeAllActions()
        SystemNode?.removeFromParentNode()
        
        let EarthCube = SCNBox(width: 10.0, height: 10.0, length: 10.0, chamferRadius: 0.5)
        EarthNode = SCNNode(geometry: EarthCube)
        
        EarthNode?.position = SCNVector3(0.0, 0.0, 0.0)
        EarthNode?.geometry?.materials.removeAll()
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.nx)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.pz)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.px)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.nz)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.pym90)!)
        EarthNode?.geometry?.materials.append(MapManager.CubicImageMaterial(.ny90)!)
        EarthNode?.geometry?.firstMaterial?.specular.contents = NSColor.clear
        EarthNode?.geometry?.firstMaterial?.lightingModel = .blinn
        
        let Declination = Sun.Declination(For: Date())
        SystemNode = SCNNode()
        SystemNode?.eulerAngles = SCNVector3(Declination.Radians, 0.0, 0.0)
        
        AboutWorld.prepare([EarthNode!], completionHandler:
            {
                success in
                if success
                {
                    self.SystemNode?.addChildNode(self.EarthNode!)
                    self.AboutWorld.scene?.rootNode.addChildNode(self.SystemNode!)
                }
        }
        )
    }
    
    /// Draw the version string that orbits the Earth.
    func AddAboutText()
    {
        if TextAdded
        {
            return
        }
        TextAdded = true
        let NameNodes = Utility.MakeFloatingWord2(Radius: 12.0, Word: "Flatland", SpacingConstant: 25.0,
                                                 Latitude: 0.0, Longitude: 0.0, Extrusion: 5.0,
                                                 TextFont: NSFont(name: "Avenir-Black", size: 28),
                                                 TextColor: NSColor.systemRed,
                                                 TextSpecular: NSColor.systemOrange)
        let VersionNodes = Utility.MakeFloatingWord2(Radius: 12.0, Word: Versioning.MakeVersionString(),
                                                     SpacingConstant: 25.0,
                                                     Latitude: 0.0, Longitude: 60.0, Extrusion: 4.0,
                                                     TextFont: NSFont(name: "Avenir-Heavy", size: 24),
                                                     TextColor: NSColor.gray,
                                                     TextSpecular: NSColor.white)
        let BuildNodes = Utility.MakeFloatingWord2(Radius: 12.0, Word: "Build \(Versioning.Build) (\(Versioning.BuildDate))",
                                                     SpacingConstant: 25.0,
                                                     Latitude: 0.0, Longitude: 120.0, Extrusion: 4.0,
                                                     TextFont: NSFont(name: "Avenir-Heavy", size: 24),
                                                     TextColor: NSColor.gray,
                                                     TextSpecular: NSColor.white)
        let TextNode = SCNNode()
        NameNodes.forEach({TextNode.addChildNode($0)})
        VersionNodes.forEach({TextNode.addChildNode($0)})
        BuildNodes.forEach({TextNode.addChildNode($0)})
        TextNode.position = SCNVector3(0.0, 0.0, 0.0)
        AboutWorld.scene?.rootNode.addChildNode(TextNode)
        let Rotation = SCNAction.rotateBy(x: 0.0, y: -CGFloat.pi / 180.0, z: 0.0, duration: 0.06)
        let Forever = SCNAction.repeatForever(Rotation)
        TextNode.runAction(Forever)
    }
    
    var TextAdded = false
    var EarthNode: SCNNode? = nil
    var SystemNode: SCNNode? = nil
    var HourNode: SCNNode? = nil
    
    @IBAction func HandleCloseButton(_ sender: Any)
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent!.endSheet(Window!, returnCode: .OK)
    }
    
    @IBAction func HandleDetailsButton(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "About", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "AboutDetails") as? AboutDetailsWindow
        {
            let Window = WindowController.window
            self.view.window?.beginSheet(Window!, completionHandler: nil)
        }
    }
    
    @IBAction func HandleViewTypePressed(_ sender: Any)
    {
        if let Button = sender as? NSButton
        {
            if CurrentView == .Globe3D
            {
                CurrentView = .CubicWorld
            }
            else
            {
                CurrentView = .Globe3D
            }
            if CurrentView == .Globe3D
            {
                Button.image = NSImage(named: "CubeIcon")
            }
            else
            {
                Button.image = NSImage(named: "GlobeIcon")
            }
            DrawWorld()
        }
    }
    
    var CurrentView = ViewTypes.Globe3D
    
    func MainClosing()
    {
        let Window = self.view.window
        let Parent = Window?.sheetParent
        Parent!.endSheet(Window!, returnCode: .OK)
    }
    
    @IBOutlet weak var ViewTypeButton: NSButton!
    @IBOutlet weak var AboutWorld: SCNView!
}
