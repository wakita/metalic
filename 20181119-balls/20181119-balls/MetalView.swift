//
//  ViewController.swift
//  20181119-balls
//
//  Created by Ken Wakita on 2018/11/19.
//  Copyright © 2018 Ken Wakita. All rights reserved.
//

import MetalKit

class MetalView: MTKView {
    var renderer: Renderer!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Device loading error")
        }
        device = defaultDevice
        colorPixelFormat = .bgra8Unorm
        clearColor = MTLClearColor(red: 0.1, green: 0.57, blue: 0.25, alpha: 1)
        
        createRenderer(device: device!)
    }
    
    func createRenderer(device: MTLDevice) {
        renderer = Renderer(device: device)
        delegate = renderer
    }
}
