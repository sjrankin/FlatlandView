//
//  File.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

/// Thin wrapper around `SCNNode` that provides a few auxiliary properties for carrying data and ID information.
class SCNNode2: SCNNode
{
    /// Default initializer.
    override init()
    {
        super.init()
    }
    
    /// Initializer.
    /// - Parameter Tag: The tag value.
    init(Tag: Any?)
    {
        super.init()
        self.Tag = Tag
    }
    
    /// Initializer.
    /// - Parameter Tag: The tag value.
    /// - Parameter NodeID: The node's ID. Assumed to be unique.
    /// - Parameter NodeClass: The node class ID. Assumed to be non-unique.
    init(Tag: Any? = nil, NodeID: UUID, NodeClass: UUID)
    {
        super.init()
        self.Tag = Tag
        self.NodeID = NodeID
        self.NodeClass = NodeClass
    }
    
    /// Initializer.
    /// - Parameter geometry: The geometry of the node.
    init(geometry: SCNGeometry?)
    {
        super.init()
        self.geometry = geometry
    }
    
    /// Initializer.
    /// - Parameter geometry: The geometry of the node.
    /// - Parameter Tag: The tag value.
    init(geometry: SCNGeometry?, Tag: Any?)
    {
        super.init()
        self.geometry = geometry
        self.Tag = Tag
    }
    
    /// Initializer.
    /// - Parameter geometry: The geometry of the node.
    /// - Parameter Tag: The tag value.
    /// - Parameter NodeID: The node's ID. Assumed to be unique.
    /// - Parameter NodeClass: The node class ID. Assumed to be non-unique.
    init(geometry: SCNGeometry?, Tag: Any? = nil, NodeID: UUID, NodeClass: UUID)
    {
        super.init()
        self.geometry = geometry
        self.Tag = Tag
        self.NodeID = NodeID
        self.NodeClass = NodeClass
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    /// Initializer.
    /// - Parameter From: The `SCNNode` whose data is used to initialize the `SCNNode2`
    ///                   instance.
    init(From: SCNNode)
    {
        super.init()
        self.geometry = From.geometry
        self.scale = From.scale
        self.position = From.position
        self.eulerAngles = From.eulerAngles
        self.categoryBitMask = From.categoryBitMask
    }
    
    /// Initializer.
    /// - Parameter AsChild: `SCNNode` instance that will be added as a child to the
    ///             `SCNNode2` instance.
    init(AsChild: SCNNode)
    {
        super.init()
        self.addChildNode(AsChild)
    }
    
    /// Tag value. Defaults to nil.
    var Tag: Any? = nil
    
    /// Node class ID. Defaults to nil.
    var NodeClass: UUID? = nil
    
    /// Node ID. Defaults to nil.
    var NodeID: UUID? = nil
    
    /// Propagate the parent's IDs to its children.
    func PropagateIDs()
    {
        for Child in self.childNodes
        {
            if let TheChild = Child as? SCNNode2
            {
                TheChild.NodeClass = NodeClass
                TheChild.NodeID = NodeID
            }
        }
    }
}



