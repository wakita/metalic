import MetalKit

let device = MTLCreateSystemDefaultDevice()!
let commandQueue = device.makeCommandQueue()!
let library = try device.makeLibrary(filepath: "compute.metallib")

let commandBuffer = commandQueue.makeCommandBuffer()!
let encoder = commandBuffer.makeComputeCommandEncoder()!
encoder.setComputePipelineState(try device.makeComputePipelineState(function: library.makeFunction(name: "add")!))

let input: [Float] = [1.0, 2.0]
encoder.setBuffer(device.makeBuffer(bytes: input as [Float], length: MemoryLayout<Float>.stride * input.count, options: []),
                  offset: 0, index: 0)
let outputBuffer = device.makeBuffer(length: MemoryLayout<Float>.stride, options: [])!
encoder.setBuffer(outputBuffer, offset: 0, index: 1)

let numThreadgroups = MTLSize(width: 1, height: 1, depth: 1)
let threadsPerThreadgroup = MTLSize(width: 1, height: 1, depth: 1)
encoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerThreadgroup)
encoder.endEncoding()

commandBuffer.commit()
commandBuffer.waitUntilCompleted()

let result = outputBuffer.contents().load(as: Float.self)
print(String(format: "%f + %f = %f", input[0], input[1], result))
