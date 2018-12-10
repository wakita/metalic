import MetalKit

let device       = MTLCreateSystemDefaultDevice()!
let commandQueue = device.makeCommandQueue()!
let library      = try device.makeLibrary(filepath: "pi.metallib")

let commandBuffer = commandQueue.makeCommandBuffer()!
let encoder       = commandBuffer.makeComputeCommandEncoder()!
encoder.setComputePipelineState(
    try device.makeComputePipelineState(function: library.makeFunction(name: "pi1")!))

let outputBuffer = device.makeBuffer(length: MemoryLayout<UInt>.stride, options: [])!
encoder.setBuffer(outputBuffer, offset: 0, index: 1)

let numThreadgroups       = MTLSize(width: 1, height: 1, depth: 1)
let threadsPerThreadgroup = MTLSize(width: 1, height: 1, depth: 1)
encoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerThreadgroup)
encoder.endEncoding()

/*
commandBuffer.commit()
commandBuffer.waitUntilCompleted()
*/

let pi = outputBuffer.contents().load(as: UInt.self)
print(String(format: "pi: %d", pi))

var c = 0
let range = 0.0 ..< 1.0
for _ in 1 ... 4000000 {
  let x = Double.random(in: range)
  let y = Double.random(in: range)
  if (x * x + y * y < 1) { c = c + 1 }
}
print(c)
