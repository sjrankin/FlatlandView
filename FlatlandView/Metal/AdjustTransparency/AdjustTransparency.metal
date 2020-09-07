//
//  AdjustTransparency.metal
//  Flatland
//
//  Created by Stuart Rankin on 9/5/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct TransparencyParameters0
{
    float Threshold;
};

kernel void AdjustTransparency0(texture2d<float, access::read> Source [[texture(0)]],
                               texture2d<float, access::write> Target [[texture(1)]],
                               constant TransparencyParameters0 &Parameters [[buffer(0)]],
                               uint2 gid [[thread_position_in_grid]])
{
    float4 SourceColor = Source.read(gid);
    if (SourceColor.a < Parameters.Threshold)
        {
        Target.write(float4(0.0, 0.0, 0.0, 0.0), gid);
        }
    else
        {
        SourceColor.a = 1.0;
        Target.write(SourceColor, gid);
        }
}
