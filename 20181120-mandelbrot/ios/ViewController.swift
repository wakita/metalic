//
//  ViewController.swift
//  ios
//
//  Created by Ken Wakita on 2018/11/20.
//

import UIKit
import MetalKit

class ViewController: UIViewController {
    var controller: ViewControllerDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        controller = ViewControllerDelegate(view: view as! MTKView)
        controller.viewDidLoad()
        controller.renderer.setFrameSize(size: controller.view.frame.size)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        controller.touchesBegan(touches, with: event)
    }
}

extension ViewControllerDelegate {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let p = view.convert(touches.first!.location(in: view), to: nil)
        renderer.setTarget(x: f(p.x), y: renderer.frameSize[1] - f(p.y))
    }
}
