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
} FS_In;

typedef float4 FS_Out;

vertex VS_Out vs(const device VS_In *vertices [[ buffer(0) ]],
                 uint vertexID [[ vertex_id ]]) {
    VS_Out out;
    out.position = float4(vertices[vertexID].position, 0, 1);
    return out;
}

fragment FS_Out fs(FS_In pixel [[ stage_in ]], float2 uv [[ point_coord ]]) {
    const int S = 5;
    float x = uv.x * S, y = uv.y * S;
    return float4(x - (int)x, y - (int)y, 0, 1);
}
