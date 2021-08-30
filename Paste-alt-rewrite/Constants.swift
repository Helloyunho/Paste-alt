//
//  Constants.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/20.
//

import Foundation
import GRDB
import os.log

var dontUpdate = false

// swiftlint:disable force_try
private let documentURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
// swiftlint:disable force_try
let dbPool = try! DatabasePool(path: documentURL.appendingPathComponent("paste-alt.db").path)

let defaultLogger = Logger()

let limitAtOneSnippets = 10
