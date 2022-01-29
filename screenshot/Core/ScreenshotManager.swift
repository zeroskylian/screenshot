//
//  ScreenshotManager.swift
//  screenshot
//
//  Created by Xinbo Lian on 2022/1/28.
//

import Foundation

class ScreenshotManager {
    static let shared = ScreenshotManager(id: "default")
    
    let id: String
    
    init(id: String) {
        self.id = id
    }
    
}
