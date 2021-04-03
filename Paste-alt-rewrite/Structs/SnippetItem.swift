//
//  SnippetItem.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/18.
//

import Foundation
import GRDB
import PDFKit
import SwiftUI
import UIColor_Hex_Swift

struct SnippetProgram: Equatable {
    var name: String
    var icon: NSImage?
    var identifier: String
    
    static func == (lhs: SnippetProgram, rhs: SnippetProgram?) -> Bool {
        lhs.name == rhs?.name && lhs.identifier == rhs?.identifier && lhs.icon == rhs?.icon
    }
    
    static func == (lhs: SnippetProgram, rhs: NSRunningApplication?) -> Bool {
        lhs.name == rhs?.localizedName && lhs.identifier == rhs?.bundleIdentifier && lhs.icon == rhs?.icon
    }
    
    static func != (lhs: SnippetProgram, rhs: SnippetProgram?) -> Bool {
        !(lhs == rhs)
    }
    
    static func != (lhs: SnippetProgram, rhs: NSRunningApplication?) -> Bool {
        !(lhs == rhs)
    }
}

private var programs: [String: SnippetProgram] = [:]
private var datas: [Data: SnippetContentType] = [:]

func resetAllGlobalDatas() -> Void {
    programs.removeAll()
    datas.removeAll()
}

struct SnippetItem: Identifiable, Equatable, FetchableRecord, TableRecord, PersistableRecord {
    static func == (lhs: SnippetItem, rhs: SnippetItem) -> Bool {
        lhs.program.identifier == rhs.program.identifier && lhs.contentForType == rhs.contentForType
    }

    var id: String
    var program: SnippetProgram
    var contentForType: [NSPasteboard.PasteboardType: Data]
    var date: Date

    init(id: String?, program: NSRunningApplication?, contentForType: [NSPasteboard.PasteboardType: Data], date: Date?) {
        let bundleID = program?.bundleIdentifier ?? "com.example.untitled"
        if programs[bundleID] == nil || programs[bundleID]! != program {
            programs[bundleID] = .init(
                name: program?.localizedName ?? "Untitled",
                icon: program?.icon, identifier: bundleID)
        }

        self.program = programs[bundleID]!
        self.contentForType = contentForType
        self.id = id ?? UUID().uuidString
        self.date = date ?? Date()
    }

    init(id: String?, program: SnippetProgram, contentForType: [NSPasteboard.PasteboardType: Data], date: Date?) {
        let bundleID = program.identifier
        if programs[bundleID] == nil || programs[bundleID]! != program {
            programs[bundleID] = program
        }
        self.program = programs[bundleID]!
        self.contentForType = contentForType
        self.id = id ?? UUID().uuidString
        self.date = date ?? Date()
    }
    
    static var databaseTableName = "snippetItems"
    
    enum Columns: String, ColumnExpression {
        case id, programName, programIdentifier, programIcon, date
    }
    
    static func createTable(_ db: Database) throws -> Void {
        try db.create(table: databaseTableName, ifNotExists: true) { t in
            t.column("id", .text).notNull().unique().primaryKey()
            t.column("programName", .text)
            t.column("programIdentifier", .text)
            t.column("programIcon", .blob)
            t.column("date", .date)
        }
    }
    
    init(row: Row) {
        id = row[Columns.id]
        let bundleID: String = row[Columns.programIdentifier] ?? "com.example.untitled"
        if programs[bundleID] == nil {
            let programName: String? = row[Columns.programName]
            let programIcon: Data? = row[Columns.programIcon]
            programs[bundleID] = SnippetProgram(name: programName ?? "Untitled", icon: programIcon != nil ? NSImage(data: programIcon!) : nil, identifier: bundleID)
        }
        program = programs[bundleID]!
        date = row[Columns.date]
        contentForType = [:]
    }
    
