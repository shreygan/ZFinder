//
//  Extension.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 1/3/24.
//

import SwiftUI
import Carbon
import Cocoa
import KeyboardShortcuts

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


/// User Customizable Keyboard Shortcuts

extension KeyboardShortcuts.Name {
    static let userShortcut1 = Self("userShortcut1")
    static let userShortcut2 = Self("userShortcut2")
    static let userShortcut3 = Self("userShortcut3")
    static let userShortcut4 = Self("userShortcut4")
    static let userShortcut5 = Self("userShortcut5")
    static let userShortcut6 = Self("userShortcut6")
    static let userShortcut7 = Self("userShortcut7")
    static let userShortcut8 = Self("userShortcut8")
    static let userShortcut9 = Self("userShortcut9")
    static let userShortcut10 = Self("userShortcut10")
}
