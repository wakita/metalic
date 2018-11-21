//
//  compat.swift
//  mac
//
//  Created by Ken Wakita on 2018/11/21.
//

import CoreGraphics

typealias FLOAT = Float80
func f(_ x: Double) -> FLOAT { return Float80(x) }
func f(_ x: CGFloat) -> FLOAT { return Float80(x) }
