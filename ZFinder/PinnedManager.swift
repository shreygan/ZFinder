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
    var name: String
    var file: Bool
    var color: CustomColor
    var path: URL
    
    var description: String {
        return "Pin(id: \(id), position: \(position), name: \(name), file: \(file), color: \(color), path: \(path)\n"
    }
    
    var fileType: String {
        path.pathExtension
    }
    
    init(position: Int, name: String, file: Bool, color: CustomColor, path: URL) {
        self.id = UUID()
        self.position = position
        self.name = name
        self.file = file
        self.color = color
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
                
                if components.count == 5 {
                    let position = Int(components[0].trimmingCharacters(in: .whitespaces))
                    let name = components[1].trimmingCharacters(in: .whitespaces)
                    let file = Bool(components[2].trimmingCharacters(in: .whitespaces))
                    let color = CustomColor.createCustomColor(components[3].trimmingCharacters(in: .whitespaces))
                    let path = URL(string: components[4].trimmingCharacters(in: .whitespaces))
                    
                    return Pin(position: position!, name: name, file: file!, color: color!, path: path!)
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
            let lines = pins.map { "\($0.position),\($0.name),\($0.file),\($0.color.name),\($0.path.path(percentEncoded: false))" }
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
    
    private func createFile() {
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
//            print("CREATING FILE at \(fileURL.path)")
        } else {
//            print("FILE ALREADY CREATED AT \(fileURL.path)")
        }
    }
}
