//
//  PinnedManager.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 12/26/23.
//

import Foundation

class PinnedManager {
    private let fileURL: URL
    
    init() {
        fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(".zfinderfavorites")
        
        print(fileURL)
        
        createFile()
    }
    
    func getPinned() -> [String] {
        do {
            let pinnedData = try String(contentsOf: fileURL, encoding: .utf8)
            return pinnedData.components(separatedBy: "\n").filter { !$0.isEmpty }
        } catch {
            print("Error loading pinned data: \(error)")
            return []
        }
    }
    
    func addPin(_ folder: String) {
        let pinnedData = "\(folder)\n"
        do {
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            fileHandle.seekToEndOfFile()
            fileHandle.write(pinnedData.data(using: .utf8)!)
            fileHandle.closeFile()
        } catch {
            print("Error saving pinned data: \(error)")
        }
    }
    
    private func createFile() {
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
            print("CREATING FILE at \(fileURL.path)")
        } else {
            print("FILE ALREADY CREATED AT \(fileURL.path)")
        }
    }
}
