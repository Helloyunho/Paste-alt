//
//  KeyHolderAsSwiftUI.swift
//  Paste-alt
//
//  Created by Helloyunho on 2020/07/29.
//  Copyright © 2020 Helloyunho. All rights reserved.
//

import Foundation
import SwiftUI
import KeyHolder
import Magnet

struct KeyHolderView: NSViewRepresentable {
    var identifier: String
    var callback: (HotKey) -> Void
    

    func updateNSView(_ nsView: NSViewType, context: Context) {
        // Do nothing
    }
    
    func makeNSView(context: Context) -> RecordView {
        let recordView = RecordView(frame: .zero)
        recordView.tintColor = NSColor(red: 0.164, green: 0.517, blue: 0.823, alpha: 1)
        recordView.didChange = { keyCombo in
            guard let keyCombo = keyCombo else {
                HotKeyCenter.shared.unregisterHotKey(with: self.identifier)
                return
            }
            
            let hotKey = HotKey(identifier: self.identifier, keyCombo: keyCombo, handler: self.callback)
            hotKey.register()
        }
        return recordView
    }
}
