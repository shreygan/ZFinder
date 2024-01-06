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
        let contView = ContentView()
        let topView = NSHostingController(rootView: contView)
        topView.view.frame.size = CGSize(width: 300, height: 300)
        
        let customMenuItem = NSMenuItem()
        customMenuItem.view = topView.view
        menu.addItem(customMenuItem)
        menu.addItem(NSMenuItem.separator())
        
//        let buttonShortcutItem = NSMenuItem(title: "Button Shortcut", action: nil, keyEquivalent: "B")
//        buttonShortcutItem.target = nil
//        buttonShortcutItem.action = #selector(ContentViewModel.buttonAction)
//        menu.addItem(buttonShortcutItem)
        
        return menu
        
//        let cpView = ColorPickerView()
//        let t2View = NSHostingController(rootView: cpView)
//        t2View.view.frame.size = CGSize(width: 300, height: 300)
//
//        let cmi = NSMenuItem()
//        cmi.view = t2View.view
//        menu.addItem(cmi)
//        menu.addItem(NSMenuItem.separator())
//        
//        return menu
    }
}
