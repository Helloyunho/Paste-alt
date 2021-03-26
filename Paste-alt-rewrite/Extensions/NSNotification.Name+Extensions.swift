//
//  NSNotification.Name+Extensions.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/18.
//

import Foundation

extension NSNotification.Name {
    static let NSPasteboardDidChange: NSNotification.Name = .init("NSPasteboardDidChange")
    static let CopyCommandCalled: NSNotification.Name = .init("CopyCommandCalled")
    static let DeleteCommandCalled: NSNotification.Name = .init("DeleteCommandCalled")
    static let DeleteAllCommandCalled: NSNotification.Name = .init("DeleteAllCommandCalled")
    static let AddSnippetItemFromBackground: NSNotification.Name = .init("AddSnippetItemFromBackground")
}
