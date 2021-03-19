//
//  AppDelegate.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/14.
//

import Cocoa
import SwiftUI
import Preferences
import KeyboardShortcuts

var dontUpdate = false

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var timer: Timer!
    var lastChangeCount: Int = 0
    let pasteboard: NSPasteboard = .general
    var firstPasteEvent = true
    
    lazy var preferencesWindowController = PreferencesWindowController(
        panes: [
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier(rawValue: "general"),
                title: "General",
                toolbarIcon: NSImage(named: NSImage.preferencesGeneralName)!
            ) {
                PreferencesView()
            }
        ]
    )

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Create the window and set the content view.
        let screen = NSScreen.main!
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: screen.frame.width, height: screen.frame.height * 0.3),
            styleMask: [.closable, .miniaturizable],
            backing: .buffered, defer: false)
        window.contentView = NSHostingView(
            rootView: contentView.background(
                VisualEffectView(
                    material: .selection,
                    blendingMode: .behindWindow)))
        window.makeKeyAndOrderFront(nil)
        window.level = .floating

        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            if self.lastChangeCount != self.pasteboard.changeCount {
                self.lastChangeCount = self.pasteboard.changeCount
                if self.firstPasteEvent || dontUpdate {
                    self.firstPasteEvent = false
                    dontUpdate = false
                    return
                }
                NotificationCenter.default.post(
                    name: .NSPasteboardDidChange, object: self.pasteboard)
            }
        }
        
        KeyboardShortcuts.onKeyDown(for: .openSnippetsView) {
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        timer.invalidate()
    }

    func applicationDidResignActive(_ notification: Notification) {
        NSApplication.shared.hide(nil)
    }
    
    @IBAction func copyCommand(_ sender: Any) {
        NotificationCenter.default.post(name: .CopyCommandCalled, object: nil)
    }
    
    @IBAction func deleteCommand(_ sender: Any) {
        NotificationCenter.default.post(name: .DeleteCommandCalled, object: nil)
    }
    
    @IBAction func minimizeCommand(_ sender: Any) {
        NSApplication.shared.hide(nil)
    }
    
    @IBAction func showPreferencesCommand(_ sender: Any) {
        preferencesWindowController.show()
    }
}
