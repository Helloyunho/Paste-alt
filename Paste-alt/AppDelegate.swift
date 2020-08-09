//
//  AppDelegate.swift
//  Paste-alt
//
//  Created by Helloyunho on 2020/06/21.
//  Copyright © 2020 Helloyunho. All rights reserved.
//

import Cocoa
import SwiftUI
import Preferences
import KeyboardShortcuts
import SQLite

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
    var snippetsItems: [SnippetItem] = []
    var olderItemsCount: Int = 0
    var firstRun = true
    
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
        makeDocumentsDirectory()
        do {
            let conn = try Connection("\(documentsDirectory)/Paste-alt.db")

            let snippets = Table("snippets")
            let uuid = Expression<String>("uuid")
            let date = Expression<Date>("date")
            let programIdentifier = Expression<String>("programIdentifier")
            try conn.run(snippets.create(ifNotExists: true) { table in
                table.column(uuid, primaryKey: true)
                table.column(programIdentifier)
                table.column(date, unique: true)
            })

            let snippetDatas = Table("snippetDatas")
            let type = Expression<String>("type")
            let data = Expression<SQLite.Blob>("data")
            try conn.run(snippetDatas.create(ifNotExists: true) { table in
                table.column(uuid)
                table.column(type)
                table.column(data)
            })

            let snippetPrograms = Table("snippetPrograms")
            let name = Expression<String>("name")
            let image = Expression<SQLite.Blob>("image")
            try conn.run(snippetPrograms.create(ifNotExists: true) { table in
                table.column(programIdentifier, primaryKey: true)
                table.column(name)
                table.column(image)
            })

            for snippet in try conn.prepare(snippets.order(date.desc)) {
                let snippetUUID = snippet[uuid]
                let snippetProgramIdentifier = snippet[programIdentifier]

                var datas: [NSPasteboard.PasteboardType: Data?] = [:]
                for snippetData in try conn.prepare(snippetDatas.filter(uuid == snippetUUID).select(data, type)) {
                    datas[NSPasteboard.PasteboardType(rawValue: snippetData[type])] = Data.fromDatatypeValue(snippetData[data])
                }

                if let snippetProgram = try conn.pluck(snippetPrograms.filter(programIdentifier == snippetProgramIdentifier).select(name, image)) {
                    self.snippetsItems.append(SnippetItem(
                        id: snippetUUID,
                        program: .init(
                            programName: snippetProgram[name],
                            programIcon: NSImage(data: Data.fromDatatypeValue(snippetProgram[image])) ?? NSImage(named: "test")!,
                            programIdentifier: snippetProgramIdentifier
                        ),
                        contentForType: datas, time: nil
                    ))
                } else {
                    self.snippetsItems.append(SnippetItem(
                        id: snippetUUID,
                        program: .init(
                            programName: "Untitled",
                            programIcon: NSImage(named: "test")!,
                            programIdentifier: snippetProgramIdentifier
                        ),
                        contentForType: datas, time: nil
                    ))
                }
            }

            self.olderItemsCount = self.snippetsItems.count
        } catch {
            NSLog(error.localizedDescription)
        }
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
        let contentView = ContentView(snippetItems: self.snippetsItems.count > 0 ? self.snippetsItems : [
            .init(
                id: nil, program: .init(
                    programName: Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String,
                    programIcon: NSImage(named: "test")!,
                    programIdentifier: Bundle.main.infoDictionary![kCFBundleIdentifierKey as String]
                        as! String), contentForType: [.string: "Hello! This is just a hello message. If you want to use this, try copying something text!".data(using: .utf8)], time: nil)
        ])
        let screen = NSScreen.main!

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: screen.frame.width, height: screen.frame.height * 0.3),
            styleMask: [.closable, .miniaturizable],
            backing: .buffered, defer: false)
        window.contentView = NSHostingView(
            rootView: contentView.background(
                VisualEffectView(
                    material: NSVisualEffectView.Material.selection,
                    blendingMode: NSVisualEffectView.BlendingMode.behindWindow)))
        window.makeKeyAndOrderFront(nil)
        window.level = .floating
        
        KeyboardShortcuts.onKeyDown(for: .openSnippetsView) {
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationDidResignActive(_ notification: Notification) {
        NSApplication.shared.hide(nil)
    }

    @IBAction func copyCommand(_ sender: Any) {
        NotificationCenter.default.post(
            name: .CopyCommandCalled, object: nil)
    }
    
    @IBAction func preferencesCommand(_ sender: Any) {
        preferencesWindowController.show()
    }
}
