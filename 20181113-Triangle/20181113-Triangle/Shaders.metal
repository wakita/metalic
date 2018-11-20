//
//  Shaders.metal
//  20181113-Triangle
//
//  Created by Ken Wakita on 2018/11/13.
//  Copyright © 2018 Ken Wakita. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef struct Vertex {
    float2 position;
} VS_In;

typedef struct VS_Out {
    float4 position [[ position ]];
    uint id [[ flat ]];
} FS_In;

vertex VS_Out
vs(const device VS_In *vertices [[ buffer(0) ]],
                 uint vertexID [[ vertex_id ]]) {
    VS_Out out;
    out.position = float4(vertices[vertexID].position, 0, 1);
    out.id = vertexID / 3;
    return out;
}

typedef float4 FS_Out;

fragment FS_Out
fs(FS_In pixel [[ stage_in ]], float2 uv [[ point_coord ]]) {
    if (pixel.id % 2 == 1) uv = 1 - uv;
    return float4(uv, 0, 1);
}
