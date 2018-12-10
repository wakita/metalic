//
//  Bridge.h
//  20181119-balls
//
//  Created by Ken Wakita on 2018/11/25.
//  Copyright © 2018 Ken Wakita. All rights reserved.
//

#ifndef Bridge_h
#define Bridge_h

#import <simd/simd.h>

enum {
    VERTEX_INDEX = 0,
    UNIFORMS_INDEX = 1
};

struct Vertex {
    vector_float3 position;
};

struct Uniforms {
    int N;
    matrix_float4x4 Model;
    matrix_float4x4 View;
    matrix_float4x4 Projection;
    matrix_float4x4 PostProjection;
    int DrawableWidth;
    int DrawableHeight;
    int Left;
};

#endif /* Bridge_h */
