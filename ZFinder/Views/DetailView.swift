//
//  DetailView.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 1/4/24.
//

import SwiftUI
import QuickLook
import KeyboardShortcuts

struct DetailView: View {
    @State private var hoveredComp: Int?
    @State private var hoveredColor: CustomColor?
    @State private var hoveringBack = false
    @State private var hoveringType = false
    @State private var hoveringPreview = false
    @State private var hoveringTrash = false
    @State private var showEditButton = false
    @State private var hoveringEditButton = false
    @State private var editing = false
    @State private var editedText = ""
//    @State private var customShortcut: KeyboardShortcuts.Shortcut?
    @State private var shortcutWindowOpen = false
    @State private var shortcutWindowInput = ""
    
    @State private var pinned: [Pin]
    @State var url: URL?
    
    @Binding var pin: Pin?
    
    @FocusState private var editingFocused: Bool
    
    @Environment(\.openWindow) var openWindow
    
    var resetSelectedPin: () -> Void
    var openFinder: (String) -> Void
    
    let pinnedManager = PinnedManager()
    
    init(pin: Binding<Pin?>, resetSelectedPin: @escaping () -> Void, openFinder: @escaping (String) -> Void) {
        _pin = pin
        self.resetSelectedPin = resetSelectedPin
        self.openFinder = openFinder
        _pinned = State(initialValue: pinnedManager.getPinned())
        _editedText = State(initialValue: _pin.wrappedValue?.name ?? "")
    }
    
    var body: some View {
        HStack {
            Button(action: {
                resetSelectedPin()
            }) {
                Image(systemName: "chevron.backward")
                    .font(hoveringBack ? .title2 : .title3)
                    .frame(width: 12.5, height: 12.5)
            }
            .buttonStyle(.borderless)
            .padding(.leading, 5)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.1)) {
                    hoveringBack = hovering
                }
            }
            .onDisappear {
                resetSelectedPin()
            }
            
            if let pin = pin {
                Image(systemName: pin.file ? extToSFSymbol(ext: pin.fileType) : "folder")
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(pin.file ? .gray : .blue)
                    .padding(.leading, 5)
                    .padding(.trailing, -2)
                    .font(hoveringType ? .title2 : .title3)
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            hoveringType = hovering
                        }
                    }
                    .onTapGesture(count: 2) {
                        url = (url == nil ? URL(fileURLWithPath: pin.path.path(percentEncoded: false)) : nil)
                    }
                    .onTapGesture {
                        if url == nil {
                            openFinder(pin.path.path(percentEncoded: false))
                        } else {
                            url = nil
                        }
                    }
            }
            
            HStack {
                if showEditButton {
                    Button(action: {
                        editing.toggle()
                        editedText = pin?.name ?? ""
                        editingFocused.toggle()
                    }) {
                        Image(systemName: "pencil")
                            .font(hoveringEditButton ? .title2 : .title3)
                            .frame(width: 12.5, height: 12.5)
                    }
                    .buttonStyle(.borderless)
                    .padding(.leading, 1)
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            hoveringEditButton = hovering
                        }
                    }
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    if editing {
                        TextField("\(editedText)", text: $editedText) {
                            setPinName(editedText)
                            editing = false
                        }
                        .focused($editingFocused)
                        .font(.title3)
                        .fontWeight(.heavy)
                        .padding(2)
                        .padding(.horizontal, 2)
                        .textFieldStyle(PlainTextFieldStyle())
                        .background (
                            RoundedRectangle(cornerRadius: 8)
                                .fill(pin?.color.color.opacity(0.2) ?? Color.gray)
                        )
                        
                    } else {
                        Text(pin?.name ?? "")
                            .font(.title3)
                            .fontWeight(.heavy)
                            .padding(3)
                            .padding(.horizontal, 2)
                            .background (
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(pin?.color.color.opacity(0.4) ?? Color.gray)
                            )
                    }
                }
                .padding(.trailing, 5)
            }
            .onHover { hovering in
                if hovering || editing {
                    withAnimation(.easeInOut(duration: 0.3).delay(1)) {
                        showEditButton = true
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showEditButton = false
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                url = (url == nil ? URL(fileURLWithPath: pin?.path.path(percentEncoded: false) ?? "") : nil)
            }) {
                Image(systemName: "eye")
                    .font(hoveringPreview ? .title2 : .title3)
                    .frame(width: 12.5, height: 12.5)
            }
            .quickLookPreview($url)
            .buttonStyle(.borderless)
            .padding(.trailing, 15)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.1)) {
                    hoveringPreview = hovering
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 5.25)
        .padding(.bottom, 0.25)
        .frame(maxHeight: 31)

        Divider()
            .padding(.horizontal, 10)
        
        HStack {
            Text("Path")
                .font(.headline)
                .foregroundStyle(Color.secondary)
                .padding(.horizontal, 15)
            
            Spacer()
        }
        .padding(.bottom, -12.5)
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                if let pathComponents = pin?.path.pathComponents {
                    ForEach(pathComponents.indices, id: \.self) { i in
                        let comp = pathComponents[i]
                        let path = pathComponents[0...i].joined(separator: "/")
                        
                        if i > 1 {
                            Text("/")
                                .font(.headline)
                        }
                        
                        Text(comp)
                            .foregroundStyle(hoveredComp == i ? Color.blue : Color.primary)
                            .font(.headline)
                            .onTapGesture {
                                openFinder(path)
                            }
                            .onHover { hovering in
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    hoveredComp = hovering ? i : nil
                                }
                            }
                            .if(i > 0) { view in
                                view.padding(.horizontal, -6)
                            }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 2)
        }
        .padding(10)
        .padding(.trailing, 5)
        
        Divider()
            .padding(.horizontal, 10)
            .padding(.top, -5)
        
        HStack {
            Text("Color")
                .font(.headline)
                .foregroundStyle(Color.secondary)
                .padding(.horizontal, 15)
            
            Spacer()
        }
        .padding(.top, -7.5)
        
        HStack {
            ForEach(CustomColor.allCases, id: \.self) { color in
                Button(action: {
                    setPinColor(color)
                }) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.color)
                        .frame(width: (hoveredColor == color && pin?.color == color) ? 23.5 : (hoveredColor == color || pin?.color == color) ? 22.5 : 18.25,
                               height: (hoveredColor == color && pin?.color == color) ? 23.5 : (hoveredColor == color || pin?.color == color) ? 22.5 : 18.25)
                }
                .buttonStyle(.borderless)
                .onHover { hovering in
                    hoveredColor = hovering ? color : nil
                }
                .frame(width: 23.5, height: 23.5)
                .padding(.vertical, -3.5)
                .padding(.horizontal, -3)
            }
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 5)
        
        Divider()
            .padding(.horizontal, 10)
        
