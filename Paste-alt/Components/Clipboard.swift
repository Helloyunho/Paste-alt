//
//  Clopboard.swift

//  Paste-alt
//
//  Created by Helloyunho on 2020/06/21.
//  Copyright © 2020 Helloyunho. All rights reserved.
//

import SwiftUI

let baseColor = NSColor(red: 236 / 255, green: 240 / 255, blue: 243 / 255, alpha: 1)

struct Clipboard: View {
    @Binding var snippets: [SnippetItem]
    @State var selected = ""
    var body: some View {
        GeometryReader { geometry in
            let globalGeometry = geometry.frame(in: .global)
            let geometryGetted = geometryGetter(geometry)

            ScrollView(.horizontal, showsIndicators: true) {
                HStack {
                    ForEach(snippets) { snippet in
                        ClipboardElement(
                            image: snippet.program.programIcon, name: snippet.program.programName,
                            content: snippet.content != nil
                                ? String(
                                    decoding: snippet.content!, as: UTF8.self
                                )
                                : "\(snippet.type) type doesn't support string.",
                            selected: selected == snippet.id
                        )
                        .padding(.all, geometryGetted * 0.076923077)
                        .frame(width: geometryGetted)
                        .onAppear {
                            setFirstSelected()
                        }
                        .highPriorityGesture(
                            TapGesture().modifiers(.control).onEnded({ _ in
                                print("called")
                                self.selected = snippet.id
                            })
                        )
                        .gesture(
                            TapGesture().onEnded({ _ in
                                self.selected = snippet.id
                            })
                        ).contextMenu {
                            Button(
                                "Copy",
                                action: {
                                    let item = NSPasteboardItem()
                                    item.setData(
                                        snippet.content ?? Data(), forType: snippet.type)
                                    NSPasteboard.general.clearContents()
                                    dontUpdatePasteboard = true
                                    NSPasteboard.general.writeObjects([item])
                                    snippets = snippets.filter({ item in
                                        return item.program.programIdentifier
                                            != snippet.program.programIdentifier
                                            || item.content != snippet.content
                                    })
                                    snippets.insert(
                                        snippet, at: 0)
                                })
                            Button(
                                "Delete",
                                action: {
                                    if let index = snippets.firstIndex(of: snippet) {
                                        snippets.remove(at: index)
                                    }
                                })
                        }
                    }
                }
            }
            .frame(
                height: globalGeometry.size.height
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .CopyCommandCalled)) { _ in
            if let snippet = snippets.first(where: {$0.id == self.selected}) {
                let item = NSPasteboardItem()
                item.setData(
                    snippet.content ?? Data(), forType: snippet.type)
                NSPasteboard.general.clearContents()
                dontUpdatePasteboard = true
                NSPasteboard.general.writeObjects([item])
                snippets = snippets.filter({ item in
                    return item.program.programIdentifier
                        != snippet.program.programIdentifier
                        || item.content != snippet.content
                })
                snippets.insert(
                    snippet, at: 0)
            }
        }
    }

    func setFirstSelected() {
        self.selected = self.snippets.first?.id ?? ""
    }
}

struct Clipboard_Previews: PreviewProvider {
    @State static var snippetItems: [SnippetItem] = [
        .init(
            program: .init(
                programName: Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String,
                programIcon: NSImage(named: "test")!,
                programIdentifier: Bundle.main.infoDictionary![kCFBundleIdentifierKey as String]
                    as! String), content: "Hello!")
    ]

    static var previews: some View {
        Clipboard(snippets: $snippetItems)
    }
}
