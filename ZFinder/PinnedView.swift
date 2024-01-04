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
    @State private var reordering = false
    @State private var count = 0
    
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
                
                Spacer()
                
                Button(action: {
                    reordering.toggle()
                    withAnimation(.default) {
                        count += 1
                    }
                }) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.title3)
                        .foregroundStyle(reordering ? .red : .blue)
                }
                .buttonStyle(.borderless)
                .padding(.trailing, 2)
                .help("Reorder Elements")
                
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
                    
            List {
                ForEach(pinned) { pin in
                    pinnedFolderView(pin)
                }
                .if(reordering) { view in
                    view.onMove(perform: orderPinned)
                }
            }
            .scrollContentBackground(.hidden)
        }
    }
    
    private func pinnedFolderView(_ pin: Pin) -> some View {
//        VStack(alignment: .leading, spacing: 0) {
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
                    .if(!reordering) { view in
                        view.onHover(perform: { hovering in
                            withAnimation(.easeInOut(duration: 0.1)) {
                                showFolderPath = hovering
                            }
                        })
                    }
                
                    .truncationMode(.head)
                
                Spacer()
                
                if hoveredPin == pin && !reordering {
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
//        }
        .if(reordering) { view in
                view.modifier(Shake(animatableData: CGFloat(count)))
        }
        .padding(.vertical, 4)
        .padding(.horizontal, -10)
        .if(!reordering) { view in
                view.background (
                    RoundedRectangle(cornerRadius: 8)
                        .fill(pin == hoveredPin ? Color.gray.opacity(0.1) : Color.clear)
                )
        }
        .if(!reordering) { view in
                view.onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        hoveredPin = hovering ? pin : nil
                    }
                }
        }
        .if(!reordering) { view in
            view.onTapGesture {
                openFinder(pin)
            }
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
