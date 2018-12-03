//
//  Renderer.swift
//  20181119-balls
//
//  Created by Ken Wakita on 2018/11/19.
//  Copyright © 2018 Ken Wakita. All rights reserved.
//

import MetalKit

class Renderer: NSObject {
    
    let start = Date()
    
    init(device: MTLDevice) {
        super.init()
        createCommandQueue(device: device)
        createPipelineState(device: device)
        buildDepthStencilState(device: device)
        createBuffers(device: device)
        createUniforms()
    }
    
    var commandQueue: MTLCommandQueue!

    func createCommandQueue(device: MTLDevice) {
        commandQueue = device.makeCommandQueue()
    }
    
    var renderPipelineState: MTLRenderPipelineState!

    func createPipelineState(device: MTLDevice) {
        guard let library = device.makeDefaultLibrary() else { return }
        let descriptor = MTLRenderPipelineDescriptor()
        guard let attach = descriptor.colorAttachments[0] else { return }
        attach.pixelFormat = .bgra8Unorm
        
        attach.isBlendingEnabled = true
        attach.rgbBlendOperation = MTLBlendOperation.add
        attach.sourceRGBBlendFactor = MTLBlendFactor.sourceAlpha
        attach.destinationRGBBlendFactor = MTLBlendFactor.oneMinusSourceAlpha
        attach.alphaBlendOperation = MTLBlendOperation.add
        attach.sourceRGBBlendFactor = MTLBlendFactor.sourceAlpha
        attach.destinationRGBBlendFactor = MTLBlendFactor.oneMinusSourceAlpha
        
        descriptor.depthAttachmentPixelFormat = .depth32Float
        descriptor.vertexFunction   = library.makeFunction(name: "vs")
        descriptor.fragmentFunction = library.makeFunction(name: "fs")
        do {
            renderPipelineState = try device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var depthStencilState: MTLDepthStencilState!
    func buildDepthStencilState(device: MTLDevice) {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        depthStencilState = device.makeDepthStencilState(descriptor: descriptor)
    }
    
    var vertexBuffer: MTLBuffer!
    
    func createBuffers(device: MTLDevice) {
        vertexBuffer = device.makeBuffer(bytes: [0.0], length: 1, options: [])
    }
    
    let eyes = [float4(0.49, 1.1, 3, 1), float4(0.51, 1.1, 3, 1)]
    var U = Uniforms()
    func createUniforms() {
        U.N = 5 + 1
        U.Model = float4x4.identity()
        U.View  = float4x4.identity()
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let aspect = Float(view.bounds.width) / Float(view.bounds.height)
        U.Projection = float4x4(projectionFov: radians(fromDegrees: 70),
                                near: 0.001, far: 100,
                                aspect: aspect);
        U.DrawableWidth  = Int32(view.drawableSize.width)
        U.DrawableHeight = Int32(view.drawableSize.height)
    }
    
    func draw(in view: MTKView) {
        let t = Date().timeIntervalSince(start)

        guard let drawable = view.currentDrawable,
            let renderPassDescriptr = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptr) else { return }
        for i in 0 ... eyes.count-1 {
            U.Left = Int32(1 - i)
            let eye = float4x4(rotationY: Float(3.14 * (-t / 20))) * eyes[i]
            U.PostProjection = float4x4(translation: [i == 0 ? -0.5 : 0.5, 0, 0])
            U.View = float4x4(eye: [eye.x, eye.y, eye.z], center: [0.5, 0.6, 0.7], up: [0, 1, 0])
            
            commandEncoder.setRenderPipelineState(renderPipelineState)
            commandEncoder.setDepthStencilState(depthStencilState)
            commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: VERTEX_INDEX)
            commandEncoder.setVertexBytes(&U, length: MemoryLayout<Uniforms>.stride, index: UNIFORMS_INDEX)
            commandEncoder.setFragmentBuffer(vertexBuffer, offset: 0, index: VERTEX_INDEX)
            commandEncoder.setFragmentBytes(&U, length: MemoryLayout<Uniforms>.stride, index: UNIFORMS_INDEX)
            commandEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: Int(U.N * U.N * U.N))
        }
        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
   }
}
