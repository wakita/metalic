//
//  GameViewController.swift
//  Mandelbrot
//
//  Created by Ken Wakita on November 16, 2018.
//  Copyright © 2018 Ken Wakita. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef struct Vertex {
    float2 position;
} VS_In;

struct VS_Out {
    float4 position [[ position ]];
    float2 complex;
};

vertex VS_Out vs(const device VS_In *vertices [[ buffer(0) ]],
                 constant float2x2 &C [[ buffer(1) ]],
                 uint id [[ vertex_id ]]) {
    VS_Out out;
    out.position = float4(vertices[id].position, 0, 1);
    switch (id) {
        case 0: out.complex.xy = C[0].xy; break;
        case 1: out.complex.xy = float2(C[1].x, C[0].y); break;
        case 2: out.complex.xy = float2(C[0].x, C[1].y); break;
        case 3: out.complex.xy = C[1].xy; break;
    }
    return out;
}

typedef VS_Out FS_In;
typedef float4 FS_Out;

fragment FS_Out fs(FS_In in [[ stage_in ]]) {
    const int NCOLOR = 256;

    float2 c = in.complex, z = float2(0, 0);
    int n = 0;
    while (n < (NCOLOR - 1) && length(z) <= 2) {
        float2 z1 = float2(z.x * z.x - z.y * z.y + c.x, 2 * z.x * z.y + c.y);
        z = z1;
        n++;
    }
    if (n == NCOLOR - 1) return float4(0, 0, 0, 0);
    
    float level = 1 - (float)n / NCOLOR;
    return float4(level, 0, level, 1);
}
