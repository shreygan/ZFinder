//
//  ShortcutView.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 1/9/24.
//

import SwiftUI
import KeyboardShortcuts

struct ShortcutView: View {
    @State private var input = ""
    
    @State var pin: Pin?
    
    var body: some View {
        VStack {
            HStack {
                Text("\(pin?.name ?? "")")
                    .font(.title3)
                    .fontWeight(.heavy)
                    .padding()
            }
            
            Spacer()
            
//            KeyboardShortcuts.Recorder(for: "TEST")
            
            Spacer()
        }
        .frame(width: 300, height: 300)
    }
}

#Preview {
    ShortcutView(pin: PinnedManager().getPinned()[0])
}

