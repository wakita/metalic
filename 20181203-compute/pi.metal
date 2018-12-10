#include <metal_stdlib>
using namespace metal;

#include "Loki/Loki/loki_header.metal"

kernel void pi1(device uint *out [[ buffer(1) ]],
                const uint2 id [[ thread_position_in_grid ]]) {
  Loki random = Loki(id.x + 1, id.y + 1, 1);

  uint c = 0;
  for (int i = 0; i < 4000000; i++) {
    float x = random.rand(), y = random.rand();
    if (x * x + y * y < 1) c++;
  }
  out[0] = c;
}
