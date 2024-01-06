//
//  ZFinderApp.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 12/7/23.
//

import SwiftUI

@main
struct ZFinderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//        .commands {
////            CommandGroup(after: .appInfo) {
////                Button(action: {
////                    print("OMG BUTTON")
////                    
////                }) {
////                    Text("HELLO")
////                }
////            }
//            CommandMenu("Menu") {
//                Button(action: {
//                    print("ACTION 1")
//                }) {
//                    Text("Action")
//                }
//                Button(action: {
//                    print("ACTION 2")
//                }) {
//                    Text("Another action")
//                }
//            }
//        }
    
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
