//
//  DetailView.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 1/4/24.
//

import SwiftUI
import QuickLook

struct DetailView: View {
    @State private var hoveredComp: Int?
    @State private var hoveringType = false
    @State private var hoveringPreview = false
    
    @Binding var pin: Pin?
    
    @State var url: URL?
    
    var resetSelectedPin: () -> Void
    var openFinder: (String) -> Void
    
    @State private var hoveringBack = false
    
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
            
            if let pin = pin {
                Image(systemName: pin.file ? extToSFSymbol(ext: pin.fileType) : "folder")
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(pin.file ? .gray : .blue)
                    .padding(.leading, 5)
                    .font(hoveringType ? .title2 : .title3)
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            hoveringType = hovering
                        }
                    }
                    .onTapGesture {
                        openFinder(pin.path.path())
                    }
            }
            
            
            Text(pin?.name ?? "")
                .font(.title3)
                .fontWeight(.heavy)
            
            Spacer()
            
//            Button("Preview") {
//                url = (url == nil ? URL(fileURLWithPath: pin?.path.path() ?? "") : nil)
//            }
//            .quickLookPreview($url)
            
            Button(action: {
                url = (url == nil ? URL(fileURLWithPath: pin?.path.path() ?? "") : nil)
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
        .padding(.top, 10)
        .padding(.bottom, 2)
        
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
            .padding(.leading, 2)
        }
        .padding(10)
                
        
        Divider()
            .padding(.horizontal, 10)
            .padding(.top, -5)
    }
}

//#Preview {
//    DetailView()
//}
