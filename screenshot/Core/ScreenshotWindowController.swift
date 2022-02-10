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
                let windowRect = dir[kCGWindowBounds as String]
                let cgrect = try CGRect(dictionaryRepresentation: windowRect.unwrap() as! CFDictionary)
                let rect = try ScreenshotUtil.cgWindowRectToScreenRect(windowRect: cgrect.unwrap())
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
            switch action {
            case .shapeRect:
                ScreenshotManager.shared.draw = .rect
                ScreenshotManager.shared.captureState = .edit
                self.snipView?.setupDrawPath()
                self.snipView?.needsDisplay = true
            case .shapeEllipse:
                ScreenshotManager.shared.draw = .ellipse
                ScreenshotManager.shared.captureState = .edit
                self.snipView?.setupDrawPath()
                self.snipView?.needsDisplay = true
            case .shapeArrow:
                ScreenshotManager.shared.draw = .arrow
                ScreenshotManager.shared.captureState = .edit
                self.snipView?.setupDrawPath()
                self.snipView?.needsDisplay = true
            case .editPen:
                ScreenshotManager.shared.draw = .point
                ScreenshotManager.shared.captureState = .edit
                self.snipView?.setupDrawPath()
                self.snipView?.needsDisplay = true
            case .editText:
                ScreenshotManager.shared.draw = .text
                ScreenshotManager.shared.captureState = .edit
                self.snipView?.setupDrawPath()
                self.snipView?.needsDisplay = true
            case .cancel:
                ScreenshotManager.shared.end(image: nil)
            case .sure:
                self.onCaptureComplete()
            }
        }
    }
    
    func startCapture(screen: NSScreen) {
        guard let window = window else { return }
        doScreenshot(screen: screen)
        guard let darkImage = darkImage else  { return }
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
        if let manager = noti.userInfo?["content"] as? ScreenshotManager, manager === self { return }
        guard let window = window, let screen = window.screen else { return }
        if ScreenshotManager.shared.captureState == .highlight && window.isVisible == true && ScreenshotUtil.point(point: NSEvent.mouseLocation, inRect: screen.frame) {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.showWindow(nil)
                self.captureAppScreen()
            }
        }
    }
    
    override func mouseDown(with event: NSEvent) {
//        super.mouseDown(with: event)
        let captureState = ScreenshotManager.shared.captureState
        if event.clickCount == 2 {
            if captureState != .highlight {
                onCaptureComplete()
            }
        }
        
        if captureState == .highlight {
            ScreenshotManager.shared.captureState = .firstMouseDown
            startPoint = NSEvent.mouseLocation
            snipView?.setupTool()
            setupToolClick()
        } else if captureState == .adjust {
            startPoint = NSEvent.mouseLocation
            captureWindowRect = ScreenshotUtil.uniform(rect: captureWindowRect)
            dragWindowRect = captureWindowRect
            dragDirection = dragDirectionFrom(point: NSEvent.mouseLocation)
        }
        
        if ScreenshotManager.shared.captureState != .edit {
            snipView?.hideToolkit()
        } else {
            let mouseLocation = NSEvent.mouseLocation
            guard captureWindowRect.contains(mouseLocation) else { return }
            if ScreenshotManager.shared.draw == .text {
                if editTextView?.superview != nil {
                    endEditText()
                    return
                }
            }
            rectBeginPoint = mouseLocation
            rectDrawing = true
            linePoints = []
            if ScreenshotManager.shared.draw == .text {
                if editTextView?.superview == nil {
                    editTextView = NSTextView(frame: .zero)
                    editTextView?.backgroundColor = .clear
                    editTextView?.wantsLayer = true
                    editTextView?.layer?.borderColor = ScreenshotManager.shared.configure.color.cgColor
                    editTextView?.layer?.borderWidth = 0.5
                    editTextView?.font = ScreenshotManager.shared.configure.font
                    editTextView?.insertionPointColor = .red
                    editTextView?.textContainerInset = .zero
                    snipView?.addSubview(editTextView!)
                    editTextView?.frame = CGRect(x: mouseLocation.x, y: mouseLocation.y - 12, width: 120, height: 24)
                    rectBeginPoint = CGPoint(x: mouseLocation.x, y: mouseLocation.y - 12 + 24)
                    editTextView?.setSelectedRange(NSRange(location: 0, length: 0))
                    window?.makeFirstResponder(editTextView)
                }
            }
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        let captureState = ScreenshotManager.shared.captureState
        if captureState == .firstMouseDown || captureState == .readyAdjust {
            ScreenshotManager.shared.captureState = .adjust
            snipView?.needsDisplay = true
        }
        
        if captureState != .edit {
            snipView?.showToolkit()
            snipView?.hideTip()
            snipView?.needsDisplay = true
        } else {
            if rectDrawing {
                rectDrawing = false
                rectEndPoint = NSEvent.mouseLocation
                if ScreenshotManager.shared.draw == .point {
                    let info = ScreenshotManager.DrawPathInfo(draw: ScreenshotManager.shared.draw, startPoint: .zero, endPoint: .zero, points: linePoints, editText: nil)
                    snipView?.pathView?.rectArray.append(info)
                } else {
                    let info = ScreenshotManager.DrawPathInfo(draw: ScreenshotManager.shared.draw, startPoint: rectBeginPoint, endPoint: rectEndPoint, points: nil, editText: nil)
                    snipView?.pathView?.rectArray.append(info)
                }
                let rect = window?.convertFromScreen(captureWindowRect) ?? .zero
                snipView?.setNeedsDisplay(rect)
            }
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        let captureState = ScreenshotManager.shared.captureState
        if captureState == .firstMouseDown || captureState == .readyAdjust {
            ScreenshotManager.shared.captureState = .readyAdjust
            endPoint = NSEvent.mouseLocation
            let rect1 = CGRect(x: self.startPoint.x, y: self.startPoint.y, width: 1, height: 1)
            let rect2 = CGRect(x: self.endPoint.x, y: self.endPoint.y, width: 1, height: 1)
            captureWindowRect = rect1.union(rect2)
            captureWindowRect = captureWindowRect.intersection(window?.frame ?? .zero)
            redrawView(image: originImage)
        } else if captureState == .edit {
            if rectDrawing {
                rectEndPoint = NSEvent.mouseLocation
                if ScreenshotManager.shared.draw == .point {
                    linePoints.append(rectEndPoint)
                    snipView?.pathView?.currentInfo = ScreenshotManager.DrawPathInfo(draw: ScreenshotManager.shared.draw, startPoint: .zero, endPoint: .zero, points: linePoints, editText: nil)
                } else {
                    let info = ScreenshotManager.DrawPathInfo(draw: ScreenshotManager.shared.draw, startPoint: rectBeginPoint, endPoint: rectEndPoint, points: nil, editText: nil)
                    snipView?.pathView?.rectArray.append(info)
                }
            }
        } else if captureState == .adjust {
            if dragDirection == -1 {
                return
            }
            let mouseLocation = NSEvent.mouseLocation
            endPoint = mouseLocation
            let deltaX = endPoint.x - startPoint.x
            let deltaY = endPoint.y - startPoint.y
            var rect = dragWindowRect
            switch dragDirection {
            case 8:
                rect = rect.offsetBy(dx: deltaX, dy: deltaY)
                if window?.frame.contains(rect) == false {
                    let rcOrigin = window?.frame ?? .zero
                    rect.origin.x = max(rect.origin.x, rcOrigin.origin.x)
                    rect.origin.y = max(rect.origin.y, rcOrigin.origin.y)
                    rect.origin.x = min(rect.origin.x, rcOrigin.origin.x + rcOrigin.width - rect.width)
                    rect.origin.y = min(rect.origin.y, rcOrigin.origin.y + rcOrigin.height - rect.height)
                    endPoint = CGPoint(x: startPoint.x + rect.origin.x - dragWindowRect.origin.x, y: startPoint.y + rect.origin.y - dragWindowRect.origin.y)
                    
                }
            case 7:
                rect.origin.y += deltaY
                rect.size.width += deltaX
                rect.size.height -= deltaY
            case 6:
                rect.origin.y += deltaY
                rect.size.height -= deltaY
            case 5:
                rect.origin.x += deltaX
                rect.origin.y += deltaY
                rect.size.width -= deltaX
                rect.size.height -= deltaY
            case 4:
                rect.size.width += deltaX
            case 3:
                rect.origin.x += deltaX
                rect.size.width -= deltaX
            case 2:
                rect.size.width += deltaX
                rect.size.height += deltaY
            case 1:
                rect.size.height += deltaY
            case 0:
                rect.origin.x += deltaX
                rect.size.width -= deltaX
                rect.size.height += deltaY
            default:
                break
            }
            dragWindowRect = rect
            rect.size.width = max(1, rect.size.width)
            rect.size.height = max(1, rect.size.height)
            captureWindowRect = ScreenshotUtil.uniform(rect: rect)
            startPoint = endPoint
            snipView?.showTip()
            redrawView(image: originImage)
        }
    }
    
    override func mouseMoved(with event: NSEvent) {
        if ScreenshotManager.shared.captureState == .highlight {
            captureAppScreen()
        }
    }
    
    private func endEditText() {
        if ScreenshotManager.shared.draw == .text {
            if editTextView?.superview != nil {
                editTextView?.removeFromSuperview()
                rectDrawing = false
                let editTextFrame = self.editTextView?.frame ?? .zero
                rectEndPoint = CGPoint(x: self.rectBeginPoint.x + editTextFrame.size.width, y: self.rectBeginPoint.y - editTextFrame.size.height)
                let info = ScreenshotManager.DrawPathInfo(draw: ScreenshotManager.shared.draw, startPoint: rectBeginPoint, endPoint: rectEndPoint, points: nil, editText: editTextView?.string)
                snipView?.pathView?.rectArray.append(info)
                let rect = window?.convertFromScreen(captureWindowRect)
                snipView?.setNeedsDisplay(rect ?? .zero)
            }
        }
    }
    
    private func onCaptureComplete() {
        guard let originImage = originImage, let window = window else {
            return
        }
        originImage.lockFocus()
        var rect = captureWindowRect.intersection(window.frame)
        rect = window.convertFromScreen(rect)
        rect = rect.integral
        snipView?.pathView?.drawFinishComment(in: rect)
        let bits = NSBitmapImageRep(focusedViewRect: rect)
        originImage.unlockFocus()
        let imageProps: [NSBitmapImageRep.PropertyKey: Any] = [NSBitmapImageRep.PropertyKey.compressionFactor: 1]
        guard let imageData = bits?.representation(using: .jpeg, properties: imageProps) else {
            window.orderOut(nil)
            return
        }
        if let image = NSImage(data: imageData) {
            let pasteBoard = NSPasteboard.general
            pasteBoard.clearContents()
            pasteBoard.writeObjects([image])
            ScreenshotManager.shared.end(image: image)
        }
        window.orderOut(nil)
    }
}

extension ScreenshotWindowController: NSWindowDelegate {
    
}

extension ScreenshotWindowController: MouseEventProtocol {
    func mouseEventDown(with event: NSEvent) {
        mouseDown(with: event)
    }
    
    func mouseEventUp(with event: NSEvent) {
        mouseUp(with: event)
    }
    
    func mouseEventDragged(with event: NSEvent) {
        mouseDragged(with: event)
    }
    
    func mouseEventMoved(with event: NSEvent) {
        mouseMoved(with: event)
    }
}
