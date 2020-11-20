//
//  +Locations.swift
//  Flatland
//
//  Created by Stuart Rankin on 6/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit
import CoreImage

extension GlobeView
{
    /// Plot user locations as inverted cones.
    /// - Parameter Plot: The city to plot.
    /// - Parameter Latitude: The latitude of the arrow.
    /// - Parameter Longitude: The longitude of the arrow.
    /// - Parameter Radius: The radius of the Earth. (The arrow is plotted above the radius by a
    ///                     constant to ensure the entire arrow is visible.)
    /// - Parameter ToSurface: The surface node where the arrow will be added.
    /// - Parameter WithColor: Ignored if `IsCurrentLocation` is true. Otherwise, this is the color of
    ///                        the arrow head shape.
    /// - Parameter EnableEmission: Determines if emission color is enabled. Defaults to `true`.
    /// - Parameter NodeID: ID of the node. This is the ID that is used to identify the node when the mouse moves
    ///                     over it.
    /// - Parameter NodeClass: The node class of the city.
    func PlotLocationAsCone(_ Plot: City2, Latitude: Double, Longitude: Double, Radius: Double, ToSurface: SCNNode2,
                            WithColor: NSColor = NSColor.magenta, EnableEmission: Bool = true,
                            NodeID: UUID, NodeClass: UUID)
    {
        let (X, Y, Z) = ToECEF(Latitude, Longitude, Radius: Radius + 0.1)
        let Attributes: ShapeAttributes =
            {
               let A = ShapeAttributes()
                let TheSize: Sizes =
                    {
                       let S = Sizes()
                        S.TopRadius = 0.15
                        S.BottomRadius = 0.0
                        S.Height = 0.45
                        return S
                    }()
                A.ShapeSize = TheSize
                A.AttributesChange = true
                A.CastsShadow = true
                A.Class = NodeClass
                A.ID = NodeID
                A.EulerX = (Latitude + 90).Radians
                A.EulerY = (Longitude + 180.0).Radians
                A.Position = SCNVector3(X, Y, Z)
                A.Latitude = Latitude
                A.Longitude = Longitude
                let Day: TimeState =
                    {
                        let D = TimeState()
                        D.Color = WithColor
                        D.Emission = nil
                        D.IsDayState = true
                        return D
                    }()
                A.DayState = Day
                let Night: TimeState =
                    {
                       let N = TimeState()
                        N.Color = WithColor
                        N.Emission = WithColor
                        N.IsDayState = false
                        return N
                    }()
                A.NightState = Night
                A.ShowBoundingShapes = true
                A.LightMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                return A
            }()
        let ConeNode = ShapeManager.Create(.Cone, Attributes: Attributes)
        ToSurface.addChildNode(ConeNode)
        PlottedCities.append(ConeNode)
    }
    
