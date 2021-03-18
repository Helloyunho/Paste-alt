//
//  ContentView.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/14.
//

import SwiftUI

struct ContentView: View {
    @State var snippetItems: [SnippetItem] = []
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: true) {
                LazyHStack(spacing: 0) {
                    ForEach(snippetItems) { snippet in
                        ClipboardElement(name: snippet.program.programName, content: snippet.getBestData(), image: snippet.program.programIcon)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(geometry.size.height * 0.05)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onReceive(NotificationCenter.default.publisher(for: .NSPasteboardDidChange)) { notification in
            guard let pasteboard = notification.object as? NSPasteboard else { return }
            guard let items = pasteboard.pasteboardItems else { return }
            if pasteboard.types?.count == 0 { return }

            for item in items {
                var isHandoff = false
                var contents: [NSPasteboard.PasteboardType: Data] = [:]
                for type in item.types {
                    if type == .init("com.apple.is-remote-clipboard") {
                        isHandoff = true
                    }
                    if let data = item.data(forType: type) {
                        contents[type] = data
                    }
                }

                if isHandoff {
                    let programName = "Hand-off"
                    let programIcon = NSImage(named: "Hand-off")!
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
                } else {
                    let frontmost = NSWorkspace.shared.frontmostApplication
                    let snippetItem = SnippetItem(
                        id: nil, program: frontmost,
                        contentForType: contents, time: nil)

                    if !self.snippetItems.move(snippetItem, to: 0) {
                        self.snippetItems.insert(snippetItem, at: 0)
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
