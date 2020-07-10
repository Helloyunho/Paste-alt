//
//  AppDelegate.swift
//  Paste-alt
//
//  Created by Helloyunho on 2020/06/21.
//  Copyright © 2020 Helloyunho. All rights reserved.
//

import Cocoa
import SwiftUI

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = NSVisualEffectView.State.active
        return visualEffectView
    }

    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}

var dontUpdatePasteboard = false

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    var timer: Timer!
    let pasteboard: NSPasteboard = .general
    var lastChangeCount: Int = 0
    var firstRun = true

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { (t) in
            if self.lastChangeCount != self.pasteboard.changeCount {
                self.lastChangeCount = self.pasteboard.changeCount
                if dontUpdatePasteboard || self.firstRun {
                    self.firstRun = false
                    dontUpdatePasteboard = false
                    return
                }
                NotificationCenter.default.post(
                    name: .NSPasteboardDidChange, object: self.pasteboard)
            }
        }

        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()
        let screen = NSScreen.main!

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: screen.visibleFrame.width, height: screen.visibleFrame.height * 0.3),
            styleMask: [.closable, .miniaturizable],
            backing: .buffered, defer: false)
        window.contentView = NSHostingView(
            rootView: contentView.background(
                VisualEffectView(
                    material: NSVisualEffectView.Material.selection,
                    blendingMode: NSVisualEffectView.BlendingMode.behindWindow)))
        window.makeKeyAndOrderFront(nil)
        window.level = .floating
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}
