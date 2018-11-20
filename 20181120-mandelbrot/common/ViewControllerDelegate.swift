//
//  ViewControllerDelegate.swift
//  mac
//
//  Created by Ken Wakita on 2018/11/20.
//

import Foundation
import MetalKit

class ViewControllerDelegate: NSObject {
    var view: MTKView!
    var renderer: Renderer!
    
    init(view: MTKView) {
        self.view = view
    }
    
    func viewDidLoad() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("The device does not support Metal technology")
            return
        }
        
        view.device = device
        renderer = Renderer(device: device)
        view.delegate = renderer
    }
}
