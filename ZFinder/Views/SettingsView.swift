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
    
    @State private var showDeleteConf = false
    
    let pinnedManager = PinnedManager()
    
    var body: some View {
        Button("Delete All Pins") {
            showDeleteConf = true
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { newValue in
            AppDelegate.instance.setActivationPolicyAccessory()
        }
        .buttonStyle(BorderedButtonStyle())
        .confirmationDialog("Are you sure you want to delete all pins?", isPresented: $showDeleteConf) {
            Button("Delete", role: .destructive) {
//                print("DELETING")
                pinnedManager.deleteAllPins()
            }
        }
        .padding(.top, 40)
        .padding(.bottom, 30)
        
        Toggle(isOn: $hideFileExtensions) {
            Text("\(hideFileExtensions ? "Hide" : "Show") File Extensions")
        }
//        .toggleStyle(())
        
//        Toggle(isOn: $launchAtLogin) {
//            Text("Launch ZFinder at Login")
//        }
//        .toggleStyle(ButtonToggleStyle())
//        .padding(.vertical, 30)
        LaunchAtLogin.Toggle()
            .padding(.vertical, 30)
        
//        Tottl3(ison: )
        
//        Spacer()

        
        Spacer()
    }
}

//#Preview {
//    SettingsView()
//}
