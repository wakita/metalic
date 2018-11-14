//  MetalView.swift
//  20181113-Triangle
//
//  Created by Ken Wakita on 2018/11/13.
//  Copyright © 2018 Ken Wakita. All rights reserved.

import MetalKit

/**
 - Note: もともとは Cocoa 向けのビューのクラスが用意されていた。それを削除して、そのかわりに `MTKView` のサブクラスを用意した。storyboard のビューのクラスをここで定義した `MetalView` に変更することを忘れないように。
 */
class MetalView: MTKView {
    var renderer: Renderer!
    
    /**
     - Note: `device = MTLCreateSystemDefaultDevice()` とでもやりたいところだけれど、これだとデバイスオブジェクトが瞬間的にゴミになるらしい。このため、（無駄に思えるけれど）変数を用意して一旦、そこに代入している。
     */
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
