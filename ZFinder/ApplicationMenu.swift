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
        topView.view.frame.size = CGSize(width: 400, height: 400)
        
        let customMenuItem = NSMenuItem()
        customMenuItem.view = topView.view
        menu.addItem(customMenuItem)
        menu.addItem(NSMenuItem.separator())
        
        return menu
    }
}
