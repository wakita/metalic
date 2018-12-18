//
//  Shaders.metal
//  20181119-balls
//
//  Created by Ken Wakita on 2018/11/19.
//  Copyright © 2018 Ken Wakita. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#import "Bridge.h"

struct VS_In {
    //float4 __ignored__ [[ attribute(VERTEX_INDEX) ]];
};
struct VS_Out {
    float4 position [[ position ]];
    float3 color;
    float pointsize [[ point_size ]];
    float edgeFraction [[ flat ]];
};

// const device VS_In *vertices [[ buffer(0) ]]

vertex VS_Out vs(
                 const device Vertex *vertices [[ buffer(VERTEX_INDEX) ]],
                 uint id [[ vertex_id ]],
                 constant Uniforms &U [[ buffer(UNIFORMS_INDEX) ]]) {
    VS_Out output;
    
    float3 p = vertices[id].position;
    float4 p_mv = U.View * U.Model * float4(p * 2 - 1, 1);
    output.pointsize = min(U.DrawableWidth, U.DrawableHeight) / 20 / p_mv.z;
    // output.color = float3(p.z > 0 ? 1.0 : 0.8, 0.8, p.z < 0 ? 1.0 : 0.8);
    output.color = p * 0.4 + float3(0.6, 0.6, 0.6);
    
    // output.edgeFraction = (output.pointsize * (U.N - 1)) / U.N; // Bug
    output.edgeFraction = (0.5 * (U.N - 1)) / U.N; // Bug

    output.position = U.PostProjection * U.Projection * p_mv;

    return output;
}

typedef VS_Out FS_In;
typedef float4 FS_Out;

fragment FS_Out fs(FS_In  in [[ stage_in ]],
                   float2 xy [[point_coord]],
                   constant Uniforms &U [[ buffer(UNIFORMS_INDEX) ]]) {
    float x = in.position.x;
    if ((U.Left && x > U.DrawableWidth / 2 - 1) ||
        (!U.Left && x < U.DrawableWidth / 2 + 1)) discard_fragment();

    float  l = length(xy - float2(0.5));
    float3 c = float3(mix((0.5 - l) * 2, in.color, 0.7));
    if (l > 0.5) discard_fragment();
    return float4(c, 1.0 - smoothstep(in.edgeFraction, 0.5, l));
}
