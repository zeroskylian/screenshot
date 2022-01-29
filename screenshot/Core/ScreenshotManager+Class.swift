//
//  ScreenshotManager+Class.swift
//  screenshot
//
//  Created by Xinbo Lian on 2022/1/28.
//

import Foundation

extension ScreenshotManager {
    
    enum CaptureState {
        case idle
        case highlight
        case firstMouseDown
        case readyAdjust
        case edit
        case done
    }
    
    enum Draw {
        case rect
        case ellipse
        case arrow
        case point
        case text
    }
    
    struct Constant {
        
    }
}

extension Notification.Name {
    
    static let kNotifyCaptureEnd = Notification.Name.init(rawValue: "kNotifyCaptureEnd")
    
    static let kNotifyMouseLocationChange = Notification.Name.init(rawValue: "kNotifyMouseLocationChange")
}
