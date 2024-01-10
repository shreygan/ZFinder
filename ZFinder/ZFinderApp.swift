//
//  ZFinderApp.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 12/7/23.
//

import SwiftUI
import KeyboardShortcuts

@main
struct ZFinderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
//        WindowGroup("Shortcut Input", for: UUID.self) { $pin in
//            ShortcutView(pinID: pin)
//        }
    }
}


class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    static private(set) var instance: AppDelegate!
    lazy var statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    let menu = ApplicationMenu()
    
//    var shortcutWindow: NSWindow!
    var shortcutWindows: [NSNumber: NSWindow] = [:]
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.instance = self
        statusBarItem.button?.image = NSImage(systemSymbolName: "folder.fill", accessibilityDescription: "logo")
        statusBarItem.menu = menu.createMenu()
    }
    
    @objc func openShortcutWindow(_ pinID: NSNumber?) {
        if let existingWindow = shortcutWindows[pinID ?? -1] {
            existingWindow.makeKeyAndOrderFront(nil)
        } else {
            let pin = PinnedManager().getPinByPos(pinID?.intValue)
            
            print(pinID ?? "NO ID FOUND")
            print(pin?.description ?? "NO PIN FOUND")
            
            let shortcutView = ShortcutView(pin: pin)
            let newWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 50, height: 50),
                                     styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                                     backing: .buffered,
                                     defer: false)
            
            newWindow.center()
            newWindow.contentView = NSHostingView(rootView: shortcutView)
            newWindow.isReleasedWhenClosed = false
            
            newWindow.title = "Set Shortcut for '\(pin?.name ?? "")'"
            
//            shortcutWindows[pinID ?? ] = newWindow
            
            let visualEffect = NSVisualEffectView()
            visualEffect.blendingMode = .behindWindow
            visualEffect.state = .active
//            visualEffect.material = .dark
            visualEffect.appearance = NSAppearance(named: .vibrantDark)
            newWindow.contentView = visualEffect

            newWindow.titlebarAppearsTransparent = true
            newWindow.styleMask.insert(.fullSizeContentView)
            
            newWindow.makeKeyAndOrderFront(nil)
            
            
//            if shortcutWindow == nil {
//                let shortcutView = ShortcutView()
//
//                shortcutWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 50, height: 50),
//                                          styleMask: [.titled, .closable, .fullSizeContentView],
//                                          backing: .buffered,
//                                          defer: false)
//                shortcutWindow.center()
//                shortcutWindow.contentView = NSHostingView(rootView: shortcutView)
//                //            shortcutWindow.title = title ?? "NO TITLE"
//                //            print("TITLE: \(title ?? "NO TITLE")")
//                
//                shortcutWindow.isReleasedWhenClosed = false
//            }
//            shortcutWindow.makeKeyAndOrderFront(nil)
        }
    }
}
