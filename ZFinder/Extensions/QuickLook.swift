//
//  QuickLook.swift
//  ZFinder
//
//  Created by Shrey Gangwar on 1/14/24.
//

import SwiftUI
import Quartz

class QLCoordinator: NSObject, QLPreviewPanelDataSource {
    var path: String
    
    init(path: String) {
        self.path = path
    }
    
    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        return NSURL(fileURLWithPath: path) as QLPreviewItem
    }

    func numberOfPreviewItems(in controller: QLPreviewPanel) -> Int {
        return 1
    }
}
