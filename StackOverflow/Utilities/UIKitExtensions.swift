//
//  UIKitExtensions.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/14.
//

import UIKit


extension UIColor {
    
    /// Convert a UIColor to its hex representation
    func hex() -> String {
        let c = components()
        let r = UInt8(round(c.r * 255))
        let g = UInt8(round(c.g * 255))
        let b = UInt8(round(c.b * 255))
        return String(format: "%02x%02x%02x", r, g, b)
    }
    
    func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r: r, g: g, b: b, a: a)
    }
}
