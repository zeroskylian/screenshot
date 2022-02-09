//
//  NSColorExtension.swift
//  screenshot
//
//  Created by Xinbo Lian on 2022/2/5.
//

import AppKit

extension NSColor {
    convenience init(hex: Int) {
        let r = (hex & 0xff0000) >> 16
        let g = (hex & 0xff00) >> 8
        let b = hex & 0xff
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1)
    }
}
