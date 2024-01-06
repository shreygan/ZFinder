//
//  PinnedView.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 12/25/23.
//

import SwiftUI

struct PinView: View {
    @State private var pinned: [Pin]
    @State private var search = ""
    @State private var searchPath = false
    @State private var hoveredPin: Pin?
    @State private var showFolderPath = false
    @State private var reordering = false
    @State private var count = 0
    @State private var hoveringOrder = false
    @State private var hoveringAdd = false
    @State private var hoveringType = false
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
    
    init(selectedPin: Binding<Pin?>, openFinder: @escaping (String) -> Void) {
        _pinned = State(initialValue: pinnedManager.getPinned())
        _selectedPin = selectedPin
        self.openFinder = openFinder
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
                        .font(hoveringOrder ? .title2 : .title3)
                        .foregroundStyle(reordering ? .red : .blue)
                        .frame(width: 12.5, height: 12.5)
                }
                .buttonStyle(.borderless)
                .padding(.trailing, 5)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        hoveringOrder = hovering
                    }
                }
                
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
                TextField("Search", text: $search)
                    .padding(.horizontal, 20)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 10))
                    .padding(.vertical, -5)
                    .foregroundStyle(Color.gray)
                
                Toggle(isOn: $searchPath) {
                    Text("Path")
                        .font(.system(size: 10))
                }
                .toggleStyle(CheckboxToggleStyle())
                .padding(.leading, -17.5)
                .padding(.trailing, 20)
            }
            
            Divider()
                .padding(.horizontal, 10)
                    
            List {
                ForEach(pinnedSearch) { pin in
                    pinnedFolderView(pin)
                }
                .if(reordering) { view in
                    view.onMove(perform: orderPinned)
                }
                .padding(.horizontal, 5)
            }
            .scrollContentBackground(.hidden)
            .listStyle(PlainListStyle())
        }
    }
    
    private func pinnedFolderView(_ pin: Pin) -> some View {
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
                .if(!reordering) { view in
                    view.onTapGesture(count: 2) {
                        url = (url == nil ? URL(fileURLWithPath: pin.path.path(percentEncoded: false)) : nil)
                    }
                }
                .if(!reordering) { view in
                    view.onTapGesture {
                        if url == nil {
                            openFinder(pin.path.path(percentEncoded: false))
                        } else {
                            url = nil
                        }
                    }
                }
                
                
            Text(showFolderPath && pin == hoveredPin ? pin.path.path(percentEncoded: false) : pin.name)
                .font(.headline)
                .lineLimit(1)
                .if(!reordering) { view in
                    view.onHover { hovering in
                        if hovering {
                            withAnimation(.easeInOut(duration: 0.1).delay(1)) {
                                showFolderPath = hovering
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                showFolderPath = hovering
                            }
                        }
                    }
                }
                .truncationMode(.head)
            
            Spacer()
            
            if reordering {
                Button(action: {
                    deletePin(pin)
                }) {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
                .buttonStyle(.borderless)
                .padding(.trailing, 10)
            }
            
            if hoveredPin == pin && !reordering {
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
        .if(reordering) { view in
            view.modifier(Shake(animatableData: CGFloat(count)))
        }
        .padding(.vertical, 4)
        .padding(.horizontal, -10)
        .if(!reordering) { view in
            view.background (
                RoundedRectangle(cornerRadius: 8)
                    .fill(pin == hoveredPin ? pin.color.color.opacity(0.4) : pin.color.color.opacity(0.2))
//                    .fill(pin == hoveredPin ? Color.red.opacity(0.2) : Color.clear)
                    .padding(.horizontal, -5)
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
                selectedPin = pin
            }
        }
        .listRowSeparator(.hidden)
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
            if let path = dirPicker.url?.path(percentEncoded: false) {
//                print("PATHTHJTHJKNDTHKGJNDKJHDGKJKJDNF       \(path.removingPercentEncoding!)")
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
//    PinView()
//}
