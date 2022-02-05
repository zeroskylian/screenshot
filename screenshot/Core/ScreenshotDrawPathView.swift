//
//  ScreenshotDrawPathView.swift
//  screenshot
//
//  Created by Xinbo Lian on 2022/2/5.
//

import AppKit

class ScreenshotDrawPathView: NSView {
    
    var rectArray: [ScreenshotManager.DrawPathInfo] = []
    
    var currentInfo: ScreenshotManager.DrawPathInfo?
    
    private func rectFromScreen(rect: NSRect) -> NSRect {
        guard let window = self.window else { return rect }
        var rectRet = window.convertFromScreen(rect)
        rectRet.origin.x -= frame.origin.x
        rectRet.origin.y -= frame.origin.y
        return rectRet
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if ScreenshotManager.shared.captureState == .edit {
            drawComment(in: bounds)
            guard let currentInfo = self.currentInfo else {  return }
            drawShape(info: currentInfo, inBackground: false)
        }
    }
    
    func drawComment(in rect: NSRect) {
        let path = NSBezierPath(rect: rect)
        path.addClip()
        ScreenshotManager.shared.configure.color.set()
        for info in rectArray {
            drawShape(info: info, inBackground: false)
        }
    }
    
    func drawFinishComment(in rect: NSRect) {
        let path = NSBezierPath(rect: rect)
        path.addClip()
        ScreenshotManager.shared.configure.color.set()
        for info in rectArray {
            drawShape(info: info, inBackground: true)
        }
    }
    
    func drawShape(info: ScreenshotManager.DrawPathInfo, inBackground: Bool) {
        guard let window = self.window else { return }
        var rect = NSRect(x: info.startPoint.x, y: info.startPoint.y, width: info.endPoint.x - info.startPoint.x, height: info.endPoint.y - info.startPoint.y)
        if inBackground {
            rect = window.convertFromScreen(rect)
        } else {
            rect = rectFromScreen(rect: rect)
        }
        let path = NSBezierPath()
        path.lineWidth = 4
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        switch info.draw {
        case .rect:
            break
        case .ellipse:
            break
        case .arrow:
            break
        case .point:
            break
        case .text:
            break
        }
    }
}