    #if false
    /// Plot the location as a sphere.
    /// - Parameters:
    ///   - Plot: The city to plot.
    ///   - Latitude: The latitude of the city.
    ///   - Longitude: The longitude of the city.
    ///   - Radius: The radius of the Earth.
    ///   - ToSurface: The surface node of the Earth.
    ///   - WithColor: The color of the sphere.
    func PlotLocationAsSphere(_ Plot: City2, Latitude: Double, Longitude: Double, Radius: Double, ToSurface: SCNNode2,
                              WithColor: NSColor = NSColor.magenta)
    {
        let (X, Y, Z) = ToECEF(Latitude, Longitude, Radius: Radius + 0.1)
        #if true
        let Attributes: ShapeAttributes =
            {
                let A = ShapeAttributes()
                A.AttributesChange = true
                A.CastsShadow = true
                A.Class = Plot.nod
                A.ID = NodeID
                A.EulerX = (Latitude + 90).Radians
                A.EulerY = (Longitude + 180.0).Radians
                A.Position = SCNVector3(X, Y, Z)
                A.Latitude = Latitude
                A.Longitude = Longitude
                let Day: TimeState =
                    {
                        let D = TimeState()
                        D.Color = WithColor
                        D.Emission = nil
                        D.IsDayState = true
                        return D
                    }()
                A.DayState = Day
                let Night: TimeState =
                    {
                        let N = TimeState()
                        N.Color = WithColor
                        N.Emission = WithColor
                        N.IsDayState = false
                        return N
                    }()
                A.NightState = Night
                A.LightMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                return A
            }()
        let SphereNode = ShapeManager.SphereShape(Radius: 0.2, Attributes: Attributes)
        #else
        let Sphere = SCNSphere(radius: 0.2)
        let SphereNode = SCNNode2(geometry: Sphere)
        SphereNode.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        SphereNode.geometry?.firstMaterial?.diffuse.contents = WithColor
        SphereNode.geometry?.firstMaterial?.specular.contents = NSColor.white
        
        let Cone = SCNCone(topRadius: 0.0, bottomRadius: 0.2, height: 0.5)
        let ConeNode = SCNNode(geometry: Cone)
        ConeNode.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        ConeNode.geometry?.firstMaterial?.diffuse.contents = WithColor
        ConeNode.geometry?.firstMaterial?.specular.contents = NSColor.white
        
        let UserNode = SCNNode2()
        UserNode.castsShadow = true
        UserNode.position = SCNVector3(X, Y, Z)
        UserNode.addChildNode(SphereNode)
        UserNode.addChildNode(ConeNode)
        let YRotation = Latitude + 90.0
        let XRotation = Longitude + 180.0
        UserNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, 0.0)
        #endif
        ToSurface.addChildNode(UserNode)
        PlottedCities.append(UserNode)
    }
    #endif

    /// Plot a city on the 3D sphere. A sphere is set on the surface of the Earth.
    /// - Parameter Plot: The city to plot.
    /// - Parameter Latitude: The latitude of the city.
    /// - Parameter Longitude: The longitude of the city.
    /// - Parameter ToSurface: The surface that defines the globe.
    /// - Parameter WithColor: The color of the city shape.
    /// - Parameter RelativeSize: The relative size of the city.
    /// - Parameter LargestSize: The largest permitted.
    func PlotEmbeddedCitySphere(_ Plot: City2, Latitude: Double, Longitude: Double, Radius: Double, ToSurface: SCNNode2,
                                WithColor: NSColor = NSColor.red, RelativeSize: Double = 1.0, LargestSize: Double = 1.0)
    {
        var CitySize = Double(RelativeSize * LargestSize)
        if CitySize < 0.15
        {
            CitySize = 0.15
        }
        #if true
        let (X, Y, Z) = ToECEF(Latitude, Longitude, Radius: Double(10 - (CitySize / 2)))
        let Attributes: ShapeAttributes =
            {
                let A = ShapeAttributes()
                let Size: Sizes =
                    {
                       let S = Sizes()
                        S.Radius = CitySize
                        return S
                    }()
                A.ShapeSize = Size
                A.AttributesChange = true
                A.CastsShadow = true
                A.Class = UUID(uuidString: NodeClasses.City.rawValue)!
                A.ID = Plot.CityID
                A.EulerX = (Latitude + 90).Radians
                A.EulerY = (Longitude + 180.0).Radians
                A.Position = SCNVector3(X, Y, Z)
                A.Latitude = Latitude
                A.Longitude = Longitude
                let Day: TimeState =
                    {
                        let D = TimeState()
                        D.Color = WithColor
                        D.Emission = nil
                        D.IsDayState = true
                        return D
                    }()
                A.DayState = Day
                let Night: TimeState =
                    {
                        let N = TimeState()
                        N.Color = WithColor
                        N.Emission = WithColor
                        N.IsDayState = false
                        return N
                    }()
                A.NightState = Night
                A.LightMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                return A
            }()
        //let CityNode = ShapeManager.SphereShape(Radius: CitySize, Attributes: Attributes)
        let CityNode = ShapeManager.Create(.Sphere, Attributes: Attributes)
        #else
        let CityShape = SCNSphere(radius: CitySize)
        let CityNode = SCNNode2(geometry: CityShape)
        CityNode.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        CityNode.geometry?.firstMaterial?.diffuse.contents = WithColor
        #if false
        if Settings.GetBool(.CityNodesGlow)
        {
            CityNode.geometry?.firstMaterial?.selfIllumination.contents = WithColor
            //        CityNode.geometry?.firstMaterial?.emission.contents = NSImage(named: "CitySphereTexture")
        }
        #endif
        CityNode.SetLocation(Latitude, Longitude)
        CityNode.SetState(ForDay: true, Color: WithColor, Emission: nil, Model: .phong, Metalness: nil, Roughness: nil)
        CityNode.SetState(ForDay: false, Color: WithColor, Emission: WithColor, Model: .phong, Metalness: nil, Roughness: nil)
        CityNode.CanSwitchState = true
        CityNode.IsInDaylight = Solar.IsInDaylight(Latitude, Longitude)!
        CityNode.castsShadow = true
        SunLight.intensity = 800
        let (X, Y, Z) = ToECEF(Latitude, Longitude, Radius: Double(10 - (CitySize / 2)))
        CityNode.position = SCNVector3(X, Y, Z)
        CityNode.name = GlobeNodeNames.CityNode.rawValue
        #endif
        ToSurface.addChildNode(CityNode)
        PlottedCities.append(CityNode)
    }
    
    /// Create a material that is essentially a square with the passed color and a black border.
    /// - Parameter With: The color of the center of the material.
    /// - Returns: `SCNMaterial` of the bordered color.
    func MakeOutlineCubeTexture(With Color: NSColor) -> SCNMaterial
    {
        let Outline = NSImage(named: "BlockTexture2")
        let OutlineSize = Outline?.size
        let bsize = NSSize(width: OutlineSize!.width / 2, height: OutlineSize!.height / 2)
        let Bottom = NSImage(size: bsize)
        Bottom.lockFocus()
        Color.drawSwatch(in: NSRect(origin: .zero, size: bsize))
        Bottom.unlockFocus()
        
        let OutlineData = Outline?.tiffRepresentation
        let OutlineImage = CIImage(data: OutlineData!)
        let BottomData = Bottom.tiffRepresentation
        let BottomImage = CIImage(data: BottomData!)
        let Filter = CIFilter.sourceAtopCompositing()
        Filter.setDefaults()
        Filter.inputImage = OutlineImage
        Filter.backgroundImage = BottomImage
        let ResultImage = Filter.outputImage
        let Rep = NSCIImageRep(ciImage: ResultImage!)
        let Final = NSImage(size: OutlineSize!)
        Final.addRepresentation(Rep)
        let Material = SCNMaterial()
        Material.diffuse.contents = Final
        return Material
    }
    
    /// Plot a city in the shape of a pyramid.
    /// - Parameter Plot: The city to plot.
    /// - Parameter Latitude: The latitude of the city.
    /// - Parameter Longitude: The longitude of the city.
    /// - Parameter ToSurface: The surface that defines the globe.
    /// - Parameter WithColor: The color of the city shape.
    /// - Parameter RelativeSize: The relative size of the city. Used to determine how large of a
    ///                           city shape to create.
    /// - Parameter LargestSize: The largest city size. This value is multiplied by `RelativeSize`
    ///                          which is assumed to be a normal value.
    func PlotPyramidCity(_ Plot: City2, Latitude: Double, Longitude: Double, Radius: Double,
                         ToSurface: SCNNode2, WithColor: NSColor, RelativeSize: Double = 1.0,
                         LargestSize: Double = 1.0)
    {
        var CitySize = Double(RelativeSize * LargestSize)
        if CitySize < 0.33
        {
            CitySize = 0.33
        }
        var HDim = CitySize * 0.1
        if HDim < 0.25
        {
            HDim = 0.25
        }
        #if true
        let (X, Y, Z) = ToECEF(Latitude, Longitude, Radius: Radius)
        let Attributes: ShapeAttributes =
            {
                let A = ShapeAttributes()
                let Size: Sizes =
                    {
                       let S = Sizes()
                        S.Width = HDim
                        S.Height = CitySize
                        S.Length = HDim
                        return S
                    }()
                A.ShapeSize = Size
                A.AttributesChange = true
                A.CastsShadow = true
                A.Class = UUID(uuidString: NodeClasses.City.rawValue)!
                A.ID = Plot.CityID
                A.EulerX = (Latitude + 90).Radians
                A.EulerY = (Longitude + 180.0).Radians
                A.Position = SCNVector3(X, Y, Z)
                A.Latitude = Latitude
                A.Longitude = Longitude
                let Day: TimeState =
                    {
                        let D = TimeState()
                        D.Color = WithColor
                        D.Emission = nil
                        D.IsDayState = true
                        return D
                    }()
                A.DayState = Day
                let Night: TimeState =
                    {
                        let N = TimeState()
                        N.Color = WithColor
                        N.Emission = WithColor
                        N.IsDayState = false
                        return N
                    }()
                A.NightState = Night
                A.LightMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                return A
            }()
        let CityNode = ShapeManager.Create(.Pyramid, Attributes: Attributes)
        //let CityNode = ShapeManager.PyramidShape(Width: HDim, Height: CitySize, Length: HDim,
        //                                        Attributes: Attributes)
        #else
        var CityNode = SCNNode2()
        let CityShape = SCNPyramid(width: HDim, height: CitySize, length: HDim)
        CityNode = SCNNode2(geometry: CityShape)
        CityNode.categoryBitMask = LightMasks3D.MetalSun.rawValue | LightMasks3D.MetalMoon.rawValue
        let SideImage = MakeOutlineCubeTexture(With: WithColor)
        CityNode.geometry?.materials.removeAll()
        CityNode.geometry?.materials.append(SideImage)
        CityNode.geometry?.materials.append(SideImage)
        CityNode.geometry?.materials.append(SideImage)
        CityNode.geometry?.materials.append(SideImage)
        CityNode.geometry?.materials.append(SideImage)
        CityNode.geometry?.firstMaterial?.specular.contents = NSColor.white
        if Settings.GetBool(.CityNodesGlow)
        {
            for Material in CityNode.geometry!.materials
            {
                Material.selfIllumination.contents = WithColor
            }
        }
        CityNode.geometry?.firstMaterial?.lightingModel = .physicallyBased
        CityNode.castsShadow = true
        CityNode.geometry?.firstMaterial?.roughness.contents = NSNumber(value: 0.7)
        CityNode.geometry?.firstMaterial?.metalness.contents = NSNumber(value: 1.0)
        let (X, Y, Z) = ToECEF(Latitude, Longitude, Radius: Radius)
        CityNode.position = SCNVector3(X, Y, Z)
        CityNode.name = GlobeNodeNames.CityNode.rawValue
        let YRotation = Latitude + 270.0
        let XRotation = Longitude + 180.0
        CityNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, 0.0)
        #endif
        ToSurface.addChildNode(CityNode)
        PlottedCities.append(CityNode)
    }
    
    /// Plot a city on the 3D sphere. The city display is a float ball whose radius is relative to
    /// the overall size of selected cities and altitude over the Earth is also relative to the population.
    /// - Parameter Plot: The city to plot.
    /// - Parameter Latitude: The latitude of the city.
    /// - Parameter Longitude: The longitude of the city.
    /// - Parameter ToSurface: The surface that defines the globe.
    /// - Parameter WithColor: The color of the city shape.
    /// - Parameter RelativeSize: The relative size of the city. Used to determine how large of a
    ///                           city shape to create.
    /// - Parameter RelativeHeight: The relative height of the city over the Earth.
    /// - Parameter LargestSize: The largest city size. This value is multiplied by `RelativeSize`
    ///                          which is assumed to be a normal value.
    /// - Parameter LongestStem: The length of the stem from the Earth to the floating city shape.
    ///                          This value is multiplied by `RelativeHeight` which is assumed to be
    ///                          a normal value.
    /// - Parameter IsASphere: If true, a sphere is used to represent the city. If false, a box is
    ///                        used instead.
    func PlotFloatingCity(_ Plot: City2, Latitude: Double, Longitude: Double, Radius: Double, ToSurface: SCNNode2,
                          WithColor: NSColor = NSColor.red, RelativeSize: Double = 1.0,
                          RelativeHeight: Double = 1.0, LargestSize: Double = 1.0, LongestStem: Double = 1.0,
                          IsASphere: Bool)
    {
        let RadialOffset = 0.1
        let (X, Y, Z) = ToECEF(Latitude, Longitude, Radius: Radius + RadialOffset)
        
        var CitySize: CGFloat = CGFloat(LargestSize * RelativeSize)
        if CitySize < 0.15
        {
            CitySize = 0.15
        }
        var CityNode: SCNNode2!
        if IsASphere
        {
            let Sphere = SCNSphere(radius: CitySize)
            CityNode = SCNNode2(geometry: Sphere)
            CityNode.geometry?.firstMaterial?.diffuse.contents = WithColor
            CityNode.geometry?.firstMaterial?.specular.contents = NSColor.white
            #if false
            if Settings.GetBool(.CityNodesGlow)
            {
                CityNode.geometry?.firstMaterial?.selfIllumination.contents = WithColor
            }
            #endif
            CityNode.SetState(ForDay: true, Color: WithColor, Emission: nil, Model: .phong, Metalness: nil, Roughness: nil)
            CityNode.SetState(ForDay: false, Color: WithColor, Emission: WithColor, Model: .phong, Metalness: nil, Roughness: nil)
        }
        else
        {
            let Side = CitySize * 2.0
            let Box = SCNBox(width: Side, height: Side, length: Side, chamferRadius: 0.05)
            CityNode = SCNNode2(geometry: Box)
            let SideImage = MakeOutlineCubeTexture(With: WithColor)
            CityNode.geometry?.materials.removeAll()
            CityNode.geometry?.materials.append(SideImage)
            CityNode.geometry?.materials.append(SideImage)
            CityNode.geometry?.materials.append(SideImage)
            CityNode.geometry?.materials.append(SideImage)
            CityNode.geometry?.materials.append(SideImage)
            CityNode.geometry?.materials.append(SideImage)
            CityNode.geometry?.firstMaterial?.specular.contents = NSColor.white
            #if false
            if Settings.GetBool(.CityNodesGlow)
            {
                for Material in CityNode.geometry!.materials
                {
                    Material.selfIllumination.contents = WithColor
                }
            }
            #endif
            CityNode.HasImageTextures = true
            CityNode.SetState(ForDay: true, Color: WithColor, Emission: nil, Model: .phong, Metalness: nil, Roughness: nil)
            CityNode.SetState(ForDay: false, Color: WithColor, Emission: WithColor, Model: .phong, Metalness: nil, Roughness: nil)
        }
        CityNode.SetLocation(Latitude, Longitude)
        CityNode.CanSwitchState = true
        CityNode.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        CityNode.NodeID = Plot.CityID
        CityNode.NodeClass = UUID(uuidString: NodeClasses.City.rawValue)!
        if let IsInDay = Solar.IsInDaylight(Latitude, Longitude)
        {
            CityNode.IsInDaylight = IsInDay
        }
        
        var CylinderLength = CGFloat(LongestStem * RelativeHeight)
        if CylinderLength < 0.1
        {
            CylinderLength = 0.1
        }
        let Cylinder = SCNCylinder(radius: 0.04, height: CGFloat(LongestStem * RelativeHeight))
        let CylinderNode = SCNNode2(geometry: Cylinder)
        CylinderNode.NodeID = Plot.CityID
        CylinderNode.NodeClass = UUID(uuidString: NodeClasses.City.rawValue)!
        CylinderNode.CanShowBoundingShape = false
        CylinderNode.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        let (H, S, B) = WithColor.HSB
        var NewH = H + 0.5
        if NewH > 1.0
        {
            NewH = NewH - 1.0
        }
        let StemColor = NSColor(calibratedHue: NewH, saturation: S, brightness: B, alpha: 1.0)
        CylinderNode.geometry?.firstMaterial?.diffuse.contents = StemColor
        CylinderNode.geometry?.firstMaterial?.specular.contents = NSColor.white
        CylinderNode.castsShadow = true
        SunLight.intensity = 800
        CylinderNode.position = SCNVector3(0.0, 0.0, 0.0)
        CityNode.position = SCNVector3(0.0, -(CylinderLength - CitySize), 0.0)
        
        let FinalNode = SCNNode2()
        FinalNode.NodeID = Plot.CityID
        FinalNode.NodeClass = UUID(uuidString: NodeClasses.City.rawValue)!
        FinalNode.addChildNode(CityNode)
        FinalNode.addChildNode(CylinderNode)
        
        FinalNode.position = SCNVector3(X, Y, Z)
        
        let YRotation = Latitude + 90.0
        let XRotation = Longitude + 180.0
        FinalNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, 0.0)
        FinalNode.name = GlobeNodeNames.CityNode.rawValue
        FinalNode.CanSwitchState = true
        FinalNode.SetLocation(Latitude, Longitude)
        
        ToSurface.addChildNode(FinalNode)
        PlottedCities.append(FinalNode)
    }
    
    /// Plot a city on the 3D sphere. A box is placed on the surface of the Earth.
    /// - Parameter Plot: The city to plot.
    /// - Parameter Latitude: The latitude of the city.
    /// - Parameter Longitude: The longitude of the city.
    /// - Parameter ToSurface: The surface that defines the globe.
    /// - Parameter WithColor: The color of the city shape.
    /// - Parameter RelativeSize: The relative size of the city.
    /// - Parameter LargestSize: The largest permitted.
    /// - Parameter IsBox: If true, the shape of the city is based on `SCNBox`. If false, the shape
    ///                    is based on `SCNCylinder`.
    func PlotSimpleCityShape(_ Plot: City2, Latitude: Double, Longitude: Double, Radius: Double, ToSurface: SCNNode2,
                             WithColor: NSColor = NSColor.red, RelativeSize: Double = 1.0,
                             LargestSize: Double = 1.0, IsBox: Bool = true)
    {
        var CitySize = CGFloat(RelativeSize * LargestSize)
        if CitySize < 0.33
        {
            CitySize = 0.33
        }
        var HDim = CitySize * 0.1
        if HDim < 0.25
        {
            HDim = 0.25
        }
        var CityNode = SCNNode2()
        if IsBox
        {
            let CityShape = SCNBox(width: HDim, height: CitySize, length: HDim, chamferRadius: 0.02)
            CityNode = SCNNode2(geometry: CityShape)
            let SideImage = MakeOutlineCubeTexture(With: WithColor)
            CityNode.geometry?.materials.removeAll()
            CityNode.geometry?.materials.append(SideImage)
            CityNode.geometry?.materials.append(SideImage)
            CityNode.geometry?.materials.append(SideImage)
            CityNode.geometry?.materials.append(SideImage)
            CityNode.geometry?.materials.append(SideImage)
            CityNode.geometry?.materials.append(SideImage)
            if Settings.GetBool(.CityNodesGlow)
            {
                for Material in CityNode.geometry!.materials
                {
                    Material.selfIllumination.contents = WithColor
                }
            }
        }
        else
        {
            let CityShape = SCNCylinder(radius: HDim / 2.0, height: CitySize)
            CityNode.geometry?.firstMaterial?.diffuse.contents = WithColor
            CityNode = SCNNode2(geometry: CityShape)
            #if false
            if Settings.GetBool(.CityNodesGlow)
            {
                //CityNode.geometry?.firstMaterial?.selfIllumination.contents = WithColor
            }
            #endif
            CityNode.SetLocation(Latitude, Longitude)
            CityNode.CanSwitchState = true
            CityNode.SetState(ForDay: true, Color: WithColor, Emission: nil, Model: .physicallyBased, Metalness: 1.0, Roughness: 0.7)
            CityNode.SetState(ForDay: false, Color: WithColor, Emission: WithColor, Model: .physicallyBased, Metalness: 1.0, Roughness: 0.7)
            CityNode.IsInDaylight = Solar.IsInDaylight(Latitude, Longitude)!
        }
        CityNode.categoryBitMask = LightMasks3D.MetalSun.rawValue | LightMasks3D.MetalMoon.rawValue
        CityNode.geometry?.firstMaterial?.specular.contents = NSColor.white
//        CityNode.geometry?.firstMaterial?.lightingModel = .physicallyBased
        CityNode.castsShadow = true
//        CityNode.geometry?.firstMaterial?.roughness.contents = NSNumber(value: 0.7)
//        CityNode.geometry?.firstMaterial?.metalness.contents = NSNumber(value: 1.0)
        let (X, Y, Z) = ToECEF(Latitude, Longitude, Radius: Radius + Double(CitySize / 2.0))
        CityNode.position = SCNVector3(X, Y, Z)
        CityNode.name = GlobeNodeNames.CityNode.rawValue
        let YRotation = Latitude + 90.0
        let XRotation = Longitude + 180.0
        CityNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, 0.0)
        ToSurface.addChildNode(CityNode)
        PlottedCities.append(CityNode)
    }
    
    /// Plot the city as its name.
    /// - Parameter SomeCity: The city whose name will be plotted.
    /// - Parameter Radius: The radius of the sphere upon which to plot the name.
    /// - Parameter ToSurface: Where to plot the city (eg, which node).
    /// - Parameter WithColor: The color to use for the diffuse surface of the text.
    func PlotCityName(_ SomeCity: City2, Radius: Double, ToSurface: SCNNode2, WithColor: NSColor)
    {
        let Font = Settings.GetFont(.CityFontName, StoredFont("Arial", 24.0, NSColor.black))
        let TheFont = NSFont(name: Font.PostscriptName, size: 24.0)
        let Letters = Utility.MakeFloatingWord(Radius: Radius, Word: "• " + SomeCity.Name,
                                               Scale: NodeScales3D.CityNameScale.rawValue,
                                               Latitude: SomeCity.Latitude, Longitude: SomeCity.Longitude,
                                               Extrusion: 1.0, Mask: LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue,
                                               TextFont: TheFont, TextColor: WithColor, OnSurface: EarthNode!,
                                               WithTag: GlobeNodeNames.CityNode.rawValue)
        for Letter in Letters
        {
            Letter.NodeID = SomeCity.CityID
            Letter.NodeClass = UUID(uuidString: NodeClasses.City.rawValue)!
            PlottedCities.append(Letter)
        }
    }
    
    /// Plot cities and locations on the Earth.
    /// - Parameter On: The main sphere node upon which to plot cities.
    /// - Parameter WithRadius: The radius of there Earth sphere node.
    func PlotLocations(On: SCNNode, WithRadius: CGFloat)
    {
        PlotPolarShape()
        PlotHomeLocation()
        PlotCities()
        PlotWorldHeritageSites()
    }
    
    /// Plot cities on the globe.
    func PlotCities()
    {
        PlotCities(On: EarthNode!, Radius: Double(GlobeRadius.Primary.rawValue))
        PlotHomeLocation()
    }
    
    /// Plot cities on the globe. User locations are also plotted here.
    /// - Parameter On: The node on which to plot cities.
    /// - Parameter Radius: The radius of the node on which to plot cities.
    func PlotCities(On Surface: SCNNode2, Radius: Double)
    {
        for AlreadyPlotted in PlottedCities
        {
            AlreadyPlotted!.removeFromParentNode()
        }
        PlottedCities.removeAll()
        CitiesToPlot = CityManager.FilteredCities()
        
        if Settings.GetBool(.ShowUserLocations)
        {
            for SomePOI in MainController.UserPOIs
            {
                NodeTables.AddUserPOI(ID: SomePOI.ID,
                                      Name: SomePOI.Name,
                                      Location: GeoPoint(SomePOI.Latitude, SomePOI.Longitude))
                let ToPlot = City2(From: SomePOI)
                let ShowEmission = Settings.GetBool(.ShowPOIEmission)
                PlotLocationAsCone(ToPlot,
                                   Latitude: ToPlot.Latitude,
                                   Longitude: ToPlot.Longitude,
                                   Radius: Radius,
                                   ToSurface: Surface,
                                   WithColor: ToPlot.CityColor,
                                   EnableEmission: ShowEmission,
                                   NodeID: SomePOI.ID,
                                   NodeClass: UUID(uuidString: NodeClasses.UserPOI.rawValue)!)
            }
        }
        
        let UseMetro = Settings.GetEnum(ForKey: .PopulationType, EnumType: PopulationTypes.self, Default: .Metropolitan) == .Metropolitan
        let (Max, Min) = CityManager.GetPopulationsIn(CityList: CitiesToPlot, UseMetroPopulation: UseMetro)
        for City in CitiesToPlot
        {
            if City.IsUserCity
            {
                continue
            }
            else
            {
                var RelativeSize: Double = 1.0
                if let ThePopulation = GetCityPopulation2(From: City)
                {
                    RelativeSize = Double(ThePopulation) / Double(Max)
                }
                else
                {
                    RelativeSize = Double(Min) / Double(Max)
                }
                var CityColor = CityManager.ColorForCity(City)
                if Settings.GetBool(.ShowCapitalCities) && City.IsCapital
                {
                    CityColor = Settings.GetColor(.CapitalCityColor, NSColor.systemYellow)
                }
                if Settings.GetBool(.ShowCitiesByPopulation)
                {
                    CityColor = Settings.GetColor(.PopulationColor, NSColor.Sunglow)
                }
                switch Settings.GetEnum(ForKey: .CityShapes, EnumType: CityDisplayTypes.self, Default: .UniformEmbedded)
                {
                    case .UniformEmbedded:
                        PlotEmbeddedCitySphere(City, Latitude: City.Latitude, Longitude: City.Longitude, Radius: Radius,
                                               ToSurface: Surface, WithColor: CityColor, RelativeSize: 1.0,
                                               LargestSize: 0.15)
                        
                    case .RelativeEmbedded:
                        PlotEmbeddedCitySphere(City, Latitude: City.Latitude, Longitude: City.Longitude, Radius: Radius,
                                               ToSurface: Surface, WithColor: CityColor, RelativeSize: RelativeSize,
                                               LargestSize: 0.35)
                        
                    case .RelativeFloatingSpheres:
                        PlotFloatingCity(City, Latitude: City.Latitude, Longitude: City.Longitude, Radius: Radius,
                                         ToSurface: Surface, WithColor: CityColor, RelativeSize: RelativeSize,
                                         RelativeHeight: RelativeSize, LargestSize: 0.5, LongestStem: 2.0,
                                         IsASphere: true)
                        
                    case .RelativeFloatingBoxes:
                        PlotFloatingCity(City, Latitude: City.Latitude, Longitude: City.Longitude, Radius: Radius,
                                         ToSurface: Surface, WithColor: CityColor, RelativeSize: RelativeSize,
                                         RelativeHeight: RelativeSize, LargestSize: 0.5, LongestStem: 2.0,
                                         IsASphere: false)
                        
                    case .RelativeHeight:
                        PlotSimpleCityShape(City, Latitude: City.Latitude, Longitude: City.Longitude, Radius: Radius,
                                            ToSurface: Surface, WithColor: CityColor, RelativeSize: RelativeSize,
                                            LargestSize: 2.0, IsBox: true)
                        
                    case .Cylinders:
                        PlotSimpleCityShape(City, Latitude: City.Latitude, Longitude: City.Longitude, Radius: Radius,
                                            ToSurface: Surface, WithColor: CityColor, RelativeSize: RelativeSize,
                                            LargestSize: 2.0, IsBox: false)
                        
                    case .Pyramids:
                        PlotPyramidCity(City, Latitude: City.Latitude, Longitude: City.Longitude, Radius: Radius,
                                        ToSurface: Surface, WithColor: CityColor, RelativeSize: RelativeSize,
                                        LargestSize: 2.0)
                        
                    case .Names:
                        PlotCityName(City, Radius: Double(GlobeRadius.CityNames.rawValue),
                                     ToSurface: Surface, WithColor: CityColor)
                }
            }
        }
    }
    
    /// Plot polar flags. Intended to be used by callers outside of `GlobeView`.
    func PlotPolarShape()
    {
        NorthPoleFlag?.removeFromParentNode()
        NorthPoleFlag = nil
        SouthPoleFlag?.removeFromParentNode()
        SouthPoleFlag = nil
        NorthPolePole?.removeFromParentNode()
        NorthPolePole = nil
        SouthPolePole?.removeFromParentNode()
        SouthPolePole = nil
        switch Settings.GetEnum(ForKey: .PolarShape, EnumType: PolarShapes.self, Default: .None)
        {
            case .Pole:
                PlotPolarPoles(On: EarthNode!, With: GlobeRadius.Primary.rawValue)
                
            case .Flag:
                PlotPolarFlags(On: EarthNode!, With: GlobeRadius.Primary.rawValue)
                
            case .None:
                return
        }
    }
    
    /// Plot flags on the north and south poles.
    /// - Parameter On: The parent surface where the flags will be plotted.
    /// - Parameter With: The radius of the surface.
    func PlotPolarFlags(On Surface: SCNNode, With Radius: CGFloat)
    {
        let (NorthX, NorthY, NorthZ) = ToECEF(90.0, 0.0, Radius: Double(Radius))
        let (SouthX, SouthY, SouthZ) = ToECEF(-90.0, 0.0, Radius: Double(Radius))
        NorthPoleFlag = MakeFlag(NorthPole: true)
        NorthPoleFlag?.NodeID = NodeTables.NorthPoleID
        NorthPoleFlag?.NodeClass = UUID(uuidString: NodeClasses.Miscellaneous.rawValue)!
        SouthPoleFlag = MakeFlag(NorthPole: false)
        SouthPoleFlag?.NodeID = NodeTables.SouthPoleID
        SouthPoleFlag?.NodeClass = UUID(uuidString: NodeClasses.Miscellaneous.rawValue)!
        NorthPoleFlag?.position = SCNVector3(NorthX, NorthY, NorthZ)
        SouthPoleFlag?.position = SCNVector3(SouthX, SouthY, SouthZ)
        Surface.addChildNode(NorthPoleFlag!)
        Surface.addChildNode(SouthPoleFlag!)
    }
    
    /// Plot festive poles on the north and south poles.
    /// - Parameter On: The parent surface where the flags will be plotted.
    /// - Parameter With: The radius of the surface.
    func PlotPolarPoles(On Surface: SCNNode, With Radius: CGFloat)
    {
        let (NorthX, NorthY, NorthZ) = ToECEF(90.0, 0.0, Radius: Double(Radius))
        let (SouthX, SouthY, SouthZ) = ToECEF(-90.0, 0.0, Radius: Double(Radius))
        NorthPolePole = MakePole(NorthPole: true)
        SouthPolePole = MakePole(NorthPole: false)
        NorthPolePole?.position = SCNVector3(NorthX, NorthY, NorthZ)
        SouthPolePole?.position = SCNVector3(SouthX, SouthY, SouthZ)
        Surface.addChildNode(NorthPolePole!)
        Surface.addChildNode(SouthPolePole!)
    }
    
    /// Create a pole shape for the north or south pole.
    /// - Parameter NorthPole: Determines if the pole is for the North or South Pole.
    /// - Returns: Node with the pole shape.
    func MakePole(NorthPole: Bool) -> SCNNode2
    {
        let Globe: ShapeAttributes =
            {
               let A = ShapeAttributes()
                A.AttributesChange = false
                A.CastsShadow = true
                A.Class = UUID(uuidString: NodeClasses.Miscellaneous.rawValue)!
                A.ID = NorthPole ? NodeTables.NorthPoleID : NodeTables.SouthPoleID
                A.DiffuseColor = NSColor(HexString: "#ffd700")!
                A.Metalness = 1.0
                A.Roughness = 0.6
                A.LightingModel = .physicallyBased
                A.DiffuseType = .Color
                A.Latitude = NorthPole ? 90.0 : -90.0
                A.Longitude = 0.0
                A.ShowBoundingShapes = true
                A.LightMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                A.Position = SCNVector3(0.0, NorthPole ? 2.1 : -2.1, 0.0)
                let Size: Sizes =
                    {
                       let S = Sizes()
                        S.Radius = 0.5
                        return S
                    }()
                A.ShapeSize = Size
                return A
            }()
        let Pole: ShapeAttributes =
            {
                let A = ShapeAttributes()
                A.AttributesChange = false
                A.CastsShadow = true
                A.Class = UUID(uuidString: NodeClasses.Miscellaneous.rawValue)!
                A.ID = NorthPole ? NodeTables.NorthPoleID : NodeTables.SouthPoleID
                A.DiffuseMaterial = "PolarTexture"
                A.DiffuseType = .Image
                A.Latitude = NorthPole ? 90.0 : -90.0
                A.Longitude = 0.0
                A.ShowBoundingShapes = true
                A.LightMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
                A.Position = SCNVector3(0.0, NorthPole ? 0.5 : -0.5, 0.0)
                let Size: Sizes =
                    {
                        let S = Sizes()
                        S.Radius = 0.25
                        S.Height = 2.5
                        return S
                    }()
                A.ShapeSize = Size
                return A
            }()
        let Comp = CompositeComponents()
        Comp.Attributes[.Cylinder] = Pole
        Comp.Attributes[.Sphere] = Globe
        let BaseAttributes: ShapeAttributes =
            {
               let A = ShapeAttributes()
                A.CastsShadow = true
                A.Class = UUID(uuidString: NodeClasses.Miscellaneous.rawValue)!
                A.ID = NorthPole ? NodeTables.NorthPoleID : NodeTables.SouthPoleID
                A.Latitude = NorthPole ? 90.0 : -90.0
                A.Longitude = 0.0
                A.ShowBoundingShapes = true
                return A
            }()
        let Base = BaseAttributes
        let FinalNode = ShapeManager.Create(.Pole, Composite: Comp, BaseAttributes: Base)
        return FinalNode
    }
    
    /// Create a flag shape for either the north or south pole.
    /// - Parameter NorthPole: If true, the North Pole flag is created. If false, the South Pole
    ///                        flag is created.
    /// - Returns: `SCNNode` with the proper shapes and textures and oriented correctly for the globe.
    func MakeFlag(NorthPole: Bool) -> SCNNode2
    {
        let Pole = SCNCylinder(radius: 0.04, height: 2.5)
        let PoleNode = SCNNode2(geometry: Pole)
        PoleNode.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        PoleNode.geometry?.firstMaterial?.diffuse.contents = NSColor.brown
        
        let FlagFace = SCNBox(width: 0.04, height: 0.6, length: 1.2, chamferRadius: 0.0)
        let FlagFaceNode = SCNNode(geometry: FlagFace)
        FlagFaceNode.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        let XOffset = NorthPole ? 0.6 : -0.6
        let YOffset = NorthPole ? 1.0 : -1.0
        FlagFaceNode.position = SCNVector3(XOffset, YOffset, 0.0)
        var FlagName = ""
        if Settings.GetEnum(ForKey: .Script, EnumType: Scripts.self, Default: .English) == .English
        {
            FlagName = NorthPole ? "NorthPoleFlag" : "SouthPoleFlag"
        }
        else
        {
            FlagName = NorthPole ? "NorthPoleFlagJP" : "SouthPoleFlagJP"
        }
        let FlagImage = NSImage(named: FlagName)
        FlagFaceNode.geometry?.firstMaterial?.diffuse.contents = FlagImage
        FlagFaceNode.geometry?.firstMaterial?.specular.contents = NSColor.white
        FlagFaceNode.geometry?.firstMaterial?.lightingModel = .lambert
        FlagFaceNode.eulerAngles = SCNVector3(0.0, 90.0.Radians, 0.0)
        
        let FlagNode = SCNNode2()
        FlagNode.NodeID = NorthPole ? NodeTables.NorthPoleID : NodeTables.SouthPoleID
        FlagNode.NodeClass = UUID(uuidString: NodeClasses.Miscellaneous.rawValue)!
        FlagNode.castsShadow = true
        FlagNode.addChildNode(PoleNode)
        FlagNode.addChildNode(FlagFaceNode)
        return FlagNode
    }
    
    /// Plot World Heritage Sites. Which sites (and whether they are plotted or not) are determined
    /// by user settings.
    /// - Note: There are a lot of World Heritage Sites so plotting all of them can adversely affect
    ///         performance. World Heritage Sites are plotted as extruded triangles to help reduce
    ///         performance issues.
    func PlotWorldHeritageSites()
    {
        for Node in WHSNodeList
        {
            Node?.removeFromParentNode()
        }
        WHSNodeList.removeAll()
        if Settings.GetBool(.ShowWorldHeritageSites)
        {
            if Settings.GetBool(.PlotSitesAs2D)
            {
                return
            }
            let TypeFilter = Settings.GetEnum(ForKey: .WorldHeritageSiteType, EnumType: SiteTypeFilters.self, Default: .Either)
            MainController.InitializeMappableDatabase()
            let Sites = MainController.GetAllSites()
            var FinalList = [WorldHeritageSite2]()
            for Site in Sites
            {
                switch TypeFilter
                {
                    case .Either:
                        FinalList.append(Site)
                        
                    case .Both:
                        if Site.Category == "Mixed"
                        {
                            FinalList.append(Site)
                        }
                        
                    case .Natural:
                        if Site.Category == "Natural"
                        {
                            FinalList.append(Site)
                        }
                        
                    case .Cultural:
                        if Site.Category == "Cultural"
                        {
                            FinalList.append(Site)
                        }
                }
            }
            for Site in FinalList
            {
                let (X, Y, Z) = ToECEF(Site.Latitude, Site.Longitude,
                                       Radius: Double(GlobeRadius.Primary.rawValue))
                var DepthOffset: CGFloat = 0.0
                switch Site.Category
                {
                    case "Mixed":
                        DepthOffset = -0.05
                        
                    case "Cultural":
                        DepthOffset = 0.0
                        
                    case "Natural":
                        DepthOffset = 0.05
                        
                    default:
                        DepthOffset = -0.08
                }
                var NodeColor = NSColor.black
                switch Site.Category
                {
                    case "Mixed":
                        NodeColor = NSColor.magenta
                        
                    case "Natural":
                        NodeColor = NSColor.green
                        
                    case "Cultural":
                        NodeColor = NSColor.red
                        
                    default:
                        NodeColor = NSColor.white
                }
                let Attributes: ShapeAttributes =
                {
                    let A = ShapeAttributes()
                    let PolySize: Sizes =
                        {
                            let S = Sizes()
                            S.VertexCount = 3
                            S.Radius = 0.2
                            S.Depth = 0.1 + Double(DepthOffset)
                            return S
                        }()
                    A.ShapeSize = PolySize
                    A.AttributesChange = false
                    A.CastsShadow = true
                    A.Class = UUID(uuidString: NodeClasses.WorldHeritageSite.rawValue)!
                    A.ID = Site.RuntimeID
                    A.ShowBoundingShapes = true
                    A.ShowBoundingShape = .Sphere
                    A.DiffuseColor = NodeColor
                    A.Latitude = Site.Latitude
                    A.Longitude = Site.Longitude
                    A.Position = SCNVector3(X, Y, Z)
                    A.Scale = Double(NodeScales3D.UnescoScale.rawValue)
                    A.EulerX = Site.Latitude.Radians
                    A.EulerY = (Site.Longitude + 180.0).Radians
                    A.AttributesChange = true
                    let Day: TimeState =
                        {
                            let D = TimeState()
                            D.Color = NodeColor
                            D.Emission = nil
                            D.IsDayState = true
                            return D
                        }()
                    A.DayState = Day
                    let Night: TimeState =
                        {
                           let N = TimeState()
                            N.Color = NodeColor
                            N.Emission = NodeColor
                            N.IsDayState = false
                            return N
                        }()
                    A.NightState = Night
                    return A
                }()
                let SiteNode = ShapeManager.Create(.Polygon, Attributes: Attributes)
                EarthNode!.addChildNode(SiteNode)
            }
        }
    }
    
    /// Returns the largest of the city population or the metropolitan population from the passed city.
    /// - Parameter City: The city whose population is returned.
    /// - Returns: The largest of the city or the metropolitan populations. Nil if no populations
    ///            are available.
    func GetCityPopulation2(From: City2) -> Int?
    {
        if Settings.GetEnum(ForKey: .PopulationType, EnumType: PopulationTypes.self, Default: .Metropolitan) == .Metropolitan
        {
            if let Metro = From.MetropolitanPopulation
            {
                return Metro
            }
            if let CityPop = From.Population
            {
                return CityPop
            }
            return nil
        }
        if let CityPop = From.Population
        {
            return CityPop
        }
        if let Metro = From.MetropolitanPopulation
        {
            return Metro
        }
        return nil
    }
    
    /// Convert the passed latitude and longitude values into a 3D coordinate that can be plotted
    /// on a sphere.
    /// - Note: See [How to map latitude and logitude to a 3D sphere](https://stackoverflow.com/questions/36369734/how-to-map-latitude-and-longitude-to-a-3d-sphere)
    /// - Parameter Latitude: The latitude portion of the 2D coordinate.
    /// - Parameter Longitude: The longitude portion of the 2D coordinate.
    /// - Parameter Radius: The radius of the sphere.
    /// - Returns: Tuple with the X, Y, and Z coordinates for the location on the sphere.
    func ToECEF(_ Latitude: Double, _ Longitude: Double, Radius: Double) -> (Double, Double, Double)
    {
        let Lat = (90 - Latitude).Radians
        let Lon = (90 + Longitude).Radians
        let X = -(Radius * sin(Lat) * cos(Lon))
        let Z = (Radius * sin(Lat) * sin(Lon))
        let Y = (Radius * cos(Lat))
        return (X, Y, Z)
    }
    
    /// Changes the color of the `diffuse` material on the passed `SCNNode` to a specified color over
    /// the specified length of time.
    /// - Note: See [How to add animations to change SCNNode's color](https://stackoverflow.com/questions/40472524/how-to-add-animations-to-change-sncnodes-color-scenekit/40473393)
    /// - Note: If the passed `SCNNode` has no `geometry` or `firstMaterial`, control returns immediately.
    /// - Parameter On: The node whose `diffuse` material will change colors.
    /// - Parameter From: Original color of the node. This function assumes the node's `diffuse` value
    ///                   is this color already. If not, a strange animation will occur.
    /// - Parameter To: The target color to change the node's `diffuse` value to. If `From` is equal
    ///                 to `To`, no action is taken.
    /// - Parameter Duration: Duration of the color animation.
    /// - Parameter Delay: Number of seconds to delay the color animation. Defaults to 0.0.
    func ChangeColor(On Node: SCNNode, From: NSColor, To: NSColor, Duration: Double, Delay: Double = 0.0)
    {
        if Node.geometry == nil
        {
            return
        }
        if Node.geometry!.firstMaterial == nil
        {
            return
        }
        let RDelta = From.r - To.r
        let GDelta = From.g - To.g
        let BDelta = From.b - To.b
        if RDelta == 0 && GDelta == 0 && BDelta == 0
        {
            //Nothing to do...
            return
        }
        let ColorChange = SCNAction.customAction(duration: Duration, action:
                                                    {
                                                        (TheNode, Time) in
                                                        let Percent: CGFloat = Time / CGFloat(Duration)
                                                        var Red = From.r + (RDelta * Percent)
                                                        if RDelta < 0.0
                                                        {
                                                            Red = abs(Red)
                                                        }
                                                        var Green = From.g + (GDelta * Percent)
                                                        if GDelta < 0.0
                                                        {
                                                            Green = abs(Green)
                                                        }
                                                        var Blue = From.b + (BDelta * Percent)
                                                        if BDelta < 0.0
                                                        {
                                                            Blue = abs(Blue)
                                                        }
                                                        TheNode.geometry?.firstMaterial?.diffuse.contents = NSColor(calibratedRed: Red, green: Green, blue: Blue, alpha: 1.0)
                                                    }
        )
        let Wait = SCNAction.wait(duration: Delay)
        let Sequence = SCNAction.sequence([Wait, ColorChange])
        Node.runAction(Sequence)
    }
}