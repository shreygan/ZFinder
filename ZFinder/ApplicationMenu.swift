//
//  ApplicationMenu.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 12/8/23.
//

import Foundation
import SwiftUI
import SettingsAccess

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
        
//        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
//            print("MONITORING: \(event)")
//            if let characters = event.charactersIgnoringModifiers {
//                print("Pressed key: \(characters)")
//            }
//            return event
//        }
        
//        let test = NSMenuItem(title: "test", action: #selector(printTest), keyEquivalent: "w")
//        test.target = self
//        menu.addItem(test)
        
        let settings = NSMenuItem(title: "Preferences", action: #selector(openSettings), keyEquivalent: ",")
        settings.target = self
        menu.addItem(settings)
        
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        return menu
    }
    
    @objc func printTest() {
        print("Test")
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

//let newWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 50, height: 50),
//                         styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
//                         backing: .buffered,
//                         defer: false)
//
//newWindow.center()
//newWindow.contentView = NSHostingView(rootView: shortcutView)
//newWindow.isReleasedWhenClosed = false
//
//newWindow.title = "Set Shortcut for '\(pin?.name ?? "")'"
//
//let visualEffect = NSVisualEffectView()
//visualEffect.blendingMode = .behindWindow
//visualEffect.state = .active
//visualEffect.appearance = NSAppearance(named: .vibrantDark)
//newWindow.contentView = visualEffect
//
//newWindow.titlebarAppearsTransparent = true
//newWindow.styleMask.insert(.fullSizeContentView)
//
//newWindow.makeKeyAndOrderFront(nil)

