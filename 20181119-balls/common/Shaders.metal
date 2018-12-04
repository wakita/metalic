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

vertex VS_Out vs(uint id [[ vertex_id ]],
                 constant Uniforms &U [[ buffer(UNIFORMS_INDEX) ]]) {
    VS_Out output;
    

    output.color = float3(id / U.N / U.N, id / U.N % U.N, id % U.N) / (U.N - 1);
    float4 p_mv = U.View * U.Model * float4(output.color * 2 - 1, 1);
    output.pointsize = min(U.DrawableWidth, U.DrawableHeight) / U.N / p_mv.z;
    
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
    if       (U.Left && x > U.DrawableWidth / 2 - 1) discard_fragment();
    else if (!U.Left && x < U.DrawableWidth / 2 + 1) discard_fragment();

    float  l = length(xy - float2(0.5));
    float3 c = float3(mix((0.5 - l) * 2, in.color, 0.7));
    if (l > 0.5) discard_fragment();
    return float4(c, 1.0 - smoothstep(in.edgeFraction, 0.5, l));
}
