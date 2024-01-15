//
//  ApplicationMenu.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 12/8/23.
//

import SwiftUI

class ApplicationMenu: NSObject {
    var controller: NSWindowController? = nil
    
    let menu = NSMenu()
    
    func createMenu() -> NSMenu {
        let contView = MainView()
        let topView = NSHostingController(rootView: contView)
        topView.view.frame.size = CGSize(width: 300, height: 300)
        
        let customMenuItem = NSMenuItem()
        customMenuItem.view = topView.view
        menu.addItem(customMenuItem)
        menu.addItem(NSMenuItem.separator())
        
        let settings = NSMenuItem(title: "Preferences", action: #selector(openSettings), keyEquivalent: ",")
        settings.target = self
        menu.addItem(settings)
        
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        return menu
    }
    
    @objc func openSettings() {
        if controller == nil {
            let settingsView = SettingsView()
            controller = ExternalWindowController(rootView: settingsView)
            controller!.window?.title = "ZFinder Settings"
            controller!.showWindow(nil)
        }
        
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        controller!.window?.orderFrontRegardless()
        controller!.window?.makeKeyAndOrderFront(self)
        controller!.window?.isReleasedWhenClosed = false
        controller!.window?.titlebarAppearsTransparent = true
    }
}
