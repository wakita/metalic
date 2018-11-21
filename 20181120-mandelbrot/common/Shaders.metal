//
//  Shaders.metal
//  20181115-Mandelbrot
//
//  Created by Ken Wakita on 2018/11/13.
//  Copyright © 2018 Ken Wakita. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef struct Vertex {
    float2 position;
    //float2 complex;
} VS_In;

typedef struct VS_Out {
    float4 position [[ position ]];
    float2 complex;
} FS_In;

typedef float4 FS_Out;

vertex VS_Out vs(const device VS_In *vertices [[ buffer(0) ]],
                 constant float2x2 &C [[ buffer(1) ]],
                 uint id [[ vertex_id ]]) {
    VS_Out out;
    out.position = float4(vertices[id].position, 0, 1);
    switch (id) {
        case 0: out.complex.xy = C[0]; break;
        case 1: out.complex.xy = float2(C[1].x, C[0].y); break;
        case 2: out.complex.xy = float2(C[0].x, C[1].y); break;
        case 3: out.complex.xy = C[1]; break;
    }
    return out;
}

float4 hsv2rgb(float h, float s, float v) {
    float3 rgb = float3(v, v, v);
    h *= 6;
    int i = (int)h;
    float f = h - i;
    switch (i) {
        case 0:
            rgb.g *= 1 - s * (1 - f);
            rgb.b *= 1 - s;
            break;
        case 1:
            rgb.r *= 1 - s * f;
            rgb.b *= 1 - s;
            break;
        case 2:
            rgb.r *= 1 - s;
            rgb.b *= 1 - s * (1 - f);
            break;
        case 3:
            rgb.r *= 1 - s;
            rgb.g *= 1 - s * f;
            break;
        case 4:
            rgb.r *= 1 - s * (1 - f);
            rgb.g *= 1 - s;
            break;
        case 5:
            rgb.g *= 1 - s;
            rgb.b *= 1 - s * f;
    }
    return float4(rgb, 1);
}

fragment FS_Out fs(FS_In pixel [[ stage_in ]]) {
    const int NCOLOR = 256;

    float2 c = pixel.complex, z = float2(0, 0);
    int n = 0;
    while (n < (NCOLOR - 1) && length(z) <= 2) {
        float2 z1 = float2(z.x * z.x - z.y * z.y + c.x, 2 * z.x * z.y + c.y);
        z = z1;
        n++;
    }
    float v = 1 - (float)n / NCOLOR;
    float h = v > 0.4 ? v - 0.4 : v + 0.6;
    return hsv2rgb(h, 1, v);
}
