//
//  VisualEffectView.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/18.
//

import Foundation
import AppKit
import SwiftUI

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material?
    var blendingMode: NSVisualEffectView.BlendingMode?
    var appearance: NSAppearance?

    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material ?? visualEffectView.material
        visualEffectView.blendingMode = blendingMode ?? visualEffectView.blendingMode
        visualEffectView.appearance = appearance ?? visualEffectView.appearance
        visualEffectView.state = NSVisualEffectView.State.active
        return visualEffectView
    }

    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material ?? visualEffectView.material
        visualEffectView.blendingMode = blendingMode ?? visualEffectView.blendingMode
        visualEffectView.appearance = appearance ?? visualEffectView.appearance
    }
}
