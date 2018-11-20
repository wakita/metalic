//
//  MetalView.swift
//  20181115-Mandelbrot
//
//  Created by Ken Wakita on 2018/11/13.
//  Copyright © 2018 Ken Wakita. All rights reserved.
//

import MetalKit

class MetalView: MTKView {
    var renderer: Renderer!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        print("Application started")
        
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Device loading error")
        }
        device = defaultDevice
        colorPixelFormat = .bgra8Unorm
        clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        
        createRenderer(device: device!)
    }
    
    func createRenderer(device: MTLDevice) {
        renderer = Renderer(device: device)
        renderer.setFrameSize(size: frame.size)
        delegate = renderer
    }
}
