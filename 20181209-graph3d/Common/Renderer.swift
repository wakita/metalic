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
    var viewController: _ViewController
    
    init(device: MTLDevice, viewController: _ViewController) {
        self.viewController = viewController
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
    
    var N = 0
    var vertexBuffer: MTLBuffer!
    
    func createBuffers(device: MTLDevice) {
        let fileName = "math-cmds"
        guard let filePath = Bundle.main.url(forResource: fileName, withExtension: "npy") else {
            fatalError("Failed to open " + fileName)
        }
        do {
            let math = try Npy(contentsOf: filePath)
            N = math.shape[0]
            let data: [Double] = math.elements()
            print(data[0], data[1], data[2], data.count)
            let OFF_X = 0, OFF_Y = N, OFF_Z = 2*N
            var vertices = Array<Vertex>(repeating: Vertex(position: float3(0, 0, 0)), count: N)
            for i in 0 ..< N {
                let x = Float(data[OFF_X + i]), y = Float(data[OFF_Y + i]), z = Float(data[OFF_Z + i])
                vertices[i] = Vertex(position: float3(x, y, z))
            }
            vertexBuffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<Vertex>.stride * vertices.count, options: [])
        } catch {}

    }
    
    var eyes = [float4(0 - 0.001, 0, -15, 1), float4(0 + 0.001, 0, -15, 1)]
    var U = Uniforms()
    func createUniforms() {
        U.N = Int32(N)
        U.Model = float4x4.identity()
        U.View  = float4x4.identity()
    }
    
    var debug = 0
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let aspect = Float(view.bounds.width / 2) / Float(view.bounds.height)
        U.Projection = float4x4(projectionFov: radians(fromDegrees: 70),
                                near: 0.001, far: 100,
                                aspect: aspect);
        // 3D TV 向けの出力をするときは aspect /= 2 するとよさそうだ。
        let sz = view.drawableSize
        #if os(iOS) || os(watchOS) || os(tvOS)
        U.DrawableWidth  = Int32(sz.height)
        U.DrawableHeight = Int32(sz.width)
        #else
        U.DrawableWidth  = Int32(sz.width)
        U.DrawableHeight = Int32(sz.height)
        #endif
        
        print(U.DrawableWidth, U.DrawableHeight)

        //print(viewController.isPortrait() ? "Portrait" : "Landscape", sz)
    }
    
    func draw(in view: MTKView) {
        let t = Date().timeIntervalSince(start)

        guard let drawable = view.currentDrawable,
            let renderPassDescriptr = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptr) else { return }
        for i in 0 ..< eyes.count {
            U.Left = Int32(1 - i)
            // let eye = float4x4(translation: [0, 0, Float(t / 10)]) * float4x4(rotationY: Float(3.14 * t / 36)) * eyes[i]
            let eye = float4x4(translation: [0, 0, Float(t / 10)]) * eyes[i]

            U.PostProjection = float4x4(translation: [i == 0 ? -0.5 : 0.5, 0, 0])
            // U.View = float4x4(eye: [eye.x, eye.y, eye.z], center: [0, 0, 0], up: [0, 1, 0])
            U.View = float4x4(translation: [eye.x, eye.y, eye.z]).inverse
            
            if (debug < 5) {
                print(U.View)
                debug = debug + 1
            }

            commandEncoder.setRenderPipelineState(renderPipelineState)
            commandEncoder.setDepthStencilState(depthStencilState)
            commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: VERTEX_INDEX)
            commandEncoder.setVertexBytes(&U, length: MemoryLayout<Uniforms>.stride, index: UNIFORMS_INDEX)
            commandEncoder.setFragmentBuffer(vertexBuffer, offset: 0, index: VERTEX_INDEX)
            commandEncoder.setFragmentBytes(&U, length: MemoryLayout<Uniforms>.stride, index: UNIFORMS_INDEX)
            commandEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: Int(U.N))
        }
        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
   }
}
