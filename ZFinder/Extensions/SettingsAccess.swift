//
//  SettingsAccess.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 1/10/24.
//

import SwiftUI 

class ExternalWindowController<RootView : View>: NSWindowController {
    convenience init(rootView: RootView) {
        let hostingController = NSHostingController(rootView: rootView.frame(width: 250, height: 225))
        let window = NSWindow(contentViewController: hostingController)
        window.setContentSize(NSSize(width: 250, height: 225))
        self.init(window: window)
    }
}
