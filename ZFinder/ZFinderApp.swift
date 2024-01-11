//
//  ZFinderApp.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 12/7/23.
//

import SwiftUI
import KeyboardShortcuts
import SettingsAccess
import Combine

@main
struct ZFinderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            MainView()
        }
    }
}


class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    static private(set) var instance: AppDelegate!
    lazy var statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    let menu = ApplicationMenu()
    
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
            
            let visualEffect = NSVisualEffectView()
            visualEffect.blendingMode = .behindWindow
            visualEffect.state = .active
            visualEffect.appearance = NSAppearance(named: .vibrantDark)
            newWindow.contentView = visualEffect

            newWindow.titlebarAppearsTransparent = true
            newWindow.styleMask.insert(.fullSizeContentView)
            
            newWindow.makeKeyAndOrderFront(nil)
        }
    }
}


struct AppState {
    let openSettingsSignal = PassthroughSubject<Void, Never>()
}


