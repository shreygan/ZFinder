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
    var path: URL
    
    var name: String {
        return path.lastPathComponent
    }
    
    var description: String {
        return "Pin(id: \(id), position: \(position), name: \(name)"
    }
    
    init(position: Int, path: URL) {
        self.id = UUID()
        self.position = position
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
                guard components.count == 2,
                      let position = Int(components[0].trimmingCharacters(in: .whitespaces)),
                      let path = URL(string: components[1].trimmingCharacters(in: .whitespaces)) else {
                    return nil
                }
                return Pin(position: position, path: path)
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
            let lines = folders.map { "\($0.position),\($0.path)" }
            let content = lines.joined(separator: "\n")
            
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error saving pinned data: \(error)")
        }
    }
    
    func addPin(_ folder: String) {
        do {
            let pinnedData = "\(getPinned().count + 1),\(folder)\n"
            
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
            
//            pinned[index...].forEach { $0.position -= 1 }
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
