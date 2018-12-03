import MetalKit

guard let device = MTLCreateSystemDefaultDevice() else { exit(-1) }

// Create command queue
let commandQueue = device.makeCommandQueue()!

// Create Compute pipeline
// var library: MTLLibrary!
let library = try device.makeLibrary(filepath: "compute.metallib")
guard let add = library.makeFunction(name: "add") else { exit(-1) }
let pipelineState = try device.makeComputePipelineState(function: add)

// Create Buffers
let input: [float2] = [float2(1, 2)]
let output: [Float] = [Float(0)]
let outputBuffer = device.makeBuffer(bytes: output, length: MemoryLayout<Float>.stride, options: [])

// Prepare command buffer
guard let commandBuffer = commandQueue.makeCommandBuffer(),
      let encoder = commandBuffer.makeComputeCommandEncoder() else { exit(-1) }
encoder.setComputePipelineState(pipelineState)
encoder.setBuffer(device.makeBuffer(bytes: input, length: MemoryLayout<float2>.stride, options: []), offset: 0, index: 1)
encoder.setBuffer(outputBuffer, offset: 0, index: 2)
let numThreadgroups = MTLSize(width: 1, height: 1, depth: 1)
let threadsPerGroup = MTLSize(width: 1, height: 1, depth: 1)
encoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerGroup)
encoder.endEncoding()

// Dispatch
commandBuffer.commit()
commandBuffer.waitUntilCompleted()

// Read output
let data = Data(bytesNoCopy: outputBuffer!.contents(), count: 1, deallocator: .none)
var result: [Float] = [Float(0)]
result = data.withUnsafeBytes { Array(UnsafeBufferPointer<Float>(start: $0, count: 1)) }
print(String(format: "%f + %f = %f", input[0].x, input[0].y, result[0]))
