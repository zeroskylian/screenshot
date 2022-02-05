//
//  ScreenshotImageButton.swift
//  screenshot
//
//  Created by Xinbo Lian on 2022/2/5.
//

import AppKit
 
class ScreenshotImageButton: NSImageView {
    override func mouseDown(with event: NSEvent) {
        guard let action = self.action else { return super.mouseDown(with: event) }
        NSApp.sendAction(action, to: target, from: self)
    }
}
