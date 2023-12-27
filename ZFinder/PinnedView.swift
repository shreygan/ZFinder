//
//  PinnedView.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 12/25/23.
//

import SwiftUI

struct PinnedView: View {
//    @State private var selectedFolder: URL?
    @State private var pinned: [String]
    let pinnedManager = PinnedManager()
    

    init () {
        _pinned = State(initialValue: pinnedManager.getPinned())
    }
    
    
    var body: some View {
        VStack {
//            Button("Select Folder") {
//                openFolderPicker()
//            }
//            .padding()
            
            Button("Add To Fav Test") {
                openFolderPicker()
            }
            .padding()
            
//            if let selectedFolder = selectedFolder {
//                Text("Selected Folder: \(selectedFolder.path)")
//                    .padding()
//            }
            
//            NavigationView {
//                List {
//                    ForEach(pinned.folders, id: \.self) { folder in
//                        Text(folder)
//                    }
//                }
//                .navigationTitle("Pinned Folders")
//                .toolbar {
//                    Button(action: {
//                        // Simulate adding a pinned folder
//                        let newFolder = "New Pinned Folder"
//                        pinned.folders.append(newFolder)
//                        pinnedManager.savePinned(pinned)
//                    }) {
//                        Image(systemName: "plus")
//                    }
//                }
//            }
            
            List {
                ForEach(pinned, id: \.self) { folder in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(folder)
                                .font(.headline)
//                                .foregroundColor(entry == hoveredEntry ? Color.blue : Color.primary)
                                .animation(.easeInOut(duration: 0.15))
                            Spacer()
                            Text("test")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Pinned Folders")
            .listStyle(.sidebar)
        }
    }
    
    private func test() {
        pinnedManager.addPin("TEST")
        pinned = pinnedManager.getPinned()
    }
    
    private func openFolderPicker() {
        let dirPicker = NSOpenPanel()
        dirPicker.canChooseFiles = false
        dirPicker.canChooseDirectories = true
        dirPicker.allowsMultipleSelection = false
        dirPicker.canDownloadUbiquitousContents = true
        dirPicker.canResolveUbiquitousConflicts = true
        
        if dirPicker.runModal() == .OK {
//            selectedFolder = dirPicker.url
            if let path = dirPicker.url?.path() {
                pinnedManager.addPin(path)
            }
            
//            pinnedManager.savePinned(dirPicker.url.path())
        }
        
    
        
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
