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
                        .padding(.all, geometryGetter(geometry) * 0.076923077)
                        .frame(width: geometryGetter(geometry))
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
                        }
                    }
                }
            }
            .frame(
                height: globalGeometry.size.height
            )
        }
    }
    
    func setFirstSelected() {
        self.selected = self.snippets.first?.id ?? ""
    }
}


struct Clipboard_Previews: PreviewProvider {
    static var previews: some View {
        Text("Previews are not supported.")
    }
}
