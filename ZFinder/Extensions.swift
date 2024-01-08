//
//  Extension.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 1/3/24.
//

import SwiftUI
import Carbon
import Cocoa

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


enum CustomColor: CaseIterable {
    case red
    case green
    case yellow
    case blue
    case orange
    case purple
    case cyan
    case magenta
    case white
    case gray
    case black
    
    var color: Color {
        switch self {
        case .red:
            return Color(hex: "e6194B")
        case .green:
            return Color(hex: "3cb44b")
        case .yellow:
            return Color(hex: "ffe119")
        case .blue:
            return Color(hex: "4363d8")
        case .orange:
            return Color(hex: "f58231")
        case .purple:
            return Color(hex: "911eb4")
        case .cyan:
            return Color(hex: "42d4f4")
        case .magenta:
            return Color(hex: "f032e6")
        case .white:
            return Color(hex: "ffffff")
        case .gray:
            return Color.gray
        case .black:
            return Color(hex: "000000")
        }
    }
    
    var name: String {
        switch self {
        case .red:
            "red"
        case .green:
            "green"
        case .yellow:
            "yellow"
        case .blue:
            "blue"
        case .orange:
            "orange"
        case .purple:
            "purple"
        case .cyan:
            "cyan"
        case .magenta:
            "magenta"
        case .white:
            "white"
        case .gray:
            "gray"
        case .black:
            "black"
        }
    }
    
    static func createCustomColor(_ color: String) -> CustomColor? {
        switch color.lowercased() {
        case "red":
            return .red
        case "green":
            return .green
        case "yellow":
            return .yellow
        case "blue":
            return .blue
        case "orange":
            return .orange
        case "purple":
            return .purple
        case "cyan":
            return .cyan
        case "magenta":
            return .magenta
        case "white":
            return .white
        case "black":
            return .black
        default:
            return .gray
        }
    }
}


struct Shake: GeometryEffect {
    var amount: CGFloat = 5
    var shakesPerUnit = 5
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}


func extToSFSymbol(ext: String) -> String {
    switch ext.lowercased() {
    case "jpg", "jpeg", "png", "gif", "svg":
        return "photo"
        
    case "doc", "docx", "pdf", "txt", "rtf":
        return "doc.plaintext"
        
    case "xls", "xlsx", "csv", "tsv", "json":
        return "filemenu.and.selection"
        
    case "ppt", "pptx", "key", "odp":
        return "slider.horizontal.below.rectangle"
    
    case "mp3", "wav", "flac", "aac":
        return "music.note"
        
    case "mp4", "mov", "avi", "mkv":
        return "film"
        
    case "zip", "tar", "rar", "7z":
        return "doc.zipper"
        
    case "app", "exe", "sh", "bat":
        return "app"

    default:
        return "doc"
    }
}


/// Alternate Single/Double Click

struct TapRecognizerViewModifier: ViewModifier {
    @State private var singleTapIsTaped: Bool = Bool()

    var tapSensitivity: Double
    var singleTapAction: () -> Void
    var doubleTapAction: () -> Void

    init(tapSensitivity: Double, singleTapAction: @escaping () -> Void, doubleTapAction: @escaping () -> Void) {
        self.tapSensitivity = tapSensitivity
        self.singleTapAction = singleTapAction
        self.doubleTapAction = doubleTapAction
    }

    func body(content: Content) -> some View {
        return content
            .gesture(simultaneouslyGesture)
    }

    private var singleTapGesture: some Gesture { TapGesture(count: 1).onEnded {
        singleTapIsTaped = true
        DispatchQueue.main.asyncAfter(deadline: .now() + tapSensitivity) {
            if singleTapIsTaped { singleTapAction() }
        }
    }}
    
    private var doubleTapGesture: some Gesture { TapGesture(count: 2).onEnded{ singleTapIsTaped = false; doubleTapAction() } }
    private var simultaneouslyGesture: some Gesture { singleTapGesture.simultaneously(with: doubleTapGesture) }
}


extension View {
    func tapRecognizer(tapSensitivity: Double, singleTapAction: @escaping () -> Void, doubleTapAction: @escaping () -> Void) -> some View {
        return self.modifier(TapRecognizerViewModifier(tapSensitivity: tapSensitivity, singleTapAction: singleTapAction, doubleTapAction: doubleTapAction))
    }
}


/// Global Hotkeys

extension String {
  /// This converts string to UInt as a fourCharCode
  public var fourCharCodeValue: Int {
    var result: Int = 0
    if let data = self.data(using: String.Encoding.macOSRoman) {
      data.withUnsafeBytes({ (rawBytes) in
        let bytes = rawBytes.bindMemory(to: UInt8.self)
        for i in 0 ..< data.count {
          result = result << 8 + Int(bytes[i])
        }
      })
    }
    return result
  }
}

class HotkeySolution {
  static
  func getCarbonFlagsFromCocoaFlags(cocoaFlags: NSEvent.ModifierFlags) -> UInt32 {
    let flags = cocoaFlags.rawValue
    var newFlags: Int = 0

    if ((flags & NSEvent.ModifierFlags.control.rawValue) > 0) {
      newFlags |= controlKey
    }
    if ((flags & NSEvent.ModifierFlags.command.rawValue) > 0) {
      newFlags |= cmdKey
    }
    if ((flags & NSEvent.ModifierFlags.shift.rawValue) > 0) {
      newFlags |= shiftKey;
    }
    if ((flags & NSEvent.ModifierFlags.option.rawValue) > 0) {
      newFlags |= optionKey
    }
    if ((flags & NSEvent.ModifierFlags.capsLock.rawValue) > 0) {
      newFlags |= alphaLock
    }
      
    return UInt32(newFlags);
  }

  static func register() {
    var hotKeyRef: EventHotKeyRef?
    let modifierFlags: UInt32 =
      getCarbonFlagsFromCocoaFlags(cocoaFlags: NSEvent.ModifierFlags.command)

    let keyCode = kVK_ANSI_R
    var gMyHotKeyID = EventHotKeyID()

    gMyHotKeyID.id = UInt32(keyCode)

    gMyHotKeyID.signature = OSType("swat".fourCharCodeValue)

    var eventType = EventTypeSpec()
    eventType.eventClass = OSType(kEventClassKeyboard)
    eventType.eventKind = OSType(kEventHotKeyReleased)

    InstallEventHandler(GetApplicationEventTarget(), {
      (nextHanlder, theEvent, userData) -> OSStatus in

      NSLog("Command + R Released!")

      return noErr
    }, 1, &eventType, nil, nil)

    let status = RegisterEventHotKey(UInt32(keyCode),
                                     modifierFlags,
                                     gMyHotKeyID,
                                     GetApplicationEventTarget(),
                                     0,
                                     &hotKeyRef)
    assert(status == noErr)
  }
}
