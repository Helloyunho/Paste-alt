//
//  SnippetItem.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/18.
//

import Foundation
import SwiftUI

struct SnippetProgram {
    var programName: String
    var programIcon: NSImage?
    var programIdentifier: String
}

var programs: [String: SnippetProgram] = [:]

struct SnippetItem: Identifiable, Equatable {
    static func == (lhs: SnippetItem, rhs: SnippetItem) -> Bool {
        lhs.program.programIdentifier == rhs.program.programIdentifier && lhs.contentForType == rhs.contentForType
    }

    var id: String
    var program: SnippetProgram
    var contentForType: [NSPasteboard.PasteboardType: Data?]
    var time: Date

    init(id: String?, program: NSRunningApplication?, contentForType: [NSPasteboard.PasteboardType: Data?], time: Date?) {
        let bundleID = program?.bundleIdentifier ?? "com.example.untitled"
        if !programs.keys.contains(bundleID) {
            programs[bundleID] = .init(
                programName: program?.localizedName ?? "Untitled",
                programIcon: program?.icon, programIdentifier: bundleID)
        }

        self.program = programs[bundleID]!
        self.contentForType = contentForType
        self.id = id ?? UUID().uuidString
        self.time = time ?? Date()
    }

    init(id: String?, program: SnippetProgram, contentForType: [NSPasteboard.PasteboardType: Data?], time: Date?) {
        let bundleID = program.programIdentifier
        if !programs.keys.contains(bundleID) {
            programs[bundleID] = program
        }
        self.program = programs[bundleID]!
        self.contentForType = contentForType
        self.id = id ?? UUID().uuidString
        self.time = time ?? Date()
    }

    func getBestData() -> SnippetContentType {
        if let content = contentForType[.png] ?? contentForType[.tiff] {
            if let image = NSImage(data: content!) {
                return image
            }
        } else if let content = contentForType[.string] {
            return String(data: content!, encoding: .utf8)!
        }

        return "Cannot find good data"
    }
}
