//
//  ScreenshotManager+Class.swift
//  screenshot
//
//  Created by Xinbo Lian on 2022/1/28.
//

import Foundation
import AppKit

extension ScreenshotManager {
    
    enum CaptureState {
        case idle
        case highlight
        case firstMouseDown
        case readyAdjust
        case adjust
        case edit
        case done
    }
    
    class DrawConfigure {
        
        var color: NSColor = .red
        
        var textColor: NSColor = .red
        
        var font: NSFont = .boldSystemFont(ofSize: 12)
        
        var borderLineWidth: CGFloat = 2
        
        var borderLineColor: NSColor = NSColor(hex: 0x1191FE)
    }
    
    struct Constant {
        static let keyEscCode: Int = 53
    }
    
    enum Draw {
        case rect
        case ellipse
        case arrow
        case point
        case text
    }
    
    class DrawPathInfo {
        let startPoint: CGPoint
        let endPoint: CGPoint
        let draw: Draw
        let points: [CGPoint]?
        let editText: String?
        
        init(draw: Draw, startPoint: CGPoint = .zero, endPoint: CGPoint = .zero, points: [CGPoint]?, editText: String?) {
            self.draw = draw
            self.startPoint = startPoint
            self.endPoint = endPoint
            self.points = points
            self.editText = editText
        }
    }
}

extension Notification.Name {
    
    static let kNotifyCaptureEnd = Notification.Name.init(rawValue: "kNotifyCaptureEnd")
    
    static let kNotifyMouseLocationChange = Notification.Name.init(rawValue: "kNotifyMouseLocationChange")
}
