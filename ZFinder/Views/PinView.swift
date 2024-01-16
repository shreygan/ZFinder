//
//  PinnedView.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 12/25/23.
//

import SwiftUI
import HotKey
import Quartz

struct PinView: View {
    @AppStorage("hideFileExtensions") private var hideFileExtensions = false
    
    @Binding private var selectedPin: Pin?
    
    @State private var pinned: [Pin]
    @State private var animationTick = 0
    
    @State private var isSearchingPath = false
    @State private var searchText = ""
    
    @State private var hoveredPin: Pin?
    
    @State private var isDeleteMode = false
    @State private var isDeleting = false
    @State private var deletedPin: Pin?
    
    @State private var isReorderMode = false
    
    @State private var isHoveringOrder = false
    @State private var isHoveringTrash = false
    @State private var isHoveringType = false
    @State private var isQuickLooking = false
    @State private var isHoveringAdd = false
    
    let pinnedManager = PinnedManager()
        
    var openFinder: (String) -> Void

    var QLPanel: QLPreviewPanel?
    
    init(selectedPin: Binding<Pin?>, openFinder: @escaping (String) -> Void) {
        _pinned = State(initialValue: pinnedManager.getPinned())
        _selectedPin = selectedPin
        self.openFinder = openFinder
        QLPanel = QLPreviewPanel.shared()
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("ZFinder")
                    .font(.title3)
                    .fontWeight(.heavy)
                    .padding()
                
                Spacer()
                
                Button(action: {
                    deletePins()
                }) {
                    Image(systemName: "trash")
                        .font(isHoveringTrash ? .title2 : .title3)
                        .foregroundStyle(isDeleteMode ? .red : .blue)
                        .frame(width: 12.5, height: 12.5)
                }
                .buttonStyle(.borderless)
                .padding(.trailing, 5)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isHoveringTrash = hovering
                    }
                }
                
                Button(action: {
                    reorderPins()
                }) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(isHoveringOrder ? .title2 : .title3)
                        .foregroundStyle(isReorderMode ? .red : .blue)
                        .frame(width: 12.5, height: 12.5)
                }
                .buttonStyle(.borderless)
                .padding(.trailing, 5)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isHoveringOrder = hovering
                    }
                }
                
                Button(action: {
                    addPin()
                }) {
                    Image(systemName: "plus.circle")
                        .font(isHoveringAdd ? .title2 : .title3)
                        .foregroundStyle(.blue)
                        .frame(width: 12.5, height: 12.5)
                }
                .buttonStyle(.borderless)
                .padding(.trailing, 20)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isHoveringAdd = hovering
                    }
                }
            }
            .padding(.top, -7)
            .padding(.bottom, -13)
            
            Divider()
                .padding(.horizontal, 10)
            
            HStack {
                TextField("Search by \(isSearchingPath ? "Path" : "Name")", text: $searchText.onUpdate(updatePinned))
                    .padding(.horizontal, 20)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 10))
                    .padding(.vertical, -5)
                    .foregroundStyle(Color.gray)
                    .disabled(isDeleting)
                
                Toggle(isOn: $isSearchingPath.onUpdate(updatePinned)) {
                    Text(isSearchingPath ? "Path" : "Name")
                        .font(.system(size: 10))
                        .padding(.horizontal, -2)
                        .frame(width: 25)
                }
                .disabled(isDeleting)
                .toggleStyle(ButtonToggleStyle())
                .padding(.leading, -17.5)
                .padding(.trailing, 12.5)
            }
            
            Divider()
                .padding(.horizontal, 10)
                    
            List {
                ForEach(pinned) { pin in
                    pinnedEntryView(pin)
                }
                .if(isReorderMode) { view in
                    view.onMove(perform: orderPinned)
                }
                .padding(.horizontal, 5)
            }
            .scrollContentBackground(.hidden)
            .listStyle(PlainListStyle())
            .padding(.bottom, -7)
            .padding(.top, -2)
            
        }
        .onAppear {
            updatePinned()
            isDeleteMode = false
            isReorderMode = false
            isDeleting = false
            deletedPin = nil
            hoveredPin = nil
        }
    }
    
    private func pinnedEntryView(_ pin: Pin) -> some View {
        HStack {
            if pin.isApp {
                pinnedEntryAppIcon(pin)
            } else {
                pinnedEntryOtherIcon(pin)
            }
            
            if isDeleting && deletedPin == pin {
                pinnedEntryDeletingView()
            } else {
                pinnedEntryNotDeletingView(pin)
            }
        }
        .if(isReorderMode) { view in
            view.modifier(Shake(animatableData: CGFloat(animationTick)))
        }
        .padding(.vertical, 4)
        .padding(.horizontal, -10)
        .if(!isReorderMode && !isDeleteMode) { view in
            view.background (
                RoundedRectangle(cornerRadius: 8)
                    .fill(pin == hoveredPin ? pin.color.color.opacity(0.4) : pin.color.color.opacity(0.2))
                    .padding(.horizontal, -5)
            )
        }
        .if(!isReorderMode && !isDeleteMode) { view in
            view.onTapGesture {
                selectedPin = pin
            }
        }
        .if(!isReorderMode && !isDeleteMode) { view in
            view.onHover { hovering in
                withAnimation(.easeInOut(duration: 0.1)) {
                    hoveredPin = hovering ? pin : nil
                }
            }
        }
        .if(isDeleteMode) { view in
            view.onHover { hovering in
                withAnimation(.easeInOut(duration: 0.1)) {
                    hoveredPin = isDeleting ? hoveredPin : (hovering ? pin : nil)
                }
            }
        }
        .if(isDeleteMode) { view in
            view.onTapGesture {
                withAnimation(.easeInOut(duration: 0.1)) {
                    if deletedPin == nil {
                        deletedPin = pin
                        isDeleting = true
                    }
                }
            }
        }
        .if(isDeleteMode) { view in
            view.background (
                RoundedRectangle(cornerRadius: 8)
                    .fill(pin == hoveredPin ? Color.red.opacity(0.4) : Color.red.opacity(0.2))
                    .padding(.horizontal, -5)
            )
        }
        .listRowSeparator(.hidden)
    }
    
    private func pinnedEntryDeletingView() -> some View {
        HStack {
            Text("Are You Sure?")
            
            Spacer()
            
            Button("Cancel") {
                isDeleting = false
                deletedPin = nil
            }
            .buttonStyle(BorderedButtonStyle())
            
            Button(action: {
                deletePin(deletedPin!)
                isDeleting = false
                deletedPin = nil
            }) {
                Text("Confirm")
                    .foregroundStyle(Color.red)
            }
            .buttonStyle(BorderedButtonStyle())
            .padding(.trailing, 20)
        }
    }
    
    private func pinnedEntryNotDeletingView(_ pin: Pin) -> some View {
        HStack {
            Text(hideFileExtensions ? pin.nameNoExt : pin.name)
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.head)
            
            Spacer()
            
            if hoveredPin == pin && !isReorderMode && !isDeleteMode {
                Button(action: {
                    selectedPin = pin
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.borderless)
                .padding(.trailing, 10)
            }
        }
    }
    
    private func pinnedEntryAppIcon(_ pin: Pin) -> some View {
        Image(nsImage: pin.icon!)
            .aspectRatio(contentMode: .fit)
            .frame(width: 20, height: 20)
            .padding(.leading, 10)
            .if(!isReorderMode) { view in
                view.onTapGesture(count: 2) {
                    isQuickLooking.toggle()
                    if isQuickLooking {
                        QLPanel?.center()
                        QLPanel?.dataSource = pin.quickLook
                        QLPanel?.makeKeyAndOrderFront(nil)
                    } else {
                        QLPanel?.close()
                    }
                }
            }
            .if(!isReorderMode) { view in
                view.onTapGesture {
                    if isQuickLooking {
                        isQuickLooking = false
                        QLPanel?.close()
                    } else {
                        openFinder(pin.path.path(percentEncoded: false))
                    }
                }
            }
    }
    
    private func pinnedEntryOtherIcon(_ pin: Pin) -> some View {
        Image(systemName: pin.isFile ? extToSFSymbol(ext: pin.fileType) : "folder")
            .aspectRatio(contentMode: .fit)
            .frame(width: 20, height: 20)
            .foregroundColor(pin.isFile ? .gray : .blue)
            .padding(.leading, 10)
            .font(isHoveringType && hoveredPin == pin ? .title2 : .title3)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isHoveringType = hovering
                }
            }
            .if(!isReorderMode) { view in
                view.onTapGesture(count: 2) {
                    isQuickLooking.toggle()
                    if isQuickLooking {
                        QLPanel?.center()
                        QLPanel?.dataSource = pin.quickLook
                        QLPanel?.makeKeyAndOrderFront(nil)
                    } else {
                        QLPanel?.close()
                    }
                }
            }
            .if(!isReorderMode) { view in
                view.onTapGesture {
                    if isQuickLooking {
                        isQuickLooking = false
                        QLPanel?.close()
                    } else {
                        openFinder(pin.path.path(percentEncoded: false))
                    }
                }
            }
    }
    
    private func updatePinned() {
        if searchText.isEmpty {
            pinned = pinnedManager.getPinned()
        } else if isSearchingPath {
            pinned = pinnedManager.getPinned().filter { $0.path.path().localizedCaseInsensitiveContains(searchText) }
        } else {
            pinned = pinnedManager.getPinned().filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private func deletePin(_ folder: Pin) {
        pinnedManager.deletePin(folder)
        pinned = pinnedManager.getPinned()
    }
    
    private func addPin() {
        isReorderMode = false
        isDeleteMode = false
        isDeleting = false
        deletedPin = nil
        
        let dirPicker = NSOpenPanel()
        dirPicker.canChooseFiles = true
        dirPicker.canChooseDirectories = true
        dirPicker.allowsMultipleSelection = true
        dirPicker.canDownloadUbiquitousContents = true
        dirPicker.canResolveUbiquitousConflicts = true
        
        dirPicker.level = .floating
        dirPicker.orderFrontRegardless()
        dirPicker.center()
        
        if dirPicker.runModal() == .OK {
            let paths = dirPicker.urls
            
            for path in paths {
                pinnedManager.addPin(file: path.path().last! != "/" || path.pathExtension == "app", path: path.path())
            }
        }
        pinned = pinnedManager.getPinned()
    }
    
    private func orderPinned(source: IndexSet, dest: Int) {
        pinned.move(fromOffsets: source, toOffset: dest)
        pinned.enumerated().forEach { idx, pin in
            pinned[idx].position = idx + 1
        }
        pinnedManager.savePinned(pinned)
    }
    
    private func reorderPins() {
        isReorderMode.toggle()
        isDeleteMode = false
        isDeleting = false
        deletedPin = nil
        withAnimation(.default) {
            animationTick += 1
        }
    }
    
    private func deletePins() {
        if isDeleteMode {
            isDeleting = false
            deletedPin = nil
        }
        isDeleteMode.toggle()
        isReorderMode = false
        withAnimation(.default) {
            animationTick += 1
        }
    }
}

//#Preview {
//    PinView()
//}
