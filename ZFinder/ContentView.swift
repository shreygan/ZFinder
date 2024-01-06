//
//  ContentView.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 12/7/23.
//

import SwiftUI

class ContentViewModel: NSObject {
    @objc func buttonAction() {
        print("Button action triggered by shortcut!")
    }
}

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    
    var body: some View {
        MainView()
        
        Spacer()
    }
}

//#Preview {
//    ContentView()
//}
