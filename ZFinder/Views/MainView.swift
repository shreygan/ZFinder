//
//  MainVie.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 1/4/24.
//

import SwiftUI
import AppKit
import Quartz

struct MainView: View {
    @State private var selectedPin: Pin?
    
    var body: some View {
        if selectedPin != nil {
            DetailView(pin: $selectedPin, resetSelectedPin: resetSelectedPin, openFinder: openFinder)
        } else {
            PinView(selectedPin: $selectedPin, openFinder: openFinder)
        }
        
        Spacer()
    }
    
    func openFinder(_ path: String) {
        let url = URL(fileURLWithPath: path)
        NSWorkspace.shared.open(url)
    }
    
    func resetSelectedPin() {
        DispatchQueue.main.async {
            selectedPin = nil
        }
    }
}

//#Preview {
//    MainView()
//}
