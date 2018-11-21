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
}

class Renderer: NSObject {
    var commandQueue: MTLCommandQueue!
    var renderPipelineState: MTLRenderPipelineState!
    var vertexBuffer: MTLBuffer!
    var vertices: [Vertex] = [
        Vertex(position: float2(-1, -1)),
        Vertex(position: float2( 1, -1)),
        Vertex(position: float2(-1,  1)),
        Vertex(position: float2( 1,  1))
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
    
    var frameSize: [FLOAT] = [ 0.0, 0.0 ]
    
    /// Point of interest
    var poi: [FLOAT] = [0.0, 0.0]
    
    /// Complex field
    var C: [FLOAT] = [ -2.0, -2.0, 2.0, 2.0 ]
    
    func setFrameSize(size: CGSize) {
        frameSize = [ f(Double(size.width)), f(Double(size.height)) ]
    }
    
    func setTarget(x: FLOAT, y: FLOAT) {
        let F = frameSize
        let pos = [ x, y ]
        poi[0] = ((F[0] - pos[0]) * C[0] + pos[0] * C[2]) / F[0]
        poi[1] = ((F[1] - pos[1]) * C[1] + pos[1] * C[3]) / F[1]
    }
}

let α = f(0.998)
let N = f(60.0)
let αN = pow(α, N)

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        setFrameSize(size: view.frame.size)
    }
    
    func setComplexField() -> float2x2 {
        let diag = [ (C[2] - C[0]) * αN, (C[3] - C[1]) * αN ]
        let E = [poi[0] - diag[0] / 2, poi[1] - diag[1] / 2,
                 poi[0] + diag[0] / 2, poi[1] + diag[1] / 2 ]
        C[0] = C[0] * (N - 1) / N + E[0] / N
        C[1] = C[1] * (N - 1) / N + E[1] / N
        C[2] = C[2] * (N - 1) / N + E[2] / N
        C[3] = C[3] * (N - 1) / N + E[3] / N
        return float2x2(float2(Float(C[0]), Float(C[1])),
                        float2(Float(C[2]), Float(C[3])))
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
            let renderPassDescriptr = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptr)
            else { return }
        
        var fC = setComplexField()

        commandEncoder.setRenderPipelineState(renderPipelineState)
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder.setVertexBytes(&fC, length: MemoryLayout<float2x2>.stride, index: 1)
        commandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: vertices.count)
        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
