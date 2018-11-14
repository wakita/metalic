//
//  Renderer.swift
//  20181113-Triangle
//
//  Created by Ken Wakita on 2018/11/13.
//  Copyright © 2018 Ken Wakita. All rights reserved.
//

import MetalKit

/**
 頂点のデータ構造。
 
 - Note: この単純な例では X-Y 座標のみを扱う。
 */
struct Vertex {
    var position: float2
}

/**
 */
class Renderer: NSObject {
    /// 頂点座標
    var vertices: [Vertex] = [ // 座標を与える順序は画素シェーダの uv に影響するので十分に注意すること
        // 三角形0
        Vertex(position: float2( 1, -1)),
        Vertex(position: float2(-1,  1)),
        Vertex(position: float2(-1, -1)),
        
        // 三角形1
        Vertex(position: float2(-1,  1)),
        Vertex(position: float2( 1, -1)),
        Vertex(position: float2( 1,  1))
    ]
    
    /**
     コマンドキューの準備、グラフィックパイプラインを設定、頂点バッファを準備
     */
    init(device: MTLDevice) {
        super.init()
        createCommandQueue(device: device)
        createPipelineState(device: device)
        createBuffers(device: device)
    }
    
    var commandQueue: MTLCommandQueue!
    /**
     コマンドキュー
     - Parameter device: デバイスオブジェクト
     */
    func createCommandQueue(device: MTLDevice) {
        commandQueue = device.makeCommandQueue()
    }
    
    var renderPipelineState: MTLRenderPipelineState!
    /**
     パイプライン状態を初期化する。
     - Parameter device: デバイスオブジェクト
     */
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
    /**
     頂点バッファを作成する。
     - Parameter device: デバイスオブジェクト
     
     Note: ここでつまらないバグを入れて苦しんだ。Readme.md を参照のこと。
     */
    func createBuffers(device: MTLDevice) {
        /// - Tag: vertexBufferInitialization
        vertexBuffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<Vertex>.stride * vertices.count, options: [])
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    /**
     指定された `view` への描画を担当するコールバック
     - Parameter view: 描画対象領域
     - コマンドバッファを用意し、すでに用意していあるパイプライン状態を設定
     - コマンドバッファに三角形を描画する命令を投入
     - 出力先を表示画面に指定してコマンドを実行
     */
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
            let renderPassDescriptr = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptr) else { return }
        commandEncoder.setRenderPipelineState(renderPipelineState)
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
