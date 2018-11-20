//
//  Shaders.metal
//  20181119-balls
//
//  Created by Ken Wakita on 2018/11/19.
//  Copyright © 2018 Ken Wakita. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VS_In {};
struct VS_Out {
    float4 position [[ position ]];
    float pointsize [[ point_size ]];
};

vertex VS_Out vs(uint id [[ vertex_id ]]) {
    VS_Out output;
    
    float x = id / 10, y = id % 10;
    
    output.position = float4(x / 5 - 0.9, y / 5 - 0.9, 0, 1);
    output.pointsize = 10.0;
    return output;
}

typedef VS_Out FS_In;
typedef float4 FS_Out;

fragment FS_Out fs(FS_In in [[ stage_in ]]) {
    return float4(1, 1, 1, 1);
}
