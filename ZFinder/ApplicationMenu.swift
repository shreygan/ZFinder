//
//  ApplicationMenu.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 12/8/23.
//

import Foundation
import SwiftUI

class ApplicationMenu: NSObject {
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
        
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        return menu
    }
    
    @objc func printTest() {
        print("Test")
    }
}
