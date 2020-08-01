//
//  SnippetItem.swift
//  Paste-alt
//
//  Created by Helloyunho on 2020/06/26.
//  Copyright © 2020 Helloyunho. All rights reserved.
//

import AppKit
import Foundation

struct SnippetProgram {
    var programName: String
    var programIcon: NSImage
    var programIdentifier: String
}

var programs: [String: SnippetProgram] = [:]

struct SnippetItem: Identifiable, Equatable {
    static func == (lhs: SnippetItem, rhs: SnippetItem) -> Bool {
        lhs.id == rhs.id
    }

    var id = UUID().uuidString
    var program: SnippetProgram
    var contentForType: [NSPasteboard.PasteboardType: Data?]

    init(program: NSRunningApplication?, contentForType: [NSPasteboard.PasteboardType: Data?]) {
        let bundleID = program?.bundleIdentifier ?? "com.example.untitled"
        if !programs.keys.contains(bundleID) {
            programs[bundleID] = .init(
                programName: program?.localizedName ?? "Untitled",
                programIcon: program?.icon ?? NSImage(named: "test")!, programIdentifier: bundleID)
        }

        self.program = programs[bundleID]!
        self.contentForType = contentForType
    }

    init(program: SnippetProgram, contentForType: [NSPasteboard.PasteboardType: Data?]) {
        let bundleID = program.programIdentifier
        if !programs.keys.contains(bundleID) {
            programs[bundleID] = program
        }
        self.program = programs[bundleID]!
        self.contentForType = contentForType
    }
}
