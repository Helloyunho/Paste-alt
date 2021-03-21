//
//  DatabasePool+Extensions.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/21.
//

import Foundation
import GRDB

extension DatabasePool {
    func writeSafely(_ action: (Database) throws -> Void) {
        do {
            try self.write { db in
                try action(db)
            }
        } catch {
            defaultLogger.error("\(String(describing: error))")
        }
    }
    
    func readSafely(_ action: (Database) throws -> Void) {
        do {
            try self.read { db in
                try action(db)
            }
        } catch {
            defaultLogger.error("\(String(describing: error))")
        }
    }
}
