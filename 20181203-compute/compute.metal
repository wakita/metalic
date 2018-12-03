#include <metal_stdlib>
using namespace metal;

kernel void add(const device float2 *in [[ buffer(1) ]],
                device float  *out [[ buffer(2) ]],
                uint id [[ thread_position_in_grid ]]) {
  out[id] = in[id].x + in[id].y;
}
