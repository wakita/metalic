//
//  ViewController.swift
//  StereoView-macOS
//
//  Created by Ken Wakita on 2018/12/02.
//

import MetalKit

class ViewController: _ViewController {
    @IBOutlet weak var leftEyeView: MTKView!
    @IBOutlet weak var rightEyeView: MTKView!
    var renderer: Renderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal device not available")
        }

        for eyeview in [leftEyeView!, rightEyeView!] {
            eyeview.device = device
            eyeview.colorPixelFormat = .bgra8Unorm
            eyeview.depthStencilPixelFormat = .depth32Float
            
            eyeview.clearColor = eyeview == leftEyeView ? MTLClearColor(red: 0.5, green: 0, blue: 0, alpha: 1) : MTLClearColor(red: 0, green: 0, blue: 0.5, alpha: 1)
            
            renderer = Renderer(device: device, name: eyeview == leftEyeView ? "left" : "right")
            eyeview.delegate = renderer
            renderer?.mtkView(eyeview, drawableSizeWillChange: eyeview.drawableSize)
        }
    }
}

class Renderer: NSObject {
    let start = Date()

    var device: MTLDevice
    var name: String
    var renderPipelineState: MTLRenderPipelineState!
    lazy var commandQueue = device.makeCommandQueue()!
    
    init(device: MTLDevice, name: String) {
        self.device = device
        self.name = name
        super.init()
        createRenderPipelineState()
    }
    
    func createRenderPipelineState() {
        let library = self.device.makeDefaultLibrary()!
        let descriptor = MTLRenderPipelineDescriptor()
        let attach = descriptor.colorAttachments[0]!
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
        do { renderPipelineState = try self.device.makeRenderPipelineState(descriptor: descriptor)
        } catch { print(error.localizedDescription) }
    }
    
    lazy var depthStencilState: MTLDepthStencilState = {
        let descriptor = MTLDepthStencilDescriptor()
        return self.device.makeDepthStencilState(descriptor: descriptor)!
    }()
    
    lazy var vertexBuffer = {
        self.device.makeBuffer(bytes: [0.0], length: 1, options: [])
    }()

    let eye = float4(0.5, 1.1, 3, 1)

    var U: Uniforms = {
        var u = Uniforms()
        u.N = 5 + 1
        u.Model = float4x4.identity()
        u.View = float4x4.identity()
        return u
    }()
    
    var drawCount = 0
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let sz = view.drawableSize
        print(name, sz)
        U.Projection = float4x4(projectionFov: radians(fromDegrees: 70),
                                near: 0.001, far: 100,
                                aspect: Float(sz.width / sz.height))
        U.DrawableWidth  = Int32(sz.width)
        U.DrawableHeight = Int32(sz.height)
    }

    func draw(in view: MTKView) {
        let t = Date().timeIntervalSince(start)

        if (drawCount < 5) {
            drawCount = drawCount + 1
            print(name, drawCount)
        }
        
        let eye = float4x4(rotationY: Float(3.14 * (-t / 20))) * self.eye
        U.View = float4x4(eye: [eye.x, eye.y, eye.z], center: [0.5, 0.6, 0.7], up: [0, 1, 0])
        
        let descriptor = view.currentRenderPassDescriptor!
        let buffer = commandQueue.makeCommandBuffer()!
        let encoder = buffer.makeRenderCommandEncoder(descriptor: descriptor)!

        encoder.setRenderPipelineState(renderPipelineState)
        encoder.setDepthStencilState(depthStencilState)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: VERTEX_INDEX)
        encoder.setVertexBytes(&U, length: MemoryLayout<Uniforms>.stride, index: UNIFORMS_INDEX)
        encoder.setFragmentBytes(&U, length: MemoryLayout<Uniforms>.stride, index: UNIFORMS_INDEX)
        encoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: Int(U.N * U.N * U.N))
        
        encoder.endEncoding()
        
        buffer.present(view.currentDrawable!)
        buffer.commit()
    }

}
