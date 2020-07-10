//
//  ContentView.swift
//  Paste-alt
//
//  Created by Helloyunho on 2020/06/21.
//  Copyright © 2020 Helloyunho. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var snippetItems: [SnippetItem] = [
        .init(
            program: .init(
                programName: Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String,
                programIcon: NSImage(named: "test")!,
                programIdentifier: Bundle.main.infoDictionary![kCFBundleIdentifierKey as String]
                    as! String), content: "Hello!")
    ]
    var body: some View {
        Clipboard(snippets: $snippetItems)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onReceive(NotificationCenter.default.publisher(for: .NSPasteboardDidChange)) {
                notification in
                guard let pasteboard = notification.object as? NSPasteboard else { return }
                guard let items = pasteboard.pasteboardItems else { return }

                for item in items {
                    let workspace = NSWorkspace.shared
                    let frontmost = workspace.frontmostApplication
                    for type in item.types {
                        if type == .string {
                            let programIdentifier =
                                frontmost?.bundleIdentifier ?? "com.example.untitled"
                            let content = item.data(forType: type)
                            snippetItems = snippetItems.filter({ item in
                                return item.program.programIdentifier != programIdentifier
                                    || item.content != content
                            })

                            snippetItems.insert(
                                SnippetItem(
                                    program: frontmost,
                                    content: content, type: type), at: 0)
                        }
                    }
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
