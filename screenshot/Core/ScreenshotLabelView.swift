//
//  ScreenshotLabelView.swift
//  screenshot
//
//  Created by Xinbo Lian on 2022/2/5.
//

import AppKit

class ScreenshotLabelView: NSView {
    var text: String?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let bgPath = NSBezierPath(roundedRect: bounds, xRadius: 6, yRadius: 6)
        bgPath.setClip()
        NSColor(calibratedWhite: 0, alpha: 0.8).setFill()
        bounds.fill()
        guard let text = text else { return }
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: NSColor(calibratedWhite: 1, alpha: 1), .font: ScreenshotManager.shared.configure.font]
        let attrString = NSAttributedString(string: text, attributes: attributes)
        let stringRect = attrString.boundingRect(with: bounds.size, options: [.usesFontLeading, .truncatesLastVisibleLine, .usesLineFragmentOrigin])
        let x = (bounds.size.width - stringRect.size.width) / 2
        let y = (bounds.size.height - stringRect.size.height) / 2
        attrString.draw(at: NSPoint(x: x, y: y))
    }
}
