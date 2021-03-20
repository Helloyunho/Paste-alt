//
//  ContentView.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/14.
//

import SwiftUI

struct ContentView: View {
    @State var snippetItems: [SnippetItem] = []
    @State var selectedSnippet: SnippetItem?
    let strokeSize: CGFloat = 0.02
    
    func copySnippet(_ snippet: SnippetItem) {
        let item = NSPasteboardItem()
        for (type, content) in snippet.contentForType {
            item.setData(content, forType: type)
        }
        NSPasteboard.general.clearContents()
        dontUpdate = true
        NSPasteboard.general.writeObjects([item])
        if self.snippetItems.move(snippet, to: 0) {
            self.snippetItems[0].date = Date()
        } else {
            self.snippetItems.insert(snippet, at: 0)
        }
    }
    
    func deleteSnippet(_ snippet: SnippetItem) {
        _ = self.snippetItems.remove(snippet)
        if snippet == selectedSnippet {
            selectedSnippet = nil
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let smallSize = geometry.size.width > geometry.size.height ? geometry.size.height : geometry.size.width
            ScrollView(.horizontal, showsIndicators: true) {
                LazyHStack(spacing: 0) {
                    ForEach(snippetItems) { snippet in
                        ClipboardElement(name: snippet.program.programName, content: snippet.getBestData(), image: snippet.program.programIcon)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(smallSize * strokeSize)
                            .overlay(RoundedRectangle(cornerRadius: smallSize / 10 + smallSize * strokeSize).strokeBorder(Color.accentColor, lineWidth: selectedSnippet?.id == snippet.id ? smallSize * strokeSize : 0))
                            .padding(smallSize * (0.05 - strokeSize))
                            .onTapGesture {
                                selectedSnippet = snippet
                            }
                            .contextMenu {
                                Button("Copy") {
                                    self.copySnippet(snippet)
                                }.keyboardShortcut("c", modifiers: [.command])
                                Button("Delete") {
                                    self.deleteSnippet(snippet)
                                }.keyboardShortcut(.delete)
                            }
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

                var snippetItem: SnippetItem
                if isHandoff {
                    let programName = "Hand-off"
                    let programIcon = NSImage(named: "Hand-off")!
                    let programIdentifier = "com.apple.handoff"
                    let program = SnippetProgram(
                        programName: programName,
                        programIcon: programIcon,
                        programIdentifier: programIdentifier)
                    snippetItem = SnippetItem(
                        id: nil, program: program,
                        contentForType: contents, date: nil)
                    self.snippetItems = self.snippetItems.filter { item in
                        item.program.programIdentifier != programIdentifier
                            || item.contentForType != contents
                    }

                    if self.snippetItems.move(snippetItem, to: 0) {
                        self.snippetItems[0].updateDate()
                    } else {
                        self.snippetItems.insert(snippetItem, at: 0)
                    }
                } else {
                    let frontmost = NSWorkspace.shared.frontmostApplication
                    snippetItem = SnippetItem(
                        id: nil, program: frontmost,
                        contentForType: contents, date: nil)

                    if self.snippetItems.move(snippetItem, to: 0) {
                        self.snippetItems[0].updateDate()
                    } else {
                        self.snippetItems.insert(snippetItem, at: 0)
                    }
                }
                
                DispatchQueue.main.async {
                    try? dbPool.write { db in
                        try? snippetItem.insertSelf(db)
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .CopyCommandCalled)) { _ in
            guard let snippet = selectedSnippet else { return }
            self.copySnippet(snippet)
        }
        .onReceive(NotificationCenter.default.publisher(for: .DeleteCommandCalled)) { _ in
            guard let snippet = selectedSnippet else { return }
            self.deleteSnippet(snippet)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
