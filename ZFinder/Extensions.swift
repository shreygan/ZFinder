//
//  Extension.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 1/3/24.
//

import SwiftUI

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
