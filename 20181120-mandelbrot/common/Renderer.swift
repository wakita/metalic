//
//  Renderer.swift
//  20181115-Mandelbrot
//
//  Created by Ken Wakita on 2018/11/13.
//  Copyright © 2018 Ken Wakita. All rights reserved.
//

import MetalKit

struct Vertex {
    var position: float2
    var complex: float2
}

class Renderer: NSObject {
    var commandQueue: MTLCommandQueue!
    var renderPipelineState: MTLRenderPipelineState!
    var vertexBuffer: MTLBuffer!
    var vertices: [Vertex] = [
        Vertex(position: float2(-1, -1), complex: float2(-2, -2)),
        Vertex(position: float2( 1, -1), complex: float2( 2, -2)),
        Vertex(position: float2(-1,  1), complex: float2(-2,  2)),
        Vertex(position: float2( 1,  1), complex: float2( 2,  2))
    ]
    
    init(device: MTLDevice) {
        super.init()
        createCommandQueue(device: device)
        createPipelineState(device: device)
        createBuffers(device: device)
    }
    
    func createCommandQueue(device: MTLDevice) {
        commandQueue = device.makeCommandQueue()
    }
    
    func createPipelineState(device: MTLDevice) {
        let library = device.makeDefaultLibrary()
        let descriptor = MTLRenderPipelineDescriptor()
        guard let colorAttachment = descriptor.colorAttachments[0] else { return }
        colorAttachment.pixelFormat = .bgra8Unorm
        descriptor.vertexFunction   = library?.makeFunction(name: "vs")
        descriptor.fragmentFunction = library?.makeFunction(name: "fs")
        do {
            renderPipelineState = try device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func createBuffers(device: MTLDevice) {
        vertexBuffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<Vertex>.stride * vertices.count, options: [])
    }
    
    var frameSize = float2(0, 0)
    
    /// Point of interest
    var poi = float2(0, 0)
    
    /// Complex field
    var C = float2x2([ float2(-2, -2), float2(2, 2) ])
    
    func setFrameSize(size: CGSize) {
        print(size)
        frameSize = float2(Float(size.width), Float(size.height))
    }
    
    func setTarget(x: Float, y: Float) {
        let C0 = C[0], C1 = C[1]
        let F = frameSize
        let pos = float2(x, y)
        poi.x = ((F.x - pos.x) * C0.x + pos.x * C1.x) / Float(F.x)
        poi.y = ((F.y - pos.y) * C0.y + pos.y * C1.y) / Float(F.y)
    }
}

let α = Float(0.998)
let N = 60

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        setFrameSize(size: view.frame.size)
    }
    
    func setComplexField() {
        let diag0: float2 = C[1] - C[0]
        let diag:  float2 = diag0 * pow(α, Float(N))
        let E = float2x2(poi - diag / 2, poi + diag / 2)
        C = C * (Float(N - 1) / Float(N)) + E * (Float(1) / Float(N))
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
            let renderPassDescriptr = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptr)
            else { return }
        
        setComplexField()

        commandEncoder.setRenderPipelineState(renderPipelineState)
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder.setVertexBytes(&C, length: MemoryLayout<float2x2>.stride, index: 1)
        commandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: vertices.count)
        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
