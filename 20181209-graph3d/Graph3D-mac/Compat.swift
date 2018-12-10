//
//  ViewController.swift
//  Graph3D-mac
//
//  Created by Ken Wakita on 2018/12/09.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let filePath = Bundle.main.url(forResource: "math-agi0", withExtension: "npy") {
            do {
                let math = try Npy(contentsOf: filePath)
                let n = math.shape[0], k = math.shape[1]
                print(n, k, math.isFortranOrder)
                let data: [Double] = math.elements()
                print(data[0], data[1], data[2], data.count)
                let X: ArraySlice<Double> = data[0..<n]
                let Y: ArraySlice<Double> = data[n..<2*n]
                let Z: ArraySlice<Double> = data[2*n..<3*n]
                print(X.count, Y.count, Z.count)
                var pos = Array<float3>(repeating: float3(0, 0, 0), count: n)
                for i in 0..<n {
                    let x = Float(X[i]), y = Float(Y[i]), z = Float(Z[i])
                    pos[i] = float3(x, y, z)
                }
            } catch {
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

