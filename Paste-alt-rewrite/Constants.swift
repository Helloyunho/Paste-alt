//
//  Constants.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/20.
//

import Foundation
import GRDB

var dontUpdate = false

private let documentURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
let dbPool = try! DatabasePool(path: documentURL.appendingPathComponent("paste-alt.db").path)
