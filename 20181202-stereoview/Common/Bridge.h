//
//  Bridge.h
//  StereoView
//
//  Created by Ken Wakita on 2018/12/02.
//

#ifndef Bridge_h
#define Bridge_h

#import <simd/simd.h>

// static const uint UNIFORMS_BP = 0;

enum {
    VERTEX_INDEX = 0,
    UNIFORMS_INDEX = 1
};

typedef struct {
    int N;
    matrix_float4x4 Model;
    matrix_float4x4 View;
    matrix_float4x4 Projection;
    matrix_float4x4 PostProjection;
    int DrawableWidth;
    int DrawableHeight;
    int Left;
} Uniforms;

#endif /* Bridge_h */
