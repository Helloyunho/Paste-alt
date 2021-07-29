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
import Sparkle

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var statusItem: NSStatusItem!
    var timer: Timer!
    var lastChangeCount: Int = 0
    let pasteboard: NSPasteboard = .general
    var firstPasteEvent = true
    let snippetItems = SnippetItems()
    var updater = SPUUpdater(hostBundle: Bundle.main, applicationBundle: Bundle.main, userDriver: SPUStandardUserDriver(hostBundle: Bundle.main, delegate: nil), delegate: nil)

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
        DispatchQueue.global(qos: .userInitiated).async {
            dbPool.writeSafely { db in
                try SnippetItem.createTable(db)
                try SnippetContentTable.createTable(db)
            }

            dbPool.readSafely { db in
                let items = try SnippetItem.order(SnippetItem.Columns.date.desc).limit(limitAtOneSnippets * 2).fetchAll(db)
                for item in items {
                    let fetchedContent = item.fetchingContentsFromDB(db)
                    DispatchQueue.main.async {
                        self.snippetItems.items.append(fetchedContent)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.snippetItems.isLoading = false
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onDeleteAllDatas), name: .DeleteAllCommandCalled, object: nil)
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
        let screen = NSScreen.screens[0]
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: screen.frame.width, height: screen.frame.height * 0.3),
            styleMask: [.closable, .miniaturizable],
            backing: .buffered, defer: false, screen: screen)
        window.contentView = contentHostingView
        window.makeKeyAndOrderFront(nil)
        window.level = .floating
        
        // StatusItem is stored as a class property.
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.statusItem.button?.title = "P"
        
        self.makeMenusInMenuBar()
        
        do {
            try updater.start()
        } catch {
            defaultLogger.error("\(String(describing: error))")
        }

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
    
    func makeMenusInMenuBar() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Open Paste-alt", action: #selector(self.openApplication), keyEquivalent: "o"))
        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(self.showPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Check for Updates...", action: #selector(self.checkForUpdate), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit Paste-alt", action: #selector(self.quitApplication), keyEquivalent: "q"))
        
        self.statusItem.menu = menu
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        timer.invalidate()
    }

    func applicationDidResignActive(_ notification: Notification) {
        NSApplication.shared.hide(nil)
    }
    
    @objc func onDeleteAllDatas(_ notification: Notification) {
        snippetItems.items = []
    }
    
    @objc func showPreferences(_ sender: Any?) {
        preferencesWindowController.show()
    }
    
    @objc func quitApplication(_ sender: Any?) {
        NSApplication.shared.terminate(nil)
    }
    
    @objc func checkForUpdate(_ sender: Any) {
        if updater.canCheckForUpdates {
            updater.checkForUpdates()
        }
    }
    
    @objc func openApplication(_ sender: Any?) {
        NSApplication.shared.activate(ignoringOtherApps: true)
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
    
    @IBAction func checkForUpdateCommand(_ sender: Any) {
        if updater.canCheckForUpdates {
            updater.checkForUpdates()
        }
    }
}
