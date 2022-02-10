//
//  ViewController.swift
//  screenshot
//
//  Created by Xinbo Lian on 2022/1/28.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(endCap(noti:)), name: .kNotifyCaptureEnd, object: nil)
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @objc private func endCap(noti: Notification) {
        guard let image = noti.object as? NSImage else { return }
        do {
            try image.tiffRepresentation?.write(to: URL(fileURLWithPath: "/Users/a1/Downloads/1.jpg"))
        } catch {
            print(error)
        }
    }
    @IBAction func buttonActin(_ sender: NSButton) {
        ScreenshotManager.shared.start()
    }
    
}
