// Chapter 1: Hello Metal! from Metal by Tutorials

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

let allocator = MTKMeshBufferAllocator(device: device)
let mdlMesh = MDLMesh(sphereWithExtent: [0.75, 0.75, 0.75], segments: [100, 100], inwardNormals: false, geometryType: .triangles, allocator: allocator)
let mesh = try MTKMesh(mesh: mdlMesh, device: device)

guard let commandQueue = device.makeCommandQueue() else {
    fatalError("Could not create a command queue")
}

let shader = """
#include <metal_stdlib>
using namespace metal;

struct VertexIn {
  float4 position [[ attribute(0) ]];
};

vertex float4 vs(const VertexIn vertex_in [[stage_in ]]) {
  return vertex_in.position;
}

fragment float4 fs() {
  return float4(1, 0, 0, 1);
}
"""

let library = try device.makeLibrary(source: shader, options: nil)
let vs = library.makeFunction(name: "vs")
let fs = library.makeFunction(name: "fs")

let descriptor = MTLRenderPipelineDescriptor()
descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
descriptor.vertexFunction = vs
descriptor.fragmentFunction = fs
descriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)

let pipelineState = try device.makeRenderPipelineState(descriptor: descriptor)

guard let commandBuffer = commandQueue.makeCommandBuffer(),
let descriptor = view.currentRenderPassDescriptor,
let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
    else { fatalError() }

renderEncoder.setRenderPipelineState(pipelineState)
renderEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)

guard let submesh = mesh.submeshes.first else {
    fatalError()
}

renderEncoder.drawIndexedPrimitives(type: .triangle,
                                    indexCount:  submesh.indexCount,
                                    indexType:   submesh.indexType,
                                    indexBuffer: submesh.indexBuffer.buffer,
                                    indexBufferOffset: 0)
renderEncoder.endEncoding()

guard let drawable = view.currentDrawable else {
    fatalError()
}
commandBuffer.present(drawable)
commandBuffer.commit()

PlaygroundPage.current.liveView = view
