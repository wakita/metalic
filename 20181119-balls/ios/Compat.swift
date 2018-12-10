//
//  ViewController.swift
//  1M-balls-ios
//
//  Created by Ken Wakita on 2018/11/28.
//  Copyright © 2018 Ken Wakita. All rights reserved.
//

import UIKit

class _ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func isLandscape() -> Bool {
        //return UIApplication.shared.statusBarOrientation.isLandscape
        return UIDevice.current.orientation.isLandscape
    }
    
    func isPortrait() -> Bool {
        //return UIApplication.shared.statusBarOrientation.isPortrait
        return UIDevice.current.orientation.isPortrait
    }
}
