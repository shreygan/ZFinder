//
//  ContentView.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 12/7/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, world!!")
//        }
        PinnedView()
            .padding()
//        SearchView()
//            .padding()
    }
}

#Preview {
    ContentView()
}







//import SwiftUI
//
//struct ContentView: View {
//    var body: some View {
//        Menu {
//            Button("Menu Item 1", action: menuItem1Clicked)
//            Divider()
//            Button("Quit", action: quitClicked)
//        } label: {
//            Label("Your App", systemImage: "") // Replace with your app icon
//        }
//        .padding()
//    }
//
//    func menuItem1Clicked() {
//        print("Menu Item 1 Clicked")
//        // Add your code here
//    }
//
//    func quitClicked() {
//        NSApplication.shared.terminate(self)
//    }
//}
