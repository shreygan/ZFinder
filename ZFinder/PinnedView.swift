//
//  PinnedView.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 12/25/23.
//

import SwiftUI

struct PinnedView: View {
//    @State private var selectedFolder: URL?
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
                
//                Button("TEST") {
//                    deletePin()
//                }
                
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
            
            
            if pinned.isEmpty || pinned.count * 30 < 300 {
                List {
                    ForEach(pinned.sorted { $0.position < $1.position }) { folder in
                        pinnedFolderView(folder: folder)
                    }
                }
                .scrollContentBackground(.hidden)
                .frame(width: 400, height: CGFloat(pinned.count) * 30)
                .padding(.vertical, -4)
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(pinned.sorted { $0.position < $1.position }) { folder in
                            pinnedFolderView(folder: folder)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .frame(width: 400, height: 300)
                }
                .padding(.vertical, -4)
            }
            
//            ScrollView {
//                List(pinned.sorted { $0.position < $1.position }, id: \.self) { folder in
//                    pinnedFolderView(folder: folder)
//                }
//                .scrollContentBackground(.hidden)
//                .frame(width: 400, height: 300)
//            }
//            .padding(.vertical, -4)
        
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
    

//    var body: some View {
//        VStack {
////            Button("Select Folder") {
////                openFolderPicker()
////            }
////            .padding()
//            
//            Button("Add To Fav Test") {
//                openFolderPicker()
//            }
//            .padding()
//            
////            if let selectedFolder = selectedFolder {
////                Text("Selected Folder: \(selectedFolder.path)")
////                    .padding()
////            }
//            
////            NavigationView {
////                List {
////                    ForEach(pinned.folders, id: \.self) { folder in
////                        Text(folder)
////                    }
////                }
////                .navigationTitle("Pinned Folders")
////                .toolbar {
////                    Button(action: {
////                        // Simulate adding a pinned folder
////                        let newFolder = "New Pinned Folder"
////                        pinned.folders.append(newFolder)
////                        pinnedManager.savePinned(pinned)
////                    }) {
////                        Image(systemName: "plus")
////                    }
////                }
////            }
//            
//            List {
//                ForEach(pinned, id: \.self) { folder in
//                    VStack(alignment: .leading) {
//                        HStack {
//                            Text(folder)
//                                .font(.headline)
////                                .foregroundColor(entry == hoveredEntry ? Color.blue : Color.primary)
//                                .animation(.easeInOut(duration: 0.15))
//                            Spacer()
//                            Text("test")
//                                .foregroundStyle(.secondary)
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Pinned Folders")
//            .listStyle(.sidebar)
//        }
//    }

    private func test() {
        pinnedManager.addPin("Path/To/Folder")
        pinned = pinnedManager.getPinned()
    }
    
    func openFinder(_ pin: Pin) {
        let pathString = pin.path.path()
        let url = URL(fileURLWithPath: pathString)
        NSWorkspace.shared.open(url)
    }
    
    private func deletePin(_ folder: Pin) {
//        pinnedManager.deletePin(pinned.sorted()[0])
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
        
//        dirPicker.orderFrontRegardless()
        dirPicker.level = .floating
//        dirPicker.styleMask = .nonactivatingPanel
//        dirPicker.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        dirPicker.orderFrontRegardless()
        
//        if let window = NSApp.keyWindow {
//            dirPicker.beginSheetModal(for: window) { response in
//                if response == .OK, let path = dirPicker.url?.path() {
//                    pinnedManager.addPin(path)
//                }
//            }
//        } else {
//            dirPicker.begin { response in
//                if response == .OK, let path = dirPicker.url?.path() {
//                    pinnedManager.addPin(path)
//                }
//            }
//        }
        
        if dirPicker.runModal() == .OK {
            if let path = dirPicker.url?.path() {
                pinnedManager.addPin(path)
            }
        }
        
        pinned = pinnedManager.getPinned()
        
    
        
        
        
//        print("FDJGNDFJKNGKJNDFG")
//        
//        let folderPicker = NSOpenPanel(contentRect: CGRect(origin: CGPoint(x: 0, y: 0),
//                                                           size: CGSize(width: 500,
//                                                                        height: 600)),
//                                       styleMask: .utilityWindow,
//                                       backing: .buffered,
//                                       defer: true)
//        
//        folderPicker.canChooseFiles = false
//        folderPicker.canChooseDirectories = true
//        folderPicker.allowsMultipleSelection = false
//        folderPicker.canDownloadUbiquitousContents = true
//        folderPicker.canResolveUbiquitousConflicts = true
//        
//        if folderPicker.runModal() == .OK {
//            selectedFolder = folderPicker.url
//            print(selectedFolder ?? "EMPTY")
//        }
        
//        folderPicker.begin { response in
//            if response == .OK {
//                if let pickedFolder = folderPicker.url {
//                    selectedFolder = pickedFolder
//                    print(selectedFolder ?? "NOTHING")
//                }
//            } else {
//                selectedFolder = URL(string: "dfgdfgdfgdfg")
//            }
//        }
        
    }
}




#Preview {
    PinnedView()
}
