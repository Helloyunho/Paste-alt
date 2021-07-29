//
//  FileURLStruct.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/20.
//

import AppKit
import Foundation

struct FileURLStruct {
    var url: String
    var icon: NSImage

    init(url: String) {
        let urlToURL = URL(string: url)!
        self.url = urlToURL.path
        self.icon = NSWorkspace.shared.icon(forFile: urlToURL.path)
    }
}
