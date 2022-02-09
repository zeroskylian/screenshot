//
//  ScreenshotWindowController.swift
//  screenshot
//
//  Created by lian on 2022/2/9.
//

import Cocoa

class ScreenshotWindowController: NSWindowController {

    private static let kAdjustKnown = 8
    
    private var snipView: ScreenshotView?
    
    private var originImage: NSImage?
    
    private var darkImage: NSImage?
    
    private var captureWindowRect: CGRect = .zero
    
    private var dragWindowRect: CGRect = .zero
    
    private var lastRect: CGRect = .zero
    
    private var startPoint: CGPoint = .zero
    
    private var endPoint: CGPoint = .zero
    
    private var dragDirection = 0
    
    private var rectBeginPoint: CGPoint = .zero
    
    private var rectEndPoint: CGPoint = .zero
    
    private var rectDrawing = false
    
    private var linePoints: [CGPoint] = []
    
    private var editTextView: NSTextView?
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func doScreenshot(screen: NSScreen) {
        guard let imgRef = SnipUtil.screenShot(screen)?.takeUnretainedValue() else { return }
        let mainFrame = screen.frame
        originImage = NSImage(cgImage: imgRef, size: mainFrame.size)
        darkImage = NSImage(cgImage: imgRef, size: mainFrame.size)
        
        darkImage?.lockFocus()
        NSColor(calibratedWhite: 0, alpha: 0.33).set()
        ScreenshotUtil.rectToZero(rect: mainFrame).fill(using: .sourceAtop)
        darkImage?.unlockFocus()
    }
    
    func captureAppScreen() {
        guard let screen = window?.screen else { return }
        let mouseLocation = NSEvent.mouseLocation
        let screenFrame = screen.frame
        self.captureWindowRect = screenFrame
        var minArea = screenFrame.size.width * screenFrame.size.height
        for dir in ScreenshotManager.shared.arrayRect {
            do {
                let windowRect = dir[kCGWindowBounds as String] as? CGRect
                let rect = try ScreenshotUtil.cgWindowRectToScreenRect(windowRect: windowRect.unwrap())
                guard let layer = dir[kCGWindowLayer as String] as? Int else { continue}
                guard layer >= 0 else { continue }
                if ScreenshotUtil.point(point: mouseLocation, inRect: rect) {
                    if layer == 0 {
                        self.captureWindowRect = rect
                        break
                    } else {
                        if rect.size.width * rect.size.height < minArea {
                            self.captureWindowRect = rect
                            minArea = rect.size.width * rect.size.height
                            break
                        }
                    }
                }
            } catch {
                print(error)
                continue
            }
        }
        
        if ScreenshotUtil.point(point: mouseLocation, inRect: screenFrame) {
            redrawView(image: originImage)
        } else {
            redrawView(image: nil)
            NotificationCenter.default.post(name: .kNotifyMouseLocationChange, object: nil, userInfo: ["context": self])
        }
    }
    
    func redrawView(image: NSImage?) {
        guard let window = self.window else { return }
        self.captureWindowRect = self.captureWindowRect.intersection(window.frame)
        if image != nil
            && Int(lastRect.origin.x) == Int(captureWindowRect.origin.x)
            && Int(lastRect.origin.y) == Int(captureWindowRect.origin.y)
            && Int(lastRect.width) == Int(captureWindowRect.width)
            && Int(lastRect.height) == Int(captureWindowRect.height) {
            return
        }
        if snipView?.image == nil && image == nil {
            return
        }
        DispatchQueue.main.async {
            self.snipView?.image = image
            let rect = window.convertFromScreen(self.captureWindowRect)
            self.snipView?.drawingRect = rect
            self.snipView?.needsDisplay = true
            self.lastRect = self.captureWindowRect
        }
    }
    
    func dragPointCenter(index: Int) -> CGPoint {
        var x: CGFloat = 0
        var y: CGFloat = 0
        switch index {
        case 0:
            x = captureWindowRect.minX
            y = captureWindowRect.maxY
        case 1:
            x = captureWindowRect.midX
            y = captureWindowRect.maxY
        case 2:
            x = captureWindowRect.maxX
            y = captureWindowRect.maxY
        case 3:
            x = captureWindowRect.minX
            y = captureWindowRect.midY
        case 4:
            x = captureWindowRect.maxX
            y = captureWindowRect.midY
        case 5:
            x = captureWindowRect.minX
            y = captureWindowRect.minY
        case 6:
            x = captureWindowRect.midX
            y = captureWindowRect.minY
        case 7:
            x = captureWindowRect.maxX
            y = captureWindowRect.minY
        default:
            break
        }
        return CGPoint(x: x, y: y)
    }
    
    func dragDirectionFrom(point: CGPoint) -> Int {
        if captureWindowRect.width <= CGFloat(Self.kAdjustKnown * 2)
            || captureWindowRect.height <= CGFloat(Self.kAdjustKnown * 2) {
                if captureWindowRect.contains(point) {
                    return 8
                }
            }
        let innerRect = captureWindowRect.insetBy(dx: CGFloat(Self.kAdjustKnown), dy: CGFloat(Self.kAdjustKnown))
        if innerRect.contains(point) {
            return 8
        }
        
        let outerRect = captureWindowRect.insetBy(dx: -CGFloat(Self.kAdjustKnown), dy: -CGFloat(Self.kAdjustKnown))
        if !outerRect.contains(point) {
            return -1
        }
        var minDistance = pow(CGFloat(Self.kAdjustKnown), 2)
        var ret = -1
        for i in 0 ..< 8 {
            let dragPoint = dragPointCenter(index: i)
            let distance = ScreenshotUtil.distance(from: dragPoint, to: point)
            if distance < minDistance {
                minDistance = distance
                ret = i
            }
        }
        return ret
    }
    
    func setupToolClick() {
        snipView?.toolBox.actionClick = { [weak self] action in
            guard let `self` = self else { return }
            #warning("----")
            
        }
    }
    
    func startCapture(screen: NSScreen) {
        guard let window = window, let darkImage = darkImage else { return }
        doScreenshot(screen: screen)
        window.backgroundColor = NSColor(patternImage: darkImage)
        var screenFrame = screen.frame
        screenFrame.size.width /= 1
        screenFrame.size.height /= 1
        window.setFrame(screenFrame, display: true, animate: false)
        snipView = window.contentView as? ScreenshotView
        (window as? ScreenshotWindow)?.mouseDelegate = self
        self.snipView?.setupTrackingArea(rect: window.screen?.frame ?? .zero)
        NotificationCenter.default.addObserver(self, selector: #selector(onNotifyMouseChange(noti: )), name: .kNotifyMouseLocationChange, object: nil)
        showWindow(nil)
        captureAppScreen()
    }
    
    @objc private func onNotifyMouseChange(noti: Notification) {
//        if let manager = noti.userInfo?["content"] as? ScreenshotManager, manager == self { return }
//        if ScreenshotManager.shared.captureState == .highlight && window?.isVisible == true && ScreenshotUtil.point(point: NSEvent.mouseLocation, inRect: <#T##CGRect#>)
    }
}

extension ScreenshotWindowController: NSWindowDelegate {
    
}

extension ScreenshotWindowController: MouseEventProtocol {
    func mouseEventDown(with event: NSEvent) {
        
    }
    
    func mouseEventUp(with event: NSEvent) {
        
    }
    
    func mouseEventDragged(with event: NSEvent) {
        
    }
    
    func mouseEventMoved(with event: NSEvent) {
        
    }
}
