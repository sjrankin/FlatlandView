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
        TestView.debugOptions = [.showBoundingBoxes]
        TestView.scene?.rootNode.addChildNode(MakeLight(Front: true))
        TestView.scene?.rootNode.addChildNode(MakeLight(Front: false))
        TestView.scene?.rootNode.addChildNode(MakeCamera())
        TestView.scene?.rootNode.addChildNode(MakeShapeNode())
//        TestView.scene?.rootNode.addChildNode(MakeHours())
        for Hour in 1 ... 24
        {
            TestView.scene?.rootNode.addChildNode(MakeHour(Hour, Radius: 12.5))
        }
        #if false
        TestView.scene?.background.contents = NSColor.black
        #else
        TestView.scene?.background.contents = NSImage(named: "EmptyGridRed")
        #endif
    }
    
    func MakeHour(_ Hour: Int, Radius: Double, Scale: Double = 0.05) -> SCNNode
    {
        let Angle = Double(Hour) * 15.0
        let HourText = "\(Hour)"
        let HourShape = SCNText(string: HourText, extrusionDepth: 1.0)
        HourShape.flatness = 0.1
        let Node = SCNNode(geometry: HourShape)
        Node.geometry?.firstMaterial?.diffuse.contents = NSColor.systemYellow
        Node.geometry?.firstMaterial?.specular.contents = NSColor.white
        let FinalAngle = (Angle - 90.0) * -1
        let Radians = FinalAngle.Radians
        let X = Radius * cos(Radians)
        let Y = Radius * sin(Radians)
        var XDelta = Double(Node.boundingBox.max.x - Node.boundingBox.min.x) / 2.0
        XDelta = XDelta * Scale
        var YDelta = Double(Node.boundingBox.max.y - Node.boundingBox.min.y) / 2.0
        YDelta = YDelta * Scale
        Node.pivot = SCNMatrix4MakeTranslation(CGFloat(XDelta), 0.0, 0.0)
        Node.position = SCNVector3(X, Y, 0.0)
        let NodeRotation = (FinalAngle - 90.0).Radians
        Node.eulerAngles = SCNVector3(0.0, 0.0, NodeRotation)
        Node.scale = SCNVector3(Scale, Scale, Scale)
        
        let Sphere = SCNNode(geometry: SCNSphere(radius: 0.5))
        Sphere.geometry?.firstMaterial?.diffuse.contents = NSColor.red
        Sphere.position = SCNVector3(X + 0.25, Y - 0.25, 0.0)
        TestView.scene?.rootNode.addChildNode(Sphere)
        
        return Node
    }
    
    func MakeHours() -> SCNNode
    {
        HourNode = SCNNode()
        
        var XDelta: CGFloat = 0.0
        var YDelta: CGFloat = 0.0
        let HourData: [(Int, Double)] =
            [
                (24, 360.0),
                (23, 345.0),
                (22, 330.0),
                (21, 315.0),
                (20, 300.0),
                (19, 285.0),
                (18, 270.0),
                (17, 255.0),
                (16, 240.0),
                (15, 225.0),
                (14, 210.0),
                (13, 195.0),
                (12, 180.0),
                (11, 165.0),
                (10, 150.0),
                (9, 135.0),
                (8, 120.0),
                (7, 105.0),
                (6, 90.0),
                (5, 75.0),
                (4, 60.0),
                (3, 45.0),
                (2, 30.0),
                (1, 15.0)
            ]
        var FinalXOffset = 0.0
        var FinalYOffset = 0.0
        for (Hour, HourAngle) in HourData
        {
            let HourText = "\(Hour)"
            let HourShape = SCNText(string: HourText, extrusionDepth: 1.0)
            HourShape.flatness = 0.1
            let Node = SCNNode(geometry: HourShape)
            Node.geometry?.firstMaterial?.diffuse.contents = NSColor.systemYellow
            Node.geometry?.firstMaterial?.specular.contents = NSColor.white
            let Angle = (HourAngle - 90.0) * -1
            let Radians = Angle.Radians
            let X = 12.5 * cos(Radians)
            let Y = 12.5 * sin(Radians)
            let NodeRotation = (Angle + 90.0).Radians
            //Node.position = SCNVector3(0.0, 0.0, 0.0)
            Node.rotation = SCNVector4(0.0, 0.0, 1.0, NodeRotation)
            
            HourNode.addChildNode(Node)
            XDelta = (Node.boundingBox.max.x - Node.boundingBox.min.x) / 2.0
            XDelta = XDelta * 0.05
            YDelta = (Node.boundingBox.max.y - Node.boundingBox.min.y) / 2.0
            YDelta = YDelta * 0.05
            Node.position = SCNVector3(X + Double(XDelta), Y + Double(YDelta * 2), 0.0)
            Node.scale = SCNVector3(0.05, 0.05, 0.05)
            if Hour == 24
            {
                FinalXOffset = Double(XDelta)
                FinalYOffset = Double(YDelta)
            }
        }
        HourNode.position = SCNVector3(0.0, 0.0, 0.0)
//        HourNode.position = SCNVector3(0.0 + FinalXOffset, 0.0 + (FinalYOffset * 2), 0.0)
        
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
        #if false
        Camera.usesOrthographicProjection = true
        Camera.orthographicScale = 15.0
        #else
        Camera.usesOrthographicProjection = false
        #endif
        Camera.fieldOfView = 100.0
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