//        Form {
//            KeyboardShortcuts.Recorder("test:", name: .test)
//        }
//        .onAppear {
//            customShortcut = KeyboardShortcuts.getShortcut(for: .test)
//        }
        
        HStack {
            Spacer()
            
            Button(action: {
//                shortcutWindowOpen.toggle()
//                openWindow(id: "shortcutInput")
//                openWindow(value: pin?.id)
//                let varToPass = "TESTIGN"
                NSApp.sendAction(#selector(AppDelegate.openShortcutWindow), to: nil, from: NSNumber(value: pin?.position ?? -1))
            }) {
                Text("Setup Global Shortcut")
            }
//            .sheet(isPresented: $shortcutWindowOpen) {
//                ShortcutView(input: $shortcutWindowInput)
//            }
            
            Spacer()
        }
        
        
        Divider()
            .padding(.horizontal, 10)
            .padding(.bottom, 3)
        
        HStack {
            Button(action: {
                if let pin = pin {
                    pinnedManager.deletePin(pin)
                    resetSelectedPin()
                }
            }) {
                Image(systemName: "trash")
                    .foregroundStyle(Color.red)
                    .font(hoveringTrash ? .title2 : .title3)
                    .frame(width: 12.5, height: 12.5)
            }
            .buttonStyle(.borderless)
            .padding(.bottom, 2)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.1)) {
                    hoveringTrash = hovering
                }
            }
        }
        
        Divider()
            .padding(.horizontal, 10)
    }
    
    private func setPinColor(_ color: CustomColor) {
        if let index = pinned.firstIndex(where: { $0.position == pin?.position }) {
            pinned[index].color = color
            pin = pinned[index]
            pinnedManager.savePinned(pinned)
        } else {
            print("FAILED")
        }
    }
    
    private func setPinName(_ name: String) {
        print("BEFORE: \(pin!)")
        if let index = pinned.firstIndex(where: { $0.position == pin?.position }) {
            pinned[index].name = name
            pin = pinned[index]
            print("AFTER: \(pin!)")
            pinnedManager.savePinned(pinned)
        }
    }
}

//#Preview {
//    DetailView()
//}
