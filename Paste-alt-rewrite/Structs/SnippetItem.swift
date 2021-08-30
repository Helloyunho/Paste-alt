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

func resetAllGlobalDatas() {
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

    static func createTable(_ db: Database) throws {
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

    func insertContents(_ db: Database) throws {
        for (type, data) in contentForType {
            try SnippetContentTable(id: nil, forID: id, type: type, data: data).insert(db)
        }
    }

    func insertSelf(_ db: Database) throws {
        try insert(db)
        try insertContents(db)
    }

    func deleteSelf(_ db: Database) throws {
        try delete(db)
        for (_, content) in contentForType {
            datas.removeValue(forKey: content)
        }
    }

    func getBestData() -> SnippetContentType {
        if let content = contentForType[.png] ?? contentForType[.tiff],
           let nsimage = NSImage(data: content)
        {
            return nsimage
        }

        if let content = contentForType[.URL],
           let url = String(data: content, encoding: .utf8),
           url.validateUrl()
        {
            let urlWithMetas = URLWithMetadatas(url: url)
            return urlWithMetas
        }

        if let content = contentForType[.fileURL],
           let url = String(data: content, encoding: .utf8)
        {
            let fileUrlStruct = FileURLStruct(url: url)
            return fileUrlStruct
        }

        if let content = contentForType[.color],
           let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: content)
        {
            // Seems like color from pasteboard is wide display color and uicolor hex swift hates it
            let nsColor = NSColor(red: color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: color.alphaComponent)
            return nsColor
        }

        if let content = contentForType[.string],
           let string = String(data: content, encoding: .utf8)
        {
            if string.validColorHex() {
                if let nsColor = NSColor(string) {
                    return nsColor
                }
            } else if string.validateUrl() {
                let urlWithMetas = URLWithMetadatas(url: string)
                return urlWithMetas
            } else if let content = contentForType[.pdf],
                      let pdf = PDFDocument(data: content)
            {
                return pdf
            } else if let content = contentForType[.rtf],
                      let nsattributedstring = NSAttributedString(rtf: content, documentAttributes: nil)
            {
                return nsattributedstring
            } else {
                return string
            }
        }

        return "Cannot find good data"
    }

    func search(for searchString: String) -> Bool {
        if searchString == "" ||
            program.name.contains(searchString) ||
            program.identifier.contains(searchString)
        {
            return true
        }

        let content = getBestData()
        switch content.self {
        case let url as URLWithMetadatas:
            return url.url.contains(searchString)
        case let url as FileURLStruct:
            return url.url.contains(searchString)
        case let color as NSColor:
            return color.hexString().contains(searchString)
        case let pdf as PDFDocument:
            return pdf.string?.contains(searchString) ?? false
        case let nsattributedstring as NSAttributedString:
            return nsattributedstring.string.contains(searchString)
        case let string as String:
            return string.contains(searchString)
        default:
            return false
        }
    }

    mutating func updateDate(_ db: Database) throws {
        date = Date()
        try update(db)
    }
}
