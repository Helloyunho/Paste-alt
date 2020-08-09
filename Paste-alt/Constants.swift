//
//  Constants.swift
//  Paste-alt
//
//  Created by Helloyunho on 2020/08/01.
//  Copyright © 2020 Helloyunho. All rights reserved.
//

import Foundation
import SQLite

let documentsDirectory = NSSearchPathForDirectoriesInDomains(
    .applicationSupportDirectory, .userDomainMask, true
).first! + "/" + Bundle.main.bundleIdentifier!

func makeDocumentsDirectory() {
    do {
        try FileManager.default.createDirectory(
            atPath: documentsDirectory, withIntermediateDirectories: true, attributes: nil
        )
    } catch {
        NSLog(error.localizedDescription)
    }
}

func insertNewSnippet(snippet: SnippetItem) -> Void {
    makeDocumentsDirectory()
    do {
        let conn = try Connection("\(documentsDirectory)/Paste-alt.db")

        let snippets = Table("snippets")
        let uuid = Expression<String>("uuid")
        let date = Expression<Date>("date")
        let programIdentifier = Expression<String>("programIdentifier")
        try conn.run(snippets.create(ifNotExists: true) { table in
            table.column(uuid, primaryKey: true)
            table.column(programIdentifier)
            table.column(date, unique: true)
        })
        
        let snippetDatas = Table("snippetDatas")
        let type = Expression<String>("type")
        let data = Expression<SQLite.Blob>("data")
        try conn.run(snippetDatas.create(ifNotExists: true) { table in
            table.column(uuid)
            table.column(type)
            table.column(data)
        })
        
        let snippetPrograms = Table("snippetPrograms")
        let name = Expression<String>("name")
        let image = Expression<SQLite.Blob>("image")
        try conn.run(snippetPrograms.create(ifNotExists: true) { table in
            table.column(programIdentifier, primaryKey: true)
            table.column(name)
            table.column(image)
        })
        
        try conn.run(snippets.insert(or: .replace, uuid <- snippet.id, programIdentifier <- snippet.program.programIdentifier, date <- snippet.time))
        try conn.run(snippetPrograms.insert(or: .replace, programIdentifier <- snippet.program.programIdentifier, name <- snippet.program.programName, image <- (snippet.program.programIcon.tiffRepresentation ?? Data()).datatypeValue))
        for (snippetType, snippetData) in snippet.contentForType {
            try conn.run(snippetDatas.insert(or: .replace, uuid <- snippet.id, type <- snippetType.rawValue, data <- (snippetData ?? Data()).datatypeValue))
        }
    } catch {
        NSLog(error.localizedDescription)
    }
}

