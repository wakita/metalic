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
    //float4 __ignored__ [[ attribute(0) ]];
};
struct VS_Out {
    float4 position [[ position ]];
    float3 color;
    float pointsize [[ point_size ]];
    float edgeFraction [[ flat ]];
};

vertex VS_Out vs(uint id [[ vertex_id ]],
                 constant Uniforms &U [[ buffer(1) ]]) {
    VS_Out output;
    
    output.color = float3(id / U.N / U.N, id / U.N % U.N, id % U.N) / (U.N - 1);
    float4 p_mv = U.View * U.Model * float4(output.color * 2 - 1, 1);
    output.position = U.Projection * p_mv;
    output.pointsize = U.FrameSize / U.N / 2 / (p_mv.z);
    output.edgeFraction = (0.5 * (U.N - 1)) / U.N;
    return output;
}

typedef VS_Out FS_In;
typedef float4 FS_Out;

#define A 0.7

fragment FS_Out fs(FS_In  in [[ stage_in ]],
                   float2 xy [[point_coord]]) {
    float  l = length(xy - float2(0.5));
    float3 c = float3((0.5 - l) * 2 * (1 - A) + in.color * A);
    return float4(c, 1.0 - smoothstep(in.edgeFraction, 0.5, l));
}
