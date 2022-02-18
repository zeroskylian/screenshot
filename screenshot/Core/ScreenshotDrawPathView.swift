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
    
    private func rectFromScreen(rect: CGRect) -> CGRect {
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
            guard let currentInfo = self.currentInfo else { return }
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
        let rectPath = NSBezierPath()
        rectPath.lineWidth = 4
        rectPath.lineCapStyle = .round
        rectPath.lineJoinStyle = .round
        switch info.draw {
        case .rect:
            rect = ScreenshotUtil.uniform(rect: rect)
            if rect.size.width * rect.size.width < 1e-2 { return }
            rectPath.appendRect(rect)
            rectPath.stroke()
        case .ellipse:
            rect = ScreenshotUtil.uniform(rect: rect)
            if rect.size.width * rect.size.width < 1e-2 { return }
            rectPath.appendOval(in: rect)
            rectPath.stroke()
        case .arrow:
            let x0: CGFloat = rect.origin.x
            let y0: CGFloat = rect.origin.y
            let x1: CGFloat = x0 + rect.size.width
            let y1: CGFloat = y0 + rect.size.height
            
            rectPath.move(to: .zero)
            let ex1 = sqrt(pow(x1 - x0, 2) + pow(y1 - y0, 2))
            if abs(rect.size.width) < 5 && abs(rect.size.height) < 5 {
                return
            }
            rectPath.line(to: CGPoint(x: ex1, y: 0))
            rectPath.line(to: CGPoint(x: ex1 - 8, y: 5))
            rectPath.line(to: CGPoint(x: ex1 - 2, y: 0))
            rectPath.line(to: CGPoint(x: ex1 - 8, y: -5))
            rectPath.line(to: CGPoint(x: ex1, y: 0))
            rectPath.close()
            
            let af = NSAffineTransform()
            af.translateX(by: x0, yBy: y0)
            af.rotate(byRadians: atan2(y1 - y0, x1 - x0))
            rectPath.transform(using: af as AffineTransform)
            rectPath.fill()
            rectPath.stroke()
        case .point:
            let pointPath = NSBezierPath()
            pointPath.lineWidth = 4
            pointPath.lineCapStyle = .round
            pointPath.lineJoinStyle = .round
            var lastPoint: CGPoint?
            let points = info.points ?? []
            for point in points {
                var rect = CGRect(x: point.x, y: point.y, width: 1, height: 1)
                if inBackground {
                    rect = window.convertFromScreen(rect)
                } else {
                    rect = rectFromScreen(rect: rect)
                }
                if lastPoint == nil {
                    pointPath.move(to: rect.origin)
                    lastPoint = point
                } else {
                    pointPath.line(to: rect.origin)
                }
            }
            pointPath.stroke()
        case .text:
            guard let text = info.editText else { return }
            var rect = CGRect(x: info.startPoint.x, y: info.startPoint.y, width: info.endPoint.x - info.startPoint.x, height: info.endPoint.y - info.startPoint.y)
            if inBackground {
                rect = window.convertFromScreen(rect)
            } else {
                rect = rectFromScreen(rect: rect)
            }
            rect.origin.x += 5
            rect.origin.y += 1
            rect = ScreenshotUtil.uniform(rect: rect)
            (text as NSString).draw(in: rect, withAttributes: [.font: ScreenshotManager.shared.configure.font, .foregroundColor: ScreenshotManager.shared.configure.textColor])
        }
    }
}
