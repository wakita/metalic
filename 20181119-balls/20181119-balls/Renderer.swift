//
//  Renderer.swift
//  20181119-balls
//
//  Created by Ken Wakita on 2018/11/19.
//  Copyright © 2018 Ken Wakita. All rights reserved.
//

import MetalKit

class Renderer: NSObject {
    
    init(device: MTLDevice) {
        super.init()
        createCommandQueue(device: device)
        createPipelineState(device: device)
        createBuffers(device: device)
    }
    
    var commandQueue: MTLCommandQueue!

    func createCommandQueue(device: MTLDevice) {
        commandQueue = device.makeCommandQueue()
    }
    
    var renderPipelineState: MTLRenderPipelineState!

    func createPipelineState(device: MTLDevice) {
        guard let library = device.makeDefaultLibrary() else { return }
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        descriptor.vertexFunction   = library.makeFunction(name: "vs")
        descriptor.fragmentFunction = library.makeFunction(name: "fs")
        do {
            renderPipelineState = try device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var vertexBuffer: MTLBuffer!
    
    func createBuffers(device: MTLDevice) {
        vertexBuffer = device.makeBuffer(bytes: [0.0], length: 1, options: [])
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
            let renderPassDescriptr = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptr) else { return }
        commandEncoder.setRenderPipelineState(renderPipelineState)
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: 100)
        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
   }
}
