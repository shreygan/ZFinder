//
//  SearchView.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 12/9/23.
//




// TODO
// make user input directory and open finder file for best match from ZEntry
// send it to open finder directory




import SwiftUI

let formatter = DateFormatter()

struct ZEntry: Identifiable, Equatable {
    let directory: String
    let frequency: Int
    let timestamp: Int
    
    var id: String {
        return directory
    }

    var date: String {
        formatter.dateFormat = "yyy-MM-dd"
        return formatter.string(from: Date(timeIntervalSince1970: Double(timestamp)))
    }
    
    var time: String {
        formatter.dateFormat = "hh:mm:ss a"
        return formatter.string(from: Date(timeIntervalSince1970: Double(timestamp)))
    }
    
    static func == (lhs: ZEntry, rhs: ZEntry) -> Bool {
        return lhs.directory == rhs.directory
    }
}

struct SearchView: View {
    @State private var userInput: String = ""
    @State private var zHistory: [ZEntry] = []
    
    @State private var hoveredEntry: ZEntry?

    var body: some View {
        VStack {
            TextField("Enter text", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Submit") {
//                writeZHistory()       // ACTUALLY MAKE THIS WRITE TO CORRECT PLACE
            }
            .padding()
            
            List(zHistory.sorted(by: { $0.frequency > $1.frequency } )) { entry in
                VStack(alignment: .leading) {
                    HStack {
                        Text(entry.directory)
                            .font(.headline)
                            .foregroundColor(entry == hoveredEntry ? Color.blue : Color.primary)
                            .animation(.easeInOut(duration: 0.15))
                        Spacer()
                        Text("\(entry.frequency) z's")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding([.top, .bottom], 8)
                .onTapGesture {
                    openFinder(entry)
                }
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.hoveredEntry = hovering ? entry : nil
                    }
                }
            }
            .navigationTitle("ZEntry List")
            .onAppear {
                loadZHistory()
            }
            .listStyle(.sidebar)
        }
        .padding()
    }
    
    
    func openFinder(_ entry: ZEntry? = nil) {
        let dirURL = URL(fileURLWithPath: entry?.directory ?? "/Users/shrey/Desktop")
        NSWorkspace.shared.open(dirURL)
    }
    
    func loadZHistory() {
        let zHistoryURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".z")
        do {
            zHistory = parseZHistory(try String(contentsOf: zHistoryURL, encoding: .utf8))
        } catch {
            print(".z file not found")
        }
    }
    
    func writeZHistory() {
        let filePath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".z")
        
        let update = "TESTTTREJIGDFGJDFGNDFGJLDFNG"
        
        if let data = update.data(using: .utf8) {
            do {
                let fileHandle = try FileHandle(forUpdating: filePath)
                
                try fileHandle.seekToEnd()
                try fileHandle.write(contentsOf: data)
                try fileHandle.close()
            } catch {
                
            }
        }
    }
    
    func parseZHistory(_ ZHistoryString: String) -> [ZEntry] {
        return ZHistoryString.split(separator: "\n").compactMap { line in
            let components = line.split(separator: "|")
            guard components.count == 3,
                  let frequency = Int(components[1]),
                  let timestamp = Int(components[2]) else {
                return nil
            }
            return ZEntry(directory: String(components[0]), frequency: frequency, timestamp: timestamp)
        }
    }
    
    func runZ() {
//        let proc = Process()
//        proc.executableURL = URL(fileURLWithPath: "/bin/zsh")
//        
//        let command = "source /opt/homebrew/etc/profile.d/z.sh; z 313; pwd"
//        proc.arguments = ["-c", command]
//        
//        let pipe = Pipe()
//        proc.standardOutput = pipe
//        
//        do {
//            try proc.run()
//        } catch {
//            displayText = "FAILURE"
//            print(displayText ?? "FAILU")
//        }
//        
//        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
//        if let outputString = String(data: outputData, encoding: .utf8) {
//            displayText = outputString
//        }
//        
//        print(displayText ?? "FAIL")
    }
    
    func procRunLS() {
//        let proc = Process()
//        proc.executableURL = URL(fileURLWithPath: "/usr/bin/env")
//        proc.arguments = ["ls", "-l"]
//        proc.currentDirectoryURL = URL(fileURLWithPath: "/Users/shrey")
//        
//        let pipe = Pipe()
//        proc.standardOutput = pipe
//        
//        do {
//            try proc.run()
//        } catch {
//            displayText = "FAILURE"
//        }
//        
//        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
//        if let outputString = String(data: outputData, encoding: .utf8) {
//            displayText = outputString
//        }
//        
//        print(displayText ?? "FAIL")
    }
}

#Preview {
    SearchView()
}

