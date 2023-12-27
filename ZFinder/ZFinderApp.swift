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
        statusBarItem.button?.image = NSImage(systemSymbolName: "testtube.2", accessibilityDescription: "logo")
        statusBarItem.menu = menu.createMenu()
    }
}


//@main
//struct swiftui_menu_barApp: App {
//    @State var currentNumber: String = "1"
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//        MenuBarExtra(currentNumber, systemImage: "\(currentNumber).circle") {
//            Button("One") {
//                currentNumber = "1"
//            }
//            .keyboardShortcut("1")
//
//            Button("Two") {
//                currentNumber = "2"
//            }
//            .keyboardShortcut("2")
//
//            Button("Three") {
//                currentNumber = "3"
//            }
//            .keyboardShortcut("3")
//
//        }
//    }
//}
