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
    }
}


class AppDelegate: NSObject, NSApplicationDelegate {
    static private(set) var instance: AppDelegate!
    lazy var statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let menu = ApplicationMenu()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.instance = self
        statusBarItem.button?.image = NSImage(systemSymbolName: "folder.fill", accessibilityDescription: "logo")
        statusBarItem.menu = menu.createMenu()
    }
}
