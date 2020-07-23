//
//  NSNotificationExtension.swift
//  Paste-alt
//
//  Created by Helloyunho on 2020/06/26.
//  Copyright © 2020 Helloyunho. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    public static let NSPasteboardDidChange: NSNotification.Name = .init(
        rawValue: "pasteboardDidChangeNotification")
    public static let CopyCommandCalled: NSNotification.Name = .init(
        rawValue: "CopyCommandCalled")
}
