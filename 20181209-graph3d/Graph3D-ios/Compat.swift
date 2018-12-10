//
//  ViewController.swift
//  Graph3D-ios
//
//  Created by Ken Wakita on 2018/12/09.
//

import UIKit

class _ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("view did load")
    }

    func isLandscape() -> Bool {
        return UIDevice.current.orientation.isLandscape
    }
    
    func isPortrait() -> Bool {
        return UIDevice.current.orientation.isPortrait
    }
}

