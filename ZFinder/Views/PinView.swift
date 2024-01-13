//
//  PinnedView.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 12/25/23.
//

import SwiftUI
import HotKey

struct PinView: View {
    @AppStorage("hideFileExtensions") private var hideFileExtensions = false
    
    @State private var pinned: [Pin]
    @State private var search = ""
    @State private var searchPath = false
    @State private var hoveredPin: Pin?
    @State private var reorderMode = false
    @State private var deleteMode = false
    @State private var count = 0
    @State private var hoveringOrder = false
    @State private var hoveringTrash = false
    @State private var hoveringAdd = false
    @State private var hoveringType = false
    @State private var deleting = false
    @State private var deletingPin: Pin?
    @State var url: URL?
    
    @Binding private var selectedPin: Pin?
    
    var openFinder: (String) -> Void
    
    var pinnedSearch: [Pin] {
        if search.isEmpty {
            return pinned
        } else if searchPath {
            return pinned.filter { $0.path.path().localizedCaseInsensitiveContains(search) }
        } else {
            return pinned.filter { $0.name.localizedCaseInsensitiveContains(search) }
        }
    }
    
    let pinnedManager = PinnedManager()
    let hotkey = HotKey(key: .a, modifiers: [.command, .control])
    
    init(selectedPin: Binding<Pin?>, openFinder: @escaping (String) -> Void) {
        _pinned = State(initialValue: pinnedManager.getPinned())
        _selectedPin = selectedPin
        self.openFinder = openFinder
        
//        let fileManager = FileManager()
//        print(fileManager.currentDirectoryPath)
        
//        callFunc()
    }
    
//    private func callFunc() {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "h:mm:ss.SSS a"
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
//            print("CALLING AT \(dateFormatter.string(from: Date()))")
//            callFunc()
//        }
//    }
    
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
                        .font(hoveringTrash ? .title2 : .title3)
                        .foregroundStyle(deleteMode ? .red : .blue)
                        .frame(width: 12.5, height: 12.5)
                }
                .buttonStyle(.borderless)
                .padding(.trailing, 5)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        hoveringTrash = hovering
                    }
                }
                
                Button(action: {
                    reorderPins()
                }) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(hoveringOrder ? .title2 : .title3)
                        .foregroundStyle(reorderMode ? .red : .blue)
                        .frame(width: 12.5, height: 12.5)
                }
                .buttonStyle(.borderless)
                .padding(.trailing, 5)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        hoveringOrder = hovering
                    }
                }
