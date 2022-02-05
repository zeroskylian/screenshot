//
//  MouseEventProtocol.swift
//  screenshot
//
//  Created by Xinbo Lian on 2022/2/5.
//

import AppKit

protocol MouseEventProtocol: AnyObject {
    
    func mouseEventDown(with event: NSEvent)
    
    func mouseEventUp(with event: NSEvent)
    
    func mouseEventDragged(with event: NSEvent)
    
    func mouseEventMoved(with event: NSEvent)
}
