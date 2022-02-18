//
//  ScreenshotToolBox.swift
//  screenshot
//
//  Created by lian on 2022/2/9.
//

import AppKit

class ScreenshotToolBox: NSView {
    
    lazy var buttons: [ScreenshotImageButton] = [.shapeRect, .shapeEllipse, .shapeArrow, .editPen, .editText, .cancel, .sure].map { action in
        return createImageButton(action: action)
    }
    
    var actionClick: ((Action) -> Void)?
    
    override var frame: NSRect {
        didSet {
            let step: CGFloat = 35
            let margin: CGFloat = 10
            for (index, btn) in buttons.enumerated() {
                btn.frame = CGRect(x: margin + step * CGFloat(index), y: 0, width: 28, height: 26)
            }
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        buttons.forEach { btn in
            addSubview(btn)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let path = NSBezierPath.init(roundedRect: bounds, xRadius: 3, yRadius: 3)
        path.setClip()
        NSColor.init(calibratedWhite: 1, alpha: 0.3).setFill()
        bounds.fill()
    }
    
    private func createImageButton(action: Action) -> ScreenshotImageButton {
        let button = ScreenshotImageButton()
        button.image = action.image
        button.tag = action.rawValue
        button.target = self
        button.action = #selector(onClickAction(sender:))
        return button
    }
    
    @objc private func onClickAction(sender: ScreenshotImageButton) {
        buttons.forEach { button in
            if let action = Action(rawValue: button.tag) {
                button.image = action.image
            }
        }
        guard let action = Action(rawValue: sender.tag) else { return }
        sender.image = action.selectImage
        actionClick?(action)
    }
    
    override func mouseDown(with event: NSEvent) {}
}

extension ScreenshotToolBox {
    enum Action: Int, CaseIterable {
        case cancel
        case sure
        case shapeRect
        case shapeEllipse
        case shapeArrow
        case editPen
        case editText
        
        var image: NSImage? {
            switch self {
            case .cancel:
                return NSImage(named: "ScreenCapture_toolbar_cross_normal")
            case .sure:
                return NSImage(named: "ScreenCapture_toolbar_tick_normal")
            case .shapeRect:
                return NSImage(named: "ScreenCapture_toolbar_rect_ineffect")
            case .shapeEllipse:
                return NSImage(named: "ScreenCapture_toolbar_ellipse_ineffect")
            case .shapeArrow:
                return NSImage(named: "ScreenCapture_toolbar_arrow_ineffect")
            case .editPen:
                return NSImage(named: "ScreenCapture_toolbar_pen_ineffect")
            case .editText:
                return NSImage(named: "ScreenCapture_toolbar_text_ineffect")
            }
        }
        
        var selectImage: NSImage? {
            switch self {
            case .cancel:
                return image
            case .sure:
                return image
            case .shapeRect:
                return NSImage(named: "ScreenCapture_toolbar_rect_effect")
            case .shapeEllipse:
                return NSImage(named: "ScreenCapture_toolbar_ellipse_effect")
            case .shapeArrow:
                return NSImage(named: "ScreenCapture_toolbar_arrow_effect")
            case .editPen:
                return NSImage(named: "ScreenCapture_toolbar_pen_effect")
            case .editText:
                return NSImage(named: "ScreenCapture_toolbar_text_effect")
            }
        }
    }
}
