//
//  AttributedText.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/19.
//

import Foundation
import SwiftUI
import AppKit

// From https://github.com/sindresorhus/Pasteboard-Viewer/blob/main/Pasteboard%20Viewer/Utilities.swift
// And heavily modified by Helloyunho
struct AttributedText: NSViewRepresentable {
    typealias NSViewType = NSTextView

    var attributedText: NSAttributedString?

    func makeNSView(context: Context) -> NSViewType {
        let textView = NSTextView()
        textView.drawsBackground = false
        textView.isSelectable = false
        textView.textContainerInset = CGSize(width: 5, height: 10)
        textView.textColor = .controlTextColor
        textView.isEditable = false

        return textView
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
        if
            let attributedText = attributedText,
            attributedText != nsView.attributedString()
        {
            nsView.textStorage?.setAttributedString(attributedText)
        }
    }
}
