//
//  ScreenshotManager.swift
//  screenshot
//
//  Created by Xinbo Lian on 2022/1/28.
//

import Foundation
import AppKit

class ScreenshotManager {
    
    static let shared = ScreenshotManager(id: "default")
    
    var windowControllerArray: [ScreenshotWindowController]  = []
    
    var arrayRect: [[String: Any]] = []
    
    var captureState: CaptureState = .idle
    
    var configure: DrawConfigure = .init()
    
    var draw: Draw = .rect
    
    var isWorking: Bool = false
    
    let id: String
    
    init(id: String) {
        self.id = id
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(screenChanged(noti:)), name: NSWorkspace.activeSpaceDidChangeNotification, object: NSWorkspace.shared)
        NotificationCenter.default.addObserver(self, selector: #selector(screenChanged(noti:)), name: NSApplication.didChangeScreenParametersNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
    
    func start() {
        guard !isWorking else { return }
        guard let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly], 0) as? [[String: Any]] else { return }
        isWorking = true
        arrayRect.removeAll()
        arrayRect.append(contentsOf: windows)
        for screen in NSScreen.screens {
            let controller = ScreenshotWindowController()
            let window = ScreenshotWindow(contentRect: screen.frame, styleMask: .nonactivatingPanel, backing: .buffered, defer: false, screen: screen)
            controller.window = window
            let view = ScreenshotView(frame: CGRect(x: 0, y: 0, width: screen.frame.width, height: screen.frame.height))
            window.contentView = view
            windowControllerArray.append(controller)
            captureState = .highlight
            controller.startCapture(screen: screen)
        }
    }
    
    func end(image: NSImage?) {
        guard isWorking else { return }
        isWorking = false
        for controller in windowControllerArray {
            controller.window?.orderOut(nil)
        }
        clearAllController()
        NotificationCenter.default.post(name: .kNotifyCaptureEnd, object: image)
    }
    
    @objc private func screenChanged(noti: Notification) {
        guard isWorking else { return }
        end(image: nil)
    }
    
    private func clearAllController() {
        for controller in windowControllerArray {
            let window = controller.window
            window?.windowController = nil
            controller.window = nil
        }
        windowControllerArray.removeAll()
    }
}