//                .popover(isPresented: $reordering) {
//                    Text("POPOVER!")
//                        .padding(5)
//                    
//                    Spacer()
//                    
//                    Button("Option 1") {
//                        print("Selected Option 1")
//                    }
//                    .popover(isPresented: $reordering) {
//                        Text("DOUBLE POPOVER!")
//                    }
//                    .padding(5)
//                    Button("Option 2") {
//                        print("Selected Option 2")
//                    }
//                    .padding(5)
//                    Button("Option 3") {
//                        print("Selected Option 3")
//                    }
//                    .padding(5)
//                }
                
                Button(action: {
                    addPin()
                }) {
                    Image(systemName: "plus.circle")
                        .font(hoveringAdd ? .title2 : .title3)
                        .foregroundStyle(.blue)
                        .frame(width: 12.5, height: 12.5)
                }
                .buttonStyle(.borderless)
                .padding(.trailing, 20)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        hoveringAdd = hovering
                    }
                }
            }
            .padding(.top, -7)
            .padding(.bottom, -13)
            
            Divider()
                .padding(.horizontal, 10)
            
            HStack {
                TextField("Search by \(searchPath ? "Path" : "Name")", text: $search)
                    .padding(.horizontal, 20)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 10))
                    .padding(.vertical, -5)
                    .foregroundStyle(Color.gray)
                    .disabled(deleting)
                
                Toggle(isOn: $searchPath) {
                    Text(searchPath ? "Path" : "Name")
                        .font(.system(size: 10))
                        .padding(.horizontal, -2)
                        .frame(width: 25)
                }
                .disabled(deleting)
                .toggleStyle(ButtonToggleStyle())
                .padding(.leading, -17.5)
                .padding(.trailing, 12.5)

            }
            
            Divider()
                .padding(.horizontal, 10)
                    
            List {
                ForEach(pinnedSearch) { pin in
                    pinnedEntryView(pin)
                }
                .if(reorderMode) { view in
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
            pinned = pinnedManager.getPinned()
            deleting = false
            deletingPin = nil
            hoveredPin = nil
        }
    }
    
    private func pinnedEntryView(_ pin: Pin) -> some View {
        HStack {
            Image(systemName: pin.file ? extToSFSymbol(ext: pin.fileType) : "folder")
//                .tapRecognizer(tapSensitivity: 0.2, singleTapAction: { print("SINGLE CLICK") }, doubleTapAction: { print("DOUBLE CLICK") })
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .foregroundColor(pin.file ? .gray : .blue)
                .padding(.leading, 10)
                .font(hoveringType && hoveredPin == pin ? .title2 : .title3)
                .quickLookPreview($url)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        hoveringType = hovering
                    }
                }
                .if(!reorderMode) { view in
                    view.onTapGesture(count: 2) {
                        url = (url == nil ? URL(fileURLWithPath: pin.path.path(percentEncoded: false)) : nil)
                    }
                }
                .if(!reorderMode) { view in
                    view.onTapGesture {
                        if url == nil {
                            openFinder(pin.path.path(percentEncoded: false))
                        } else {
                            url = nil
                        }
                    }
                }
            
            if deleting && deletingPin == pin {
                pinnedEntryDeletingView()
            } else {
                pinnedEntryNotDeletingView(pin)
            }
        }
        .if(reorderMode) { view in
            view.modifier(Shake(animatableData: CGFloat(count)))
        }
        .padding(.vertical, 4)
        .padding(.horizontal, -10)
        .if(!reorderMode && !deleteMode) { view in
            view.background (
                RoundedRectangle(cornerRadius: 8)
                    .fill(pin == hoveredPin ? pin.color.color.opacity(0.4) : pin.color.color.opacity(0.2))
                    .padding(.horizontal, -5)
            )
        }
        .if(!reorderMode && !deleteMode) { view in
            view.onTapGesture {
                selectedPin = pin
            }
        }
        .if(!reorderMode && !deleteMode) { view in
            view.onHover { hovering in
                withAnimation(.easeInOut(duration: 0.1)) {
                    hoveredPin = hovering ? pin : nil
                }
            }
        }
        .if(deleteMode) { view in
            view.onHover { hovering in
                withAnimation(.easeInOut(duration: 0.1)) {
                    hoveredPin = deleting ? hoveredPin : (hovering ? pin : nil)
                }
            }
        }
        .if(deleteMode) { view in
            view.onTapGesture {
                withAnimation(.easeInOut(duration: 0.1)) {
                    if deletingPin == nil {
                        deletingPin = pin
                        deleting = true
                    }
                }
            }
        }
        .if(deleteMode) { view in
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
                deleting = false
                deletingPin = nil
            }
            .buttonStyle(BorderedButtonStyle())
            
            Button(action: {
                deletePin(deletingPin!)
                deleting = false
                deletingPin = nil
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
            
            if hoveredPin == pin && !reorderMode && !deleteMode {
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
        .if(!reorderMode && !deleteMode) { view in
            view.onHover { hovering in
                if hovering {
                    withAnimation(.easeInOut(duration: 0.1).delay(1)) {
                        showFolderPath = hovering
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.01)) {
                        showFolderPath = hovering
                    }
                }
            }
        }
    }
    
    private func deletePin(_ folder: Pin) {
        pinnedManager.deletePin(folder)
        pinned = pinnedManager.getPinned()
    }
    
    private func addPin() {
        reorderMode = false
        deleteMode = false
        deleting = false
        deletingPin = nil
        
        let dirPicker = NSOpenPanel()
        dirPicker.canChooseFiles = true
        dirPicker.canChooseDirectories = true
        dirPicker.allowsMultipleSelection = false
        dirPicker.canDownloadUbiquitousContents = true
        dirPicker.canResolveUbiquitousConflicts = true
        
        dirPicker.level = .floating
        dirPicker.orderFrontRegardless()
        dirPicker.center()
        
        if dirPicker.runModal() == .OK {
            if let path = dirPicker.url?.path(percentEncoded: false) {
                pinnedManager.addPin(file: path.last! != "/", path: path)
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
        reorderMode.toggle()
        deleteMode = false
        deleting = false
        deletingPin = nil
        withAnimation(.default) {
            count += 1
        }
    }
    
    private func deletePins() {
        if deleteMode {
            deleting = false
            deletingPin = nil
        }
        deleteMode.toggle()
        reorderMode = false
        withAnimation(.default) {
            count += 1
        }
    }
}

//#Preview {
//    PinView()
//}
