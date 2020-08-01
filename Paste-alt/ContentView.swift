//
//  ContentView.swift
//  Paste-alt
//
//  Created by Helloyunho on 2020/06/21.
//  Copyright © 2020 Helloyunho. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var snippetItems: [SnippetItem]
    var body: some View {
        Clipboard(snippets: $snippetItems)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onReceive(NotificationCenter.default.publisher(for: .NSPasteboardDidChange)) {
                notification in
                guard let pasteboard = notification.object as? NSPasteboard else { return }
                guard let items = pasteboard.pasteboardItems else { return }

                for item in items {
                    var isHandoff = false
                    var contents: [NSPasteboard.PasteboardType: Data?] = [:]
                    for type in item.types {
                        if type == .init("com.apple.is-remote-clipboard") {
                            isHandoff = true
                        }
                        contents[type] = item.data(forType: type)
                    }

                    if isHandoff {
                        let programName = "Hand-off"
                        let programIcon = NSImage(named: "hand-off")!
                        let programIdentifier = "com.apple.handoff"
                        let program = SnippetProgram(
                            programName: programName,
                            programIcon: programIcon,
                            programIdentifier: programIdentifier
                        )
                        let snippetItem = SnippetItem(
                            id: nil, program: program,
                            contentForType: contents, time: nil)
                        self.snippetItems = self.snippetItems.filter({ item in
                            return item.program.programIdentifier != programIdentifier
                                || item.contentForType != contents
                        })
                        
                        if self.snippetItems.count != 0 {
                            self.snippetItems.insert(snippetItem, at: 0)
                        } else {
                            self.snippetItems.append(snippetItem)
                        }
                        
                        insertNewSnippet(snippet: snippetItem)
                    } else {
                        let workspace = NSWorkspace.shared
                        let frontmost = workspace.frontmostApplication
                        let programIdentifier =
                            frontmost?.bundleIdentifier ?? "com.example.untitled"
                        let snippetItem = SnippetItem(
                            id: nil, program: frontmost,
                            contentForType: contents, time: nil)
                        self.snippetItems = self.snippetItems.filter({ item in
                            return item.program.programIdentifier != programIdentifier
                                || item.contentForType != contents
                        })

                        if self.snippetItems.count != 0 {
                            self.snippetItems.insert(snippetItem, at: 0)
                        } else {
                            self.snippetItems.append(snippetItem)
                        }
                        
                        insertNewSnippet(snippet: snippetItem)
                    }
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(snippetItems: [
            .init(
                id: nil, program: .init(
                    programName: Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String,
                    programIcon: NSImage(named: "test")!,
                    programIdentifier: Bundle.main.infoDictionary![kCFBundleIdentifierKey as String]
                        as! String), contentForType: [.string: "Hello! This is just a hello message. If you want to use this, try copying something text!".data(using: .utf8)], time: nil)
        ])
    }
}
