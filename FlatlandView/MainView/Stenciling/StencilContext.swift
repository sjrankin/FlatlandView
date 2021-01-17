//
//  StencilContext.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/17/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Context data for rendering stencils on a map.
class StencilContext
{
    /// Image used as the background image.
    var BackgroundImage: NSImage? = nil
    
    /// The image rendered as the quake magnitude layer.
    var QuakeLayer: NSImage? = nil
    
    /// Number of seconds used to render earthquake magnitude layer.
    var QuakeRenderDuration: Double = 0.0
    
    /// The image rendered as the region layer.
    var RegionLayer: NSImage? = nil
    
    /// Number of seconds used to render the region layer.
    var RegionRenderDuration: Double = 0.0
    
    /// The image rendered as the grid layer.
    var GridLayer: NSImage? = nil
    
    /// Number of seconds used to render the grid layer.
    var GridRenderDuration: Double = 0.0
    
    /// The image rendered as the name layer.
    var NameLayer: NSImage? = nil
    
    /// Number of seconds used to render the name layer.
    var NameRenderDuration: Double = 0.0
    
    /// Total number of seconds used to render the pipeline.
    var PipelineRenderDuration: Double = 0.0
    
    /// Callback for render completion.
    var Callback: StencilPipelineProtocol? = nil
    
    /// Final rendered image. If nil, no image available.
    var CompletedImage: NSImage? = nil
    
    /// Current image. May not be complete if not all stages are completed.
    var WorkingImage: NSImage? = nil
}
