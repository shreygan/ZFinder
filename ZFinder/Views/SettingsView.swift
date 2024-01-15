//
//  SettingsView.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 1/11/24.
//

import SwiftUI
import LaunchAtLogin

struct SettingsView: View {    
    @AppStorage("hideFileExtensions") private var hideFileExtensions = false
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    
    @State private var isShowingDeleteConfirmation = false
    
    let pinnedManager = PinnedManager()
    
    var body: some View {
        Button("Delete All Pins") {
            isShowingDeleteConfirmation = true
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { newValue in
            AppDelegate.instance.setActivationPolicyAccessory()
        }
        .buttonStyle(BorderedButtonStyle())
        .confirmationDialog("Are you sure you want to delete all pins?", isPresented: $isShowingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                pinnedManager.deleteAllPins()
            }
        }
        .padding(.top, 40)
        .padding(.bottom, 30)
        
        Toggle(isOn: $hideFileExtensions) {
            Text("\(hideFileExtensions ? "Hide" : "Show") File Extensions")
        }
        
        LaunchAtLogin.Toggle()
            .padding(.vertical, 30)
        
        Spacer()
    }
}

//#Preview {
//    SettingsView()
//}
