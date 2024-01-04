//
//  PinnedView.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 12/25/23.
//

import SwiftUI

struct PinnedView: View {
    @State private var pinned: [Pin]
    @State private var hoveredPin: Pin?
    @State private var showFolderPath = false
    
    let pinnedManager = PinnedManager()
    
    init() {
        _pinned = State(initialValue: pinnedManager.getPinned())
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("ZFinder")
                    .font(.title3)
                    .fontWeight(.heavy)
                    .padding()
                    .contextMenu {
                        Button("TEST1") {}
                    }
                
                Spacer()
                
                Button(action: {
                    addPin()
                }) {
                    Image(systemName: "plus.circle")
                        .font(.title3)
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.borderless)
                .padding(.trailing, 15)
            }
            .padding(.top, -7)
            .padding(.bottom, -13)
            
            Divider()
                .padding(.horizontal, 10)
            
//            ScrollView {
//                VStack {
//                    ForEach(pinned.sorted { $0.position < $1.position }) { folder in
//                        pinnedFolderView(folder)
//                    }
//                    Spacer()
//                }
//                .scrollContentBackground(.hidden)
//            }
//            .frame(maxWidth: 300, maxHeight: 200)
//            .fixedSize(horizontal: false, vertical: true)
            
            List {
                ForEach(pinned) { pin in
                    pinnedFolderView(pin)
                        .onHover { hovering in
                            if hovering {
                                print("HOVERING")
                            }
                        }
                }
//                .onMove(perform: orderPinned)
            }
            .scrollContentBackground(.hidden)
            .frame(maxWidth: 300, maxHeight: 200)
        
            Divider()
                .padding(.horizontal, 10)
        }
    }
    
    private func pinnedFolderView(_ pin: Pin) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: pin.file ? "doc" : "folder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(pin.file ? .gray : .blue)
                    .padding(.leading, 10)
                
                Text(showFolderPath && pin == hoveredPin ? pin.path.path() : pin.name)
                    .font(.headline)
                    .lineLimit(1)
                    .onHover(perform: { hovering in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            showFolderPath = hovering
                        }
                    })
                    .truncationMode(.head)
                
                Spacer()
                
                if hoveredPin == pin {
                    Button(action: {
                        deletePin(pin)
                    }) {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.borderless)
                    .padding(.trailing, 10)
                }
            }
        }
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(pin == hoveredPin ? Color.gray.opacity(0.1) : Color.clear)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                hoveredPin = hovering ? pin : nil
            }
        }
        .onTapGesture {
            openFinder(pin)
        }
        .listRowSeparator(.hidden)
    }
    
    private func openFinder(_ pin: Pin) {
        let pathString = pin.path.path()
        let url = URL(fileURLWithPath: pathString)
        NSWorkspace.shared.open(url)
    }
    
    private func deletePin(_ folder: Pin) {
        
        pinnedManager.deletePin(folder)
        pinned = pinnedManager.getPinned()
    }
    
    private func addPin() {
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
            if let path = dirPicker.url?.path() {
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
}


//#Preview {
//    PinnedView()
//}
