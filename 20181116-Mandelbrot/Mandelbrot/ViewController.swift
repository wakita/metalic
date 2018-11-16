//
//  GameViewController.swift
//  Mandelbrot
//
//  Created by Ken Wakita on November 16, 2018.
//  Copyright © 2018 Ken Wakita. All rights reserved.
//

import UIKit
import Metal
import MetalKit

struct VertexIn {
    var position: float2
}

var vertices: [VertexIn] = [
    VertexIn(position: float2(-1, -1)),
    VertexIn(position: float2( 1, -1)),
    VertexIn(position: float2(-1,  1)),
    VertexIn(position: float2( 1,  1))
]

class ViewController: UIViewController {
    
    var device: MTLDevice! = nil
    var commandQueue: MTLCommandQueue! = nil
    var pipelineState: MTLRenderPipelineState! = nil
    var vertexBuffer: MTLBuffer! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let device = MTLCreateSystemDefaultDevice() else { // Fallback to a blank UIView, an application could also fallback to OpenGL ES here.
            print("Metal is not supported on this device")
            self.view = UIView(frame: self.view.frame)
            return
        }
        self.device = device

        loadAssets()
        mtkView(view as! MTKView, drawableSizeWillChange: view.frame.size)
    }
    
    func loadAssets() {
        let view = self.view as! MTKView
        commandQueue = device.makeCommandQueue()
        commandQueue.label = "main command queue"
        
        let defaultLibrary = device.makeDefaultLibrary()!
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = defaultLibrary.makeFunction(name: "vs")!
        pipelineStateDescriptor.fragmentFunction = defaultLibrary.makeFunction(name: "fs")!
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineStateDescriptor.sampleCount = view.sampleCount
        
        do {
            try pipelineState = device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error {
            print("Failed to create a pipeline state, error \(error)")
        }
        
        vertexBuffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<VertexIn>.stride * vertices.count, options: [])
    }
    
    func update() {}
    
    var frameSize = double2(0, 0)
    
    func setFrameSize(size: CGSize) {
        frameSize = double2(Double(size.width), Double(size.height))
    }
    
    /// Complex field
    var C = double2x2([ double2(-2, -2), double2(2, 2) ])
    /// Point of interest
    var poi = double2(0, 0)

    func setTarget(p: CGPoint) {
        let pos = double2(Double(p.x), frameSize.y - Double(p.y))
        poi = ((frameSize - pos) * C[0] + pos * C[1]) / frameSize
    }
    
    /// Shrink rate: the region of view shrinks by α for each frame
    let α = 0.998
    /// Smooth targetting is achieved by targetting towards 60 frames in the future.
    let N = 60.0
    
    func setComplexField() {
        let diag0: double2 = C[1] - C[0]
        let diag:  double2 = diag0 * pow(α, N)
        let E = double2x2(poi - diag / 2, poi + diag / 2)
        C = C * ((N - 1) / N) + E * (1 / N)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        setTarget(p: view.convert(touches.first!.location(in: view), to: nil))
    }
}

extension ViewController: MTKViewDelegate {
    func draw(in view: MTKView) {
        setComplexField()
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        commandBuffer!.label = "Frame command buffer"
        
        if let renderPassDescriptor = view.currentRenderPassDescriptor, let currentDrawable = view.currentDrawable {
            let renderEncoder = commandBuffer!.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
            renderEncoder!.label = "Render encoder"
            
            renderEncoder!.pushDebugGroup("Draw Mandelbrot")
            renderEncoder!.setRenderPipelineState(pipelineState)
            
            // Vertex buffer
            renderEncoder!.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            
            // Complex field uniform
            var CFloat = float2x2(float2(Float(C[0].x), Float(C[0].y)), float2(Float(C[1].x), Float(C[1].y)))
            renderEncoder!.setVertexBytes(&CFloat, length: MemoryLayout<float2x2>.stride, index: 1)
            
            renderEncoder!.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: vertices.count)
            
            renderEncoder!.popDebugGroup()
            renderEncoder!.endEncoding()
            
            commandBuffer!.present(currentDrawable)
        }
        
        commandBuffer!.commit()
    }
    
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        view.device = device
        view.delegate = self
        setFrameSize(size: view.frame.size)
    }
}
