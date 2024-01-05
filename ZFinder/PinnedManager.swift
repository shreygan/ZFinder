//
//  PinnedManager.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 12/26/23.
//

import Foundation

struct Pin: Hashable, Identifiable, Comparable, CustomStringConvertible {
    var id: UUID
    var position: Int
    var file: Bool
    var path: URL
    
    var name: String {
        return path.lastPathComponent
    }
    
    var description: String {
        return "Pin(id: \(id), file: \(file), position: \(position), name: \(name)"
    }
    
    var fileType: String {
        path.pathExtension
    }
    
    init(position: Int, file: Bool, path: URL) {
        self.id = UUID()
        self.position = position
        self.file = file
        self.path = path
    }
    
    static func < (lhs: Pin, rhs: Pin) -> Bool {
        return lhs.position < rhs.position
    }
}

class PinnedManager {
    private let fileURL: URL
    
    init() {
        fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(".zfinderfavorites")
    
        createFile()
    }
    
    func getPinned() -> [Pin] {
        do {
            let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
            let lines = fileContent.components(separatedBy: "\n")
            
            var pinnedFolders: [Pin] = lines.compactMap { line in
                let components = line.components(separatedBy: ",")
                guard components.count == 3,
                      let position = Int(components[0].trimmingCharacters(in: .whitespaces)),
                      let file = Bool(components[1].trimmingCharacters(in: .whitespaces)),
                      let path = URL(string: components[2].trimmingCharacters(in: .whitespaces)) else {
                    return nil
                }
                return Pin(position: position, file: file, path: path)
            }
            pinnedFolders.sort { $0.position < $1.position }
            
            return pinnedFolders
        } catch {
            print("Error loading pinned data: \(error)")
            return []
        }
    }
    
    func savePinned(_ folders: [Pin]) {
        print("SAVING PINNED")
        
        do {
            let lines = folders.map { "\($0.position),\($0.file),\($0.path)" }
            let content = lines.joined(separator: "\n")
            
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error saving pinned data: \(error)")
        }
    }
    
    func addPin(file: Bool, path: String) {
        print("file: \(file), folder: \(path)'")
        do {
            let pinnedData: String
            if let fileContent = try? String(contentsOf: fileURL, encoding: .utf8), !fileContent.isEmpty {
                pinnedData = fileContent.last == "\n" ?
                                "\(getPinned().count + 1),\(file),\(path)\n"
                                : "\n\(getPinned().count + 1),\(file),\(path)\n"
            } else {
                pinnedData = "\(getPinned().count + 1),\(file),\(path)\n"
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
    
    func deletePin(_ folder: Pin) {
        var pinned = getPinned()
        
        print("DELETING \(folder.position) AT INDEX: \(String(describing: pinned.firstIndex(where: { $0.position == folder.position })))")
        
        if let index = pinned.firstIndex(where: { $0.position == folder.position }) {
            print(pinned)
            print("")
            print("")
            print("")
            print("INDEX IS \(index)")
            
            pinned.remove(at: index)
            
            for i in index..<pinned.count {
                pinned[i].position -= 1
            }
            
            savePinned(pinned)
        }
    }
    
    private func createFile() {
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
//            print("CREATING FILE at \(fileURL.path)")
        } else {
//            print("FILE ALREADY CREATED AT \(fileURL.path)")
        }
    }
}
