//
//  2Din3DController.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/12/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit
import CoreImage
import CoreImage.CIFilterBuiltins

class TwoDin3DController: NSViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InitializeView()
    }
    
    func InitializeView()
    {
        let Scene = SCNScene()
        TestView.scene = Scene
        TestView.scene?.rootNode.addChildNode(MakeLight(Front: true))
        TestView.scene?.rootNode.addChildNode(MakeLight(Front: false))
        TestView.scene?.rootNode.addChildNode(MakeCamera())
        TestView.scene?.rootNode.addChildNode(MakeShapeNode())
        TestView.scene?.rootNode.addChildNode(MakeHours())
        TestView.scene?.background.contents = NSImage(named: "EmptyGrid") //NSColor.black
    }
    
    func MakeHours() -> SCNNode
    {
        HourNode = SCNNode()
        
        var XDelta: CGFloat = 0.0
        var YDelta: CGFloat = 0.0
        for Hour in 1 ... 24
        {
            let HourText = "\(24 - Hour)"
            let HourShape = SCNText(string: HourText, extrusionDepth: 1.0)
            HourShape.flatness = 0.1
            let Node = SCNNode(geometry: HourShape)
            Node.geometry?.firstMaterial?.diffuse.contents = NSColor.systemYellow
            Node.geometry?.firstMaterial?.specular.contents = NSColor.white
            let Angle: Double = (Double(Hour) * 15.0) - 90.0
            let Radians = Angle.Radians
            let X = 12.0 * cos(Radians)
            let Y = 12.0 * sin(Radians)
            Node.position = SCNVector3(X, Y, 0.0)
            Node.scale = SCNVector3(0.05, 0.05, 0.05)
            HourNode.addChildNode(Node)
            if Hour == 24
            {
                XDelta = (Node.boundingBox.max.x - Node.boundingBox.min.x) / 2.0
                XDelta = XDelta * 0.05
                YDelta = (Node.boundingBox.max.y - Node.boundingBox.min.y) / 2.0
                YDelta = YDelta * 0.05
            }
        }
        HourNode.position = SCNVector3(0.0 - XDelta, 0.0 - (YDelta * 2), 0.0)
        
        return HourNode
    }
    
    var HourNode = SCNNode()
    
    //https://cocoaapi.hatenablog.com/entry/00000522/recID9377
    func MakeShapeNode() -> SCNNode
    {
        let Shape = SCNCylinder(radius: 10.0, height: 0.5)
        Shape.radialSegmentCount = 100
        let Node = SCNNode(geometry: Shape)
        let Image = NSImage(named: "SimplePoliticalWorldMapSouthCenter")
        let ImageTiff = Image?.tiffRepresentation
        var CImage = CIImage(data: ImageTiff!)
        let Transform = CGAffineTransform(scaleX: -1, y: 1)
        CImage = CImage?.transformed(by: Transform)
        let CImageRep = NSCIImageRep(ciImage: CImage!)
        let Final = NSImage(size: CImageRep.size)
        Final.addRepresentation(CImageRep)
        Node.geometry?.firstMaterial?.diffuse.contents = Final
        Node.geometry?.firstMaterial?.lightingModel = .phong
        Node.position = SCNVector3(0.0, 0.0, 0.0)
        Node.eulerAngles = SCNVector3(90.0.Radians, 180.0.Radians, 0.0)
        return Node
    }
    
    func MakeLight(Front: Bool) -> SCNNode
    {
    let Light = SCNLight()
        Light.color = NSColor.white
        Light.type = .omni
        let Node = SCNNode()
        Node.light = Light
        let Z = Front ? 15.0 : -15.0
        Node.position = SCNVector3(0.0, 0.0, Z)
        return Node
    }
    
    func MakeCamera() -> SCNNode
    {
        let Camera = SCNCamera()
        Camera.usesOrthographicProjection = false
        Camera.fieldOfView = 90.0
        let Node = SCNNode()
        Node.camera = Camera
        Node.position = SCNVector3(0.0, 0.0, 15.0)
        return Node
    }
    
    @IBAction func HandleCloseButton(_ sender: Any)
    {
        self.view.window?.close()
    }
    
    @IBOutlet weak var TestView: SCNView!
}
