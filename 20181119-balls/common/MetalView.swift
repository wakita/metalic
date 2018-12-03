//
//  MetalView.swift
//  20181119-balls
//
//  Created by Ken Wakita on 2018/11/19.
//  Copyright © 2018 Ken Wakita. All rights reserved.
//

import MetalKit

class ViewController: _ViewController {
    var renderer: Renderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let metalView = view as? MTKView else {
            fatalError("MetalView not setup in storyboard")
        }
        
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Device loading error")
        }
        metalView.device = defaultDevice
        metalView.colorPixelFormat = .bgra8Unorm
        metalView.depthStencilPixelFormat = .depth32Float
        metalView.clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        
        renderer = Renderer(device: defaultDevice)
        metalView.delegate = renderer
        renderer?.mtkView(metalView, drawableSizeWillChange: view.frame.size)
    }
}
