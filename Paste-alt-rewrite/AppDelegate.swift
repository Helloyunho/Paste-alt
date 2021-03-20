//
//  AppDelegate.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/14.
//

import Cocoa
import KeyboardShortcuts
import Preferences
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var timer: Timer!
    var lastChangeCount: Int = 0
    let pasteboard: NSPasteboard = .general
    var firstPasteEvent = true
    var snippetItems: [SnippetItem] = []

    lazy var preferencesWindowController = PreferencesWindowController(
        panes: [
            Preferences.Pane(
                identifier: Preferences.PaneIdentifier(rawValue: "general"),
                title: "General",
                toolbarIcon: NSImage(named: NSImage.preferencesGeneralName)!) {
                    PreferencesView()
            }
        ]
    )

    func applicationWillFinishLaunching(_ notification: Notification) {
        try! dbPool.write { db in
            SnippetItem.createTable(db)
            SnippetContentTable.createTable(db)
        }

        try! dbPool.read { db in
            if let items = try? SnippetItem.order(SnippetItem.Columns.date.desc).fetchAll(db) {
                for item in items {
                    self.snippetItems.append(item.fetchingContentsFromDB(db))
                }
            }
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(snippetItems: snippetItems)
            .background(VisualEffectView(
                material: .selection,
                blendingMode: .behindWindow))

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            switch event.keyCode {
                case 53:
                    NSApplication.shared.hide(nil)
                default: break
            }

            return event
        }

        let contentHostingView = NSHostingView(rootView: contentView)

        // Create the window and set the content view.
        let screen = NSScreen.main!
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: screen.frame.width, height: screen.frame.height * 0.3),
            styleMask: [.closable, .miniaturizable],
            backing: .buffered, defer: false)
        window.contentView = contentHostingView
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
