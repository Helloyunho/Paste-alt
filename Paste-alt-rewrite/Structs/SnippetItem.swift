//
//  SnippetItem.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/18.
//

import Foundation
import SwiftUI
import UIColor_Hex_Swift

struct SnippetProgram {
    var programName: String
    var programIcon: NSImage?
    var programIdentifier: String
}

private var programs: [String: SnippetProgram] = [:]
private var datas: [Data: SnippetContentType] = [:]

struct SnippetItem: Identifiable, Equatable {
    static func == (lhs: SnippetItem, rhs: SnippetItem) -> Bool {
        lhs.program.programIdentifier == rhs.program.programIdentifier && lhs.contentForType == rhs.contentForType
    }

    var id: String
    var program: SnippetProgram
    var contentForType: [NSPasteboard.PasteboardType: Data]
    var date: Date

    init(id: String?, program: NSRunningApplication?, contentForType: [NSPasteboard.PasteboardType: Data], date: Date?) {
        let bundleID = program?.bundleIdentifier ?? "com.example.untitled"
        if !programs.keys.contains(bundleID) {
            programs[bundleID] = .init(
                programName: program?.localizedName ?? "Untitled",
                programIcon: program?.icon, programIdentifier: bundleID)
        }

        self.program = programs[bundleID]!
        self.contentForType = contentForType
        self.id = id ?? UUID().uuidString
        self.date = date ?? Date()
    }

    init(id: String?, program: SnippetProgram, contentForType: [NSPasteboard.PasteboardType: Data], date: Date?) {
        let bundleID = program.programIdentifier
        if !programs.keys.contains(bundleID) {
            programs[bundleID] = program
        }
        self.program = programs[bundleID]!
        self.contentForType = contentForType
        self.id = id ?? UUID().uuidString
        self.date = date ?? Date()
    }

    func getBestData() -> SnippetContentType {
        if let content = contentForType[.png] ?? contentForType[.tiff] {
            if let cached = datas[content] {
                return cached
            } else {
                if let nsimage = NSImage(data: content) {
                    datas[content] = nsimage
                    return nsimage
                }
            }
        }
        
        if let content = contentForType[.URL] {
            if let cached = datas[content] {
                return cached
            } else {
                if let url = String(data: content, encoding: .utf8) {
                    if url.validateUrl() {
                        let urlWithMetas = URLWithMetadatas(url: url)
                        datas[content] = urlWithMetas
                        return urlWithMetas
                    }
                }
            }
        }
        
        if let content = contentForType[.fileURL] {
            if let cached = datas[content] {
                return cached
            } else {
                if let url = String(data: content, encoding: .utf8) {
                    let fileUrlStruct = FileURLStruct(url: url)
                    datas[content] = fileUrlStruct
                    return fileUrlStruct
                }
            }
        }
        
        if let content = contentForType[.string] {
            if let cached = datas[content] {
                return cached
            } else {
                if let string = String(data: content, encoding: .utf8) {
                    if string.starts(with: "#") {
                        if let nsColor = NSColor.init(string) {
                            datas[content] = nsColor
                            return nsColor
                        }
                    }
                    
                    if string.validateUrl() {
                        let urlWithMetas = URLWithMetadatas(url: string)
                        datas[content] = urlWithMetas
                        return urlWithMetas
                    }
                    
                    if let content = contentForType[.rtf] {
                        if let nsattributedstring = NSAttributedString(rtf: content, documentAttributes: nil) {
                            datas[content] = nsattributedstring
                            return nsattributedstring
                        }
                    } else {
                        datas[content] = string
                        return string
                    }
                }
            }
        }

        return "Cannot find good data"
    }
    
    mutating func updateDate() {
        self.date = Date()
    }
}
