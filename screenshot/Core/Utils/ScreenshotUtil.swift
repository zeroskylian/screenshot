//
//  ScreenshotUtil.swift
//  screenshot
//
//  Created by Xinbo Lian on 2022/2/5.
//

import AppKit

struct ScreenshotUtil {

    static func distance(from p1: CGPoint, to p2: CGPoint) -> CGFloat {
        return pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2)
    }
    
    static func uniform(rect: CGRect) -> CGRect {
        var x = rect.origin.x
        var y = rect.origin.y
        var w = rect.size.width
        var h = rect.size.height
        if w < 0 {
            x += w
            w = -w
        }
        
        if h < 0 {
            y += h
            h = -h
        }
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    static func rectToZero(rect: CGRect) -> CGRect {
        return rect.offsetBy(dx: -rect.origin.x, dy: -rect.origin.y)
    }
    
    static func cgWindowRectToScreenRect(windowRect: CGRect) -> CGRect {
        var mainRect = NSScreen.main?.frame ?? .zero
        for screen in NSScreen.screens {
            if Int(screen.frame.origin.x) == 0 && Int(screen.frame.origin.y) == 0 {
                mainRect = screen.frame
            }
        }
        let rect = CGRect(x: windowRect.origin.x, y: mainRect.size.height - windowRect.size.height - windowRect.origin.y, width: windowRect.size.width, height: windowRect.size.height)
        return rect
    }
}
