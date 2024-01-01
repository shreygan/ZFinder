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
                
                Spacer()
                
                Button(action: {
                    addPin()
                }) {
                    Image(systemName: "plus.circle")
                        .font(.title)
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.borderless)
                .padding(.trailing, 10)
            }
            .padding(.horizontal)
            .padding(.bottom, 5)
            
            Divider()
            
            ScrollView {
                VStack {
                    ForEach(pinned.sorted { $0.position < $1.position }) { folder in
                        pinnedFolderView(folder: folder)
                    }
                    Spacer()
                }
                .scrollContentBackground(.hidden)
            }
            .frame(maxWidth: 400, maxHeight: 300)
            .fixedSize(horizontal: false, vertical: true)
        
            Divider()
        }
    }
    
    private func pinnedFolderView(folder: Pin) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "folder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(.blue)
                    .padding(.leading, 10)
                
                Text(showFolderPath && folder == hoveredPin ? folder.path.path() : folder.name)
                    .font(.headline)
                    .lineLimit(1)
                    .onHover(perform: { hovering in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            showFolderPath = hovering
                        }
                    })
                
                Spacer()
                
                if hoveredPin == folder {
                    Button(action: {
                        deletePin(folder)
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
                .fill(folder == hoveredPin ? Color.gray.opacity(0.1) : Color.clear)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                hoveredPin = hovering ? folder : nil
            }
        }
        .onTapGesture {
            openFinder(folder)
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
        dirPicker.canChooseFiles = false
        dirPicker.canChooseDirectories = true
        dirPicker.allowsMultipleSelection = false
        dirPicker.canDownloadUbiquitousContents = true
        dirPicker.canResolveUbiquitousConflicts = true
        
        dirPicker.level = .floating
        dirPicker.orderFrontRegardless()
        
        if dirPicker.runModal() == .OK {
            if let path = dirPicker.url?.path() {
                pinnedManager.addPin(path)
            }
        }
        
        pinned = pinnedManager.getPinned()
    }
}


#Preview {
    PinnedView()
}
