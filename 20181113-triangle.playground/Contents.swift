/***
 * References
 * Metal by Tutorials, Chapter 1: Hello Metal!
 * Rendering Graphics with MetalKit + Swift 4 (Part 1)
 *   https://www.clientresourcesinc.com/2018/04/30/rendering-graphics-with-metalkit-swift-4-part-1/
 */

import Cocoa
import PlaygroundSupport
import MetalKit

var str = "Hello, playground"

guard let device = MTLCreateSystemDefaultDevice() else {
    fatalError("GPU is not supported")
}

let frame = CGRect(x: 0, y: 0, width: 600, height: 600)
let view = MTKView(frame: frame, device: device)
view.clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)

// Create command queue
guard let commandQueue = device.makeCommandQueue() else {
    fatalError("Could not create a command queue")
}

let shader = """
#include <metal_stdlib>
using namespace metal;

struct VertexIn {
  float2 position;
};

vertex float4 vs(const device VertexIn *vertices [[ buffer(0) ]], uint vertexID [[ vertex_id ]]) {
  return float4(vertices[vertexID].position, 0, 1);
}

fragment float4 fs() {
  return float4(1, 0, 0, 1);
}
"""

// Create pipeline state

let library = try device.makeLibrary(source: shader, options: nil)
let vs = library.makeFunction(name: "vs")
let fs = library.makeFunction(name: "fs")

let descriptor = MTLRenderPipelineDescriptor()
descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
descriptor.vertexFunction   = vs
descriptor.fragmentFunction = fs
let pipelineState = try device.makeRenderPipelineState(descriptor: descriptor)

// Create buffers
let vertices: [float2] = [ float2(0.2, 0.2), float2(0.8, 0), float2(0.8, 0.8) ];
let vertexBuffer = device.makeBuffer(bytes: vertices, length: 3, options: [])

guard let commandBuffer = commandQueue.makeCommandBuffer(),
let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: view.currentRenderPassDescriptor!)
    else { fatalError() }
renderEncoder.setRenderPipelineState(pipelineState)
renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
renderEncoder.endEncoding()

guard let drawable = view.currentDrawable else {
    fatalError()
}
commandBuffer.present(drawable)
commandBuffer.commit()

PlaygroundPage.current.liveView = view
