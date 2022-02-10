//
//  ScreenshotView.swift
//  screenshot
//
//  Created by Xinbo Lian on 2022/2/5.
//

import AppKit

class ScreenshotView: NSView {
    
    private static let dragPointNum = 8
    private static let dragPointLen: CGFloat = 5
    
    var image: NSImage?
    
    var drawingRect: CGRect = .zero
    
    var pathView: ScreenshotDrawPathView?
    
    var trackingArea: NSTrackingArea?
    
    var toolBox: ScreenshotToolBox?
    
    private var tipView: ScreenshotLabelView?
    
    func setupTrackingArea(rect: CGRect) {
        trackingArea = NSTrackingArea(rect: rect, options: [.mouseMoved, .activeAlways], owner: self, userInfo: nil)
        addTrackingArea(trackingArea!)
    }
    
    func setupTool() {
        toolBox = ScreenshotToolBox()
        addSubview(toolBox!)
        hideToolkit()
        
        tipView = ScreenshotLabelView()
        addSubview(tipView!)
        hideTip()
    }
    
    func setupDrawPath() {
        guard pathView == nil else { return }
        pathView = ScreenshotDrawPathView()
        addSubview(pathView!)
        let imageRect = drawingRect.intersection(bounds)
        pathView?.frame = imageRect
        pathView?.isHidden = false
    }
    
    func showToolkit() {
        let imageRect = drawingRect.intersection(bounds)
        var y = imageRect.origin.y - 28
        var x = imageRect.origin.x + imageRect.size.width
        y = max(0, y)
        let margin: CGFloat = 10
        let toolWidth: CGFloat = (35 * 7) + (margin * 2) - (35 - 28)
        x = max(toolWidth, x)
        if toolBox?.frame != CGRect(x: x - toolWidth, y: y, width: toolWidth, height: 26) {
            toolBox?.frame = CGRect(x: x - toolWidth, y: y, width: toolWidth, height: 26)
        }
        
        if toolBox?.isHidden == true {
            toolBox?.isHidden = false
        }
    }
    
    func hideToolkit() {
        toolBox?.isHidden = true
    }
    
    func showTip() {
        guard let window = window else { return }
        var mouseLocation = NSEvent.mouseLocation
        let frame = window.frame
        if mouseLocation.x > frame.origin.x + frame.size.width - 100 {
            mouseLocation.x -= 100
        }
        
        if mouseLocation.x < frame.origin.x {
            mouseLocation.x = frame.origin.x
        }
        
        if mouseLocation.y > frame.origin.y + frame.size.height - 26 {
            mouseLocation.y -= 26
        }
        
        if mouseLocation.y < frame.origin.y {
            mouseLocation.y = frame.origin.y
        }
        
        let rect = CGRect(origin: mouseLocation, size: CGSize(width: 100, height: 25))
        let imageRect = drawingRect.intersection(bounds)
        tipView?.text = String(format: "%dX%d", Int(imageRect.size.width), Int(imageRect.size.height))
        tipView?.frame = window.convertFromScreen(rect)
        tipView?.isHidden = false
    }
    
    func hideTip() {
        tipView?.isHidden = true
    }
    
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
    
    func pointRect(index: Int, in rect: CGRect) -> CGRect {
        var x: CGFloat = 0
        var y: CGFloat = 0
        switch index {
        case 0:
            x = rect.minX
            y = rect.maxY
        case 1:
            x = rect.midX
            y = rect.maxY
        case 2:
            x = rect.maxX
            y = rect.maxY
        case 3:
            x = rect.minX
            y = rect.midY
        case 4:
            x = rect.maxX
            y = rect.midY
        case 5:
            x = rect.minX
            y = rect.minY
        case 6:
            x = rect.midX
            y = rect.minY
        case 7:
            x = rect.maxX
            y = rect.minY
        default:
            break
        }
        return CGRect(x: x - Self.dragPointLen, y: y - Self.dragPointLen, width: Self.dragPointLen * 2, height: Self.dragPointLen * 2)
    }
    override func draw(_ dirtyRect: NSRect) {
        NSDisableScreenUpdates()
        super.draw(dirtyRect)
        if let image = image {
            let imageRect = drawingRect.intersection(bounds)
            image.draw(in: imageRect, from: imageRect, operation: .sourceOver, fraction: 1)
            NSColor(hex: ScreenshotManager.Constant.borderLineColor).set()
            let rectPath = NSBezierPath()
            rectPath.lineWidth = ScreenshotManager.Constant.borderLineWidth
            rectPath.removeAllPoints()
            rectPath.appendRect(imageRect)
            rectPath.stroke()
            if ScreenshotManager.shared.captureState == .adjust {
                NSColor.white.set()
                for i in 0 ..< Self.dragPointNum {
                    let adjustPath = NSBezierPath()
                    adjustPath.removeAllPoints()
                    adjustPath.appendOval(in: pointRect(index: i, in: imageRect))
                    adjustPath.fill()
                }
            }
        }
        if toolBox != nil && toolBox?.isHidden == false {
            showToolkit()
        }
        NSEnableScreenUpdates()
    }
}
