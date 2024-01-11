//
//  SettingsView.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 1/11/24.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("setting") private var setting = false
    
    var body: some View {
        Spacer()
        
        Text("TESTING")
        
        Spacer()
        
        Toggle(isOn: $setting) {
            Text("Name")
        }
        .toggleStyle(ButtonToggleStyle())

        
        Spacer()
    }
}

#Preview {
    SettingsView()
}