    func fetchingContentsFromDB(_ db: Database) -> SnippetItem {
        var contentForType: [NSPasteboard.PasteboardType: Data] = [:]
        if let contents = try? SnippetContentTable.filter(SnippetContentTable.Columns.forID == id).fetchAll(db) {
            for content in contents {
                contentForType[content.type] = content.data
            }
        }
        
        return SnippetItem(id: id, program: program, contentForType: contentForType, date: date)
    }
    
    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.programName] = program.name
        container[Columns.programIcon] = program.icon?.tiffRepresentation
        container[Columns.programIdentifier] = program.identifier
        container[Columns.date] = date
    }
    
    func insertContents(_ db: Database) throws -> Void {
        for (type, data) in contentForType {
            try SnippetContentTable(id: nil, forID: id, type: type, data: data).insert(db)
        }
    }
    
    func insertSelf(_ db: Database) throws -> Void {
        try self.insert(db)
        try self.insertContents(db)
    }
    
    func deleteSelf(_ db: Database) throws -> Void {
        try self.delete(db)
        for (_, content) in contentForType {
            datas.removeValue(forKey: content)
        }
    }

    func getBestData() -> SnippetContentType {
        if let content = contentForType[.png] ?? contentForType[.tiff] {
            if let cached = datas[content] {
                return cached
            } else if let nsimage = NSImage(data: content) {
                datas[content] = nsimage
                return nsimage
            }
        }
        
        if let content = contentForType[.URL] {
            if let cached = datas[content] {
                return cached
            } else if let url = String(data: content, encoding: .utf8) {
                if url.validateUrl() {
                    let urlWithMetas = URLWithMetadatas(url: url)
                    datas[content] = urlWithMetas
                    return urlWithMetas
                }
            }
        }
        
        if let content = contentForType[.fileURL] {
            if let cached = datas[content] {
                return cached
            } else if let url = String(data: content, encoding: .utf8) {
                let fileUrlStruct = FileURLStruct(url: url)
                datas[content] = fileUrlStruct
                return fileUrlStruct
            }
        }
        
        if let content = contentForType[.color] {
            if let cached = datas[content] {
                return cached
            } else if let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: content) {
                // Seems like color from pasteboard is wide display color and uicolor hex swift hates it
                let nsColor = NSColor(red: color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: color.alphaComponent)
                datas[content] = nsColor
                return nsColor
            }
        }
        
        if let content = contentForType[.string] {
            if let cached = datas[content] {
                return cached
            } else if let string = String(data: content, encoding: .utf8) {
                if string.validColorHex() {
                    if let nsColor = NSColor(string) {
                        datas[content] = nsColor
                        return nsColor
                    }
                }
                
                if string.validateUrl() {
                    let urlWithMetas = URLWithMetadatas(url: string)
                    datas[content] = urlWithMetas
                    return urlWithMetas
                }
                
                if let content = contentForType[.pdf] {
                    if let cached = datas[content] {
                        return cached
                    } else if let pdf = PDFDocument(data: content) {
                        datas[content] = pdf
                        return pdf
                    }
                } else if let content = contentForType[.rtf] {
                    if let cached = datas[content] {
                        return cached
                    } else if let nsattributedstring = NSAttributedString(rtf: content, documentAttributes: nil) {
                        datas[content] = nsattributedstring
                        return nsattributedstring
                    }
                } else {
                    datas[content] = string
                    return string
                }
            }
        }

        return "Cannot find good data"
    }
    
    func search(for searchString: String) -> Bool {
        if searchString == "" {
            return true
        }

        if program.name.contains(searchString) {
            return true
        }
        if program.identifier.contains(searchString) {
            return true
        }
        
        if let content = contentForType[.URL] {
            if let cached = datas[content] {
                if let url = cached as? URLWithMetadatas {
                    if url.url.contains(searchString) {
                        return true
                    }
                }
            } else {
                if let url = String(data: content, encoding: .utf8) {
                    if url.contains(searchString) {
                        return true
                    }
                }
            }
        }
        
        if let content = contentForType[.fileURL] {
            if let cached = datas[content] {
                if let url = cached as? FileURLStruct {
                    if url.url.contains(searchString) {
                        return true
                    }
                }
            } else {
                if let url = String(data: content, encoding: .utf8) {
                    if url.contains(searchString) {
                        return true
                    }
                }
            }
        }
        
        if let content = contentForType[.color] {
            if let cached = datas[content] {
                if let color = cached as? NSColor {
                    if color.hexString().contains(searchString) {
                        return true
                    }
                }
            } else {
                if let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: content) {
                    let nsColor = NSColor(red: color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: color.alphaComponent)
                    if nsColor.hexString().contains(searchString) {
                        return true
                    }
                }
            }
        }
        
        if let content = contentForType[.string] {
            if let cached = datas[content] {
                if let color = cached as? NSColor {
                    if color.hexString().contains(searchString) {
                        return true
                    }
                }

                if let url = cached as? FileURLStruct {
                    if url.url.contains(searchString) {
                        return true
                    }
                }
                
                if let pdf = cached as? PDFDocument {
                    if pdf.string?.contains(searchString) ?? false {
                        return true
                    }
                }
                
                if let nsattributedstring = NSAttributedString(rtf: content, documentAttributes: nil) {
                    if nsattributedstring.string.contains(searchString) {
                        return true
                    }
                }
            } else {
                if let string = String(data: content, encoding: .utf8) {
                    if string.contains(searchString) {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    mutating func updateDate(_ db: Database) throws -> Void {
        date = Date()
        try self.update(db)
    }
}
