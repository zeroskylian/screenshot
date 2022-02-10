//
//  ScreenshotWindow.swift
//  screenshot
//
//  Created by Xinbo Lian on 2022/2/1.
//

import AppKit

class ScreenshotWindow: NSPanel {
    
    weak var mouseDelegate: MouseEventProtocol?
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: .buffered, defer: false)
        acceptsMouseMovedEvents = true
        isFloatingPanel = true
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        isMovableByWindowBackground = false
        isExcludedFromWindowsMenu = true
        alphaValue = 1
        isOpaque = false
        hasShadow = false
        hidesOnDeactivate = false
        isRestorable = false
        disableSnapshotRestoration()
        level = .init(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
        isMovable = false
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
    
    override func mouseDown(with event: NSEvent) {
        mouseDelegate?.mouseEventDown(with: event)
    }
    
    override func mouseUp(with event: NSEvent) {
        mouseDelegate?.mouseEventUp(with: event)
    }
    override func mouseMoved(with event: NSEvent) {
        mouseDelegate?.mouseEventMoved(with: event)
    }
    
    override func mouseDragged(with event: NSEvent) {
        mouseDelegate?.mouseEventDragged(with: event)
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == ScreenshotManager.Constant.keyEscCode {
            orderOut(nil)
            ScreenshotManager.shared.end(image: nil)
            return
        }
        super.keyDown(with: event)
    }
}
