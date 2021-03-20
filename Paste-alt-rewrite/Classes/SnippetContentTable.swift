//
//  SnippetContentTable.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/20.
//

import AppKit
import Foundation
import GRDB

class SnippetContentTable: Record {
    var id: Int64?
    var forID: String
    var type: NSPasteboard.PasteboardType
    var data: Data
    
    static func createTable(_ db: Database) throws -> Void {
        try db.create(table: databaseTableName, ifNotExists: true) { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("forID", .text).notNull()
            t.column("type", .text).notNull()
            t.column("data", .blob).notNull()
        }
    }
    
    init(id: Int64?, forID: String, type: NSPasteboard.PasteboardType, data: Data) {
        self.id = id
        self.forID = forID
        self.type = type
        self.data = data
        super.init()
    }
    
    override class var databaseTableName: String { "snippetContents" }
    
    enum Columns: String, ColumnExpression {
        case id, forID, type, data
    }
    
    required init(row: Row) {
        id = row[Columns.id]
        forID = row[Columns.forID]
        type = NSPasteboard.PasteboardType(row[Columns.type])
        data = row[Columns.data]
        super.init(row: row)
    }
    
    override func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.forID] = forID
        container[Columns.type] = type.rawValue
        container[Columns.data] = data
    }
    
    override func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
