//
//  PinnedManager.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 12/26/23.
//

import Foundation
import AppKit

struct Pin: Hashable, Identifiable, Comparable, CustomStringConvertible {
    var id: UUID
    var position: Int
    var name: String
    var isFile: Bool
    var color: CustomColor
    var path: URL
    var isApp: Bool
    
    var icon: NSImage?
    
//    var icon: NSImage? {
//        if isApp {
//            return NSWorkspace.shared.icon(forFile: path.path()).resized(to: NSSize(width: 22.5, height: 22.5))
//        } else {
//            return nil
//        }
//    }
    
    var nameNoExt: String {
        guard let dotIndex = name.lastIndex(of: ".") else {
            return name
        }
        
        if name.startIndex < dotIndex {
            return String(name[..<dotIndex])
        }
        
        return name
    }
    
    var description: String {
        return "Pin(id: \(id), position: \(position), name: \(name), file: \(isFile), color: \(color), path: \(path)\n"
    }
    
    var fileType: String {
        path.pathExtension
    }
    
    init(position: Int, name: String, file: Bool, color: CustomColor, path: URL) {
        self.id = UUID()
        self.position = position
        self.name = name
        self.isFile = file
        self.color = color
        self.path = path
        self.isApp = path.pathExtension == "app"
        
        if self.isApp {
            self.icon = NSWorkspace.shared.icon(forFile: path.path()).resized(to: NSSize(width: 22.5, height: 22.5))
        }
    }
    
    static func < (lhs: Pin, rhs: Pin) -> Bool {
        return lhs.position < rhs.position
    }
}


class PinnedManager {
    private let fileManager: FileManager = FileManager.default
    private let fileURL: URL
    
    var pinned: [Pin] {
        return self.getPinned()
    }
    
    init() {
        fileURL = fileManager.homeDirectoryForCurrentUser.appendingPathComponent(".zfinderpins")
        createFile()
    }
    
    private func createFile() {
        if !fileManager.fileExists(atPath: fileURL.path) {
            fileManager.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
            //            print("CREATING FILE at \(fileURL.path)")
        } else {
            //            print("FILE ALREADY CREATED AT \(fileURL.path)")
        }
    }
    
    func getPinned() -> [Pin] {
        do {
            let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
            let lines = fileContent.components(separatedBy: "\n")
            
            var pinnedFolders: [Pin] = lines.compactMap { line in
                let components = line.components(separatedBy: ",")
                
                if components.count == 5 {
                    let position = Int(components[0].trimmingCharacters(in: .whitespaces))
                    let name = components[1].trimmingCharacters(in: .whitespaces)
                    let file = Bool(components[2].trimmingCharacters(in: .whitespaces))
                    let color = CustomColor.createCustomColor(components[3].trimmingCharacters(in: .whitespaces))
                    let path = URL(string: components[4].trimmingCharacters(in: .whitespaces))
                    
//                    print("path: \(path!.path())")
//                    print("default: \(fileManager.currentDirectoryPath)")
//                    print("exists: \(fileManager.fileExists(atPath: path!.path(percentEncoded: false)))")
                    
                    
                    if fileManager.fileExists(atPath: path!.path(percentEncoded: false)) {
                        return Pin(position: position!, name: name, file: file!, color: color!, path: path!)
                    } else {
                        return nil
                    }
                } else {
                    return nil
                }
                
//                guard components.count == 5,
//                      let name = components[1].trimmingCharacters(in: .whitespaces) != "" ? components[1].trimmingCharacters(in: .whitespaces) : nil,
//                      let position = Int(components[0].trimmingCharacters(in: .whitespaces)),
//                      let file = Bool(components[2].trimmingCharacters(in: .whitespaces)),
//                      let color = CustomColor.createCustomColor(components[3].trimmingCharacters(in: .whitespaces)),
//                      let path = URL(string: components[4].trimmingCharacters(in: .whitespaces))
//                else {
//                    return nil
//                }
//                return Pin(position: position, name: name, file: file, color: color, path: path)
            }
            pinnedFolders.sort { $0.position < $1.position }
            
            return pinnedFolders
        } catch {
            print("Error loading pinned data: \(error)")
            return []
        }
    }
    
    func savePinned(_ pins: [Pin]) {
        do {
            let lines = pins.map { "\($0.position),\($0.name),\($0.isFile),\($0.color.name),\($0.path.path(percentEncoded: false))" }
            let content = lines.joined(separator: "\n")
            
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error saving pinned data: \(error)")
        }
    }
    
    func addPin(file: Bool, path: String) {
        let url = URL(string: path)!
        do {
            let pinnedData: String
            if let fileContent = try? String(contentsOf: fileURL, encoding: .utf8), !fileContent.isEmpty {
                
                pinnedData = fileContent.last == "\n" ?
                            "\(getPinned().count + 1),\(url.lastPathComponent),\(file),\(CustomColor.gray.name),\(path)\n"
                            : "\n\(getPinned().count + 1),\(url.lastPathComponent),\(file),\(CustomColor.gray.name),\(path)\n"
            } else {
                pinnedData = "\(getPinned().count + 1),\(url.lastPathComponent),\(file),\(CustomColor.gray.name),\(path)\n"
            }
            
//            let pinnedData = "\(getPinned().count + 1),\(file),\(path)\n"       // make count a locally stored var to not recall getPinned EVERY time
            
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            fileHandle.seekToEndOfFile()
            let data = pinnedData.data(using: .utf8)
            fileHandle.write(data!)
            fileHandle.closeFile()
        } catch {
            print("Error saving pinned data: \(error)")
        }
    }
    
    func deletePin(_ pin: Pin) {
        var pinned = getPinned()
        
        if let index = pinned.firstIndex(where: { $0.position == pin.position }) {
            pinned.remove(at: index)
            
            for i in index..<pinned.count {
                pinned[i].position -= 1
            }
            
            savePinned(pinned)
        }
    }
    
    func getPinByPos(_ pos: Int?) -> Pin? {
        if pos == nil {
            return nil
        }
        
        for pin in pinned {
            if pin.position == pos {
                return pin
            }
        }
        
        return nil
    }
    
    func deleteAllPins() {
        savePinned([])
    }
}
