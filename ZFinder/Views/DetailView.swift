//
//  DetailView.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 1/4/24.
//

import SwiftUI
import Quartz

struct DetailView: View {
    @AppStorage("hideFileExtensions") private var hideFileExtensions = false

    @Binding var pin: Pin?
    
    @FocusState private var isEditFocused: Bool
    
    @State private var pinned: [Pin]
    
    @State private var hoveredPathComponent: Int?
    @State private var hoveredColor: CustomColor?
    
    @State private var isHoveringEditButton = false
    @State private var isHoveringPreview = false
    @State private var isHoveringTrash = false
    @State private var isHoveringBack = false
    @State private var isHoveringType = false
    
    @State private var isShortcutWindowOpen = false
    @State private var isQuickLooking = false
    @State private var isShowingEdit = false
    @State private var isEditing = false
    
    @State private var editedText = ""
    
    let pinnedManager = PinnedManager()
        
    var resetSelectedPin: () -> Void
    var openFinder: (String) -> Void
    
    var QLPanel: QLPreviewPanel?
    
    init(pin: Binding<Pin?>, resetSelectedPin: @escaping () -> Void, openFinder: @escaping (String) -> Void) {
        _pin = pin
        self.resetSelectedPin = resetSelectedPin
        self.openFinder = openFinder
        _pinned = State(initialValue: pinnedManager.getPinned())
        _editedText = State(initialValue: _pin.wrappedValue?.name ?? "")
        QLPanel = QLPreviewPanel.shared()
    }
    
    var body: some View {
        HStack {
            Button(action: {
                resetSelectedPin()
            }) {
                Image(systemName: "chevron.backward")
                    .font(isHoveringBack ? .title2 : .title3)
                    .frame(width: 12.5, height: 12.5)
            }
            .buttonStyle(.borderless)
            .padding(.leading, 5)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isHoveringBack = hovering
                }
            }
            .onDisappear {
                resetSelectedPin()
            }
            
            if let pin = pin {
                if pin.isApp {
                    Image(nsImage: pin.icon!)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(pin.isFile ? .gray : .blue)
                        .padding(.leading, 5)
                        .padding(.trailing, -2)
                        .font(isHoveringType ? .title2 : .title3)
                        .onHover { hovering in
                            withAnimation(.easeInOut(duration: 0.1)) {
                                isHoveringType = hovering
                            }
                        }
                        .onTapGesture(count: 2) {
                            isQuickLooking.toggle()
                            if isQuickLooking {
                                QLPanel?.center()
                                QLPanel?.dataSource = pin.quickLook
                                QLPanel?.makeKeyAndOrderFront(nil)
                            } else {
                                QLPanel?.close()
                            }
                        }
                        .onTapGesture {
                            if isQuickLooking {
                                isQuickLooking = false
                                QLPanel?.close()
                            } else {
                                openFinder(pin.path.path(percentEncoded: false))
                            }
                        }
                } else {
                    Image(systemName: pin.isFile ? extToSFSymbol(ext: pin.fileType) : "folder")
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(pin.isFile ? .gray : .blue)
                        .padding(.leading, 5)
                        .padding(.trailing, -2)
                        .font(isHoveringType ? .title2 : .title3)
                        .onHover { hovering in
                            withAnimation(.easeInOut(duration: 0.1)) {
                                isHoveringType = hovering
                            }
                        }
                        .onTapGesture(count: 2) {
                            isQuickLooking.toggle()
                            if isQuickLooking {
                                QLPanel?.center()
                                QLPanel?.dataSource = pin.quickLook
                                QLPanel?.makeKeyAndOrderFront(nil)
                            } else {
                                QLPanel?.close()
                            }
                        }
                        .onTapGesture {
                            if isQuickLooking {
                                isQuickLooking = false
                                QLPanel?.close()
                            } else {
                                openFinder(pin.path.path(percentEncoded: false))
                            }
                        }
                }
            }
            
            HStack {
                if isShowingEdit {
                    Button(action: {
                        isEditing.toggle()
                        editedText = pin?.name ?? ""
                        isEditFocused.toggle()
                    }) {
                        Image(systemName: "pencil")
                            .font(isHoveringEditButton ? .title2 : .title3)
                            .frame(width: 12.5, height: 12.5)
                    }
                    .buttonStyle(.borderless)
                    .padding(.leading, 1)
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isHoveringEditButton = hovering
                        }
                    }
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    if isEditing {
                        if #available(macOS 13.0, *) {
                            TextField("\(editedText)", text: $editedText) {
                                setPinName(editedText)
                                isEditing = false
                            }
                            .focused($isEditFocused)
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
                            TextField("\(editedText)", text: $editedText) {
                                setPinName(editedText)
                                isEditing = false
                            }
                            .focused($isEditFocused)
                            .font(.title3)
                            .padding(2)
                            .padding(.horizontal, 2)
                            .textFieldStyle(PlainTextFieldStyle())
                            .background (
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(pin?.color.color.opacity(0.2) ?? Color.gray)
                            )
                        }
                        
                    } else {
                        Text(hideFileExtensions ? (pin?.nameNoExt ?? "") : (pin?.name ?? ""))
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
                if hovering || isEditing {
                    withAnimation(.easeInOut(duration: 0.3).delay(1)) {
                        isShowingEdit = true
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowingEdit = false
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                isQuickLooking.toggle()
                if isQuickLooking {
                    QLPanel?.center()
                    QLPanel?.dataSource = pin?.quickLook
                    QLPanel?.makeKeyAndOrderFront(nil)
                } else {
                    QLPanel?.close()
                }
            }) {
                Image(systemName: "eye")
                    .font(isHoveringPreview ? .title2 : .title3)
                    .frame(width: 12.5, height: 12.5)
            }
            .buttonStyle(.borderless)
            .padding(.trailing, 15)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isHoveringPreview = hovering
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
                            .foregroundStyle(hoveredPathComponent == i ? Color.blue : Color.primary)
                            .font(.headline)
                            .onTapGesture {
                                openFinder(path)
                            }
                            .onHover { hovering in
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    hoveredPathComponent = hovering ? i : nil
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
        
        HStack {
            Spacer()
            
            Button(action: {
                NSApp.sendAction(#selector(AppDelegate.openShortcutWindow), to: nil, from: NSNumber(value: pin?.position ?? -1))
            }) {
                Text("Setup Global Shortcut")
            }
            
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
                    .font(isHoveringTrash ? .title2 : .title3)
                    .frame(width: 12.5, height: 12.5)
            }
            .buttonStyle(.borderless)
            .padding(.bottom, 2)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isHoveringTrash = hovering
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
        }
    }
    
    private func setPinName(_ name: String) {
        if let index = pinned.firstIndex(where: { $0.position == pin?.position }) {
            pinned[index].name = name
            pin = pinned[index]
            pinnedManager.savePinned(pinned)
        }
    }
}

//#Preview {
//    DetailView()
//}
