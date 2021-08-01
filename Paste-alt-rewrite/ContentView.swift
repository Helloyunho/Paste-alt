//
//  ContentView.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/14.
//

import GRDB
import SwiftUI

struct ContentView: View {
    @ObservedObject var snippetItems: SnippetItems
    @State var selectedSnippet: SnippetItem?
    @State var searchFor: String = ""
    let strokeSize: CGFloat = 0.02

    func copySnippet(_ snippet: SnippetItem) {
        let item = NSPasteboardItem()
        for (type, content) in snippet.contentForType {
            item.setData(content, forType: type)
        }
        NSPasteboard.general.clearContents()
        dontUpdate = true
        NSPasteboard.general.writeObjects([item])
        if self.snippetItems.items.move(snippet, to: 0) {
            DispatchQueue.global().async {
                dbPool.writeSafely { db in
                    try self.snippetItems.items[0].updateDate(db)
                }
            }
        } else {
            self.snippetItems.items.insert(snippet, at: 0)
            if self.snippetItems.items.count > limitAtOneSnippets * 2 {
                self.snippetItems.items.removeLast()
            }
        }
    }

    func deleteSnippet(_ snippet: SnippetItem) {
        let idx = self.snippetItems.items.firstIndex(of: snippet)
        _ = self.snippetItems.items.remove(snippet)
        DispatchQueue.global(qos: .userInitiated).async {
            dbPool.writeSafely { db in
                try snippet.deleteSelf(db)
            }
        }

        if let lastDate = self.snippetItems.items.last?.date {
            DispatchQueue.global(qos: .userInitiated).async {
                dbPool.readSafely { db in
                    let items = try SnippetItem.filter(lastDate > SnippetItem.Columns.date).limit(1).fetchAll(db)
                    for item in items {
                        let object = item.fetchingContentsFromDB(db)
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .AddSnippetItemFromBackground, object: object)
                        }
                    }
                }
                DispatchQueue.main.async {
                    snippetItems.isLoading = false
                }
            }
            self.snippetItems.isLoading = true
        }

        if snippet == self.selectedSnippet {
            if let idx = idx {
                self.selectedSnippet = self.snippetItems.items[idx]
            } else {
                self.selectedSnippet = nil
            }
        }
    }

    var body: some View {
        GeometryReader { windowGeometry in
            VStack(spacing: 0) {
                // TODO: Make search bar
                GeometryReader { scrollviewGeometry in
                    let smallSize = scrollviewGeometry.size.width > scrollviewGeometry.size.height ? scrollviewGeometry.size.height : scrollviewGeometry.size.width
                    ScrollView(.horizontal, showsIndicators: true) {
                        LazyHStack(spacing: 0) {
                            ForEach(snippetItems.items) { snippet in
                                if snippet.search(for: searchFor) {
                                    ClipboardElement(name: snippet.program.name, content: snippet.getBestData(), image: snippet.program.icon)
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
                                        .onAppear {
                                            if !snippetItems.isLoading {
                                                if let currentIndex = self.snippetItems.items.firstIndex(of: snippet) {
                                                    if currentIndex >= self.snippetItems.items.count - limitAtOneSnippets {
                                                        if let lastDate = self.snippetItems.items.last?.date {
                                                            DispatchQueue.global(qos: .userInteractive).async {
                                                                dbPool.readSafely { db in
                                                                    let items = try SnippetItem.filter(lastDate > SnippetItem.Columns.date).limit(limitAtOneSnippets).fetchAll(db)
                                                                    for item in items {
                                                                        let object = item.fetchingContentsFromDB(db)
                                                                        DispatchQueue.main.async {
                                                                            NotificationCenter.default.post(name: .AddSnippetItemFromBackground, object: object)
                                                                        }
                                                                    }
                                                                }
                                                                DispatchQueue.main.async {
                                                                    snippetItems.isLoading = false
                                                                }
                                                            }
                                                            snippetItems.isLoading = true
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                }
                            }
                            if snippetItems.isLoading {
                                ProgressView()
                                    .aspectRatio(1.0, contentMode: .fit)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding(smallSize * 0.05)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onReceive(NotificationCenter.default.publisher(for: .AddSnippetItemFromBackground)) { notification in
            guard let item = notification.object as? SnippetItem else { return }
            self.snippetItems.items.append(item)
        }
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
                        name: programName,
                        icon: programIcon,
                        identifier: programIdentifier)
                    snippetItem = SnippetItem(
                        id: nil, program: program,
                        contentForType: contents, date: nil)
                } else {
                    let frontmost = NSWorkspace.shared.frontmostApplication
                    snippetItem = SnippetItem(
                        id: nil, program: frontmost,
                        contentForType: contents, date: nil)
                }

                if self.snippetItems.items.move(snippetItem, to: 0) {
                    DispatchQueue.global(qos: .userInitiated).async {
                        dbPool.writeSafely { db in
                            try self.snippetItems.items[0].updateDate(db)
                        }
                    }
                } else {
                    self.snippetItems.items.insert(snippetItem, at: 0)
                    if self.snippetItems.items.count > limitAtOneSnippets * 2 {
                        self.snippetItems.items.removeLast()
                    }
                }

                DispatchQueue.global(qos: .userInitiated).async {
                    dbPool.writeSafely { db in
                        try snippetItem.insertSelf(db)
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
        .onReceive(NotificationCenter.default.publisher(for: .DeleteAllCommandCalled)) { _ in
            selectedSnippet = nil
        }
    }
}
