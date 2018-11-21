//
//  ViewController.swift
//  mac
//
//  Created by Ken Wakita on 2018/11/20.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {
    var controller: ViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        controller = ViewControllerDelegate(view: view as! MTKView)
        controller.viewDidLoad()
        controller.renderer.setFrameSize(size: controller.view.frame.size)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        controller.mouseDown(with: event)
    }
}

extension ViewControllerDelegate {
    func mouseDown(with theEvent: NSEvent) {
        let p = view.convert(theEvent.locationInWindow, to: nil)
        renderer.setTarget(x: f(p.x), y: f(p.y))
    }
}
