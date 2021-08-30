//
//  SnippetContentType.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/18.
//

import AppKit
import Foundation
import PDFKit
import SwiftUI

protocol SnippetContentType {}
extension String: SnippetContentType {}
extension NSImage: SnippetContentType {}
extension NSAttributedString: SnippetContentType {}
extension NSColor: SnippetContentType {}
extension URLWithMetadatas: SnippetContentType {}
extension FileURLStruct: SnippetContentType {}
extension PDFDocument: SnippetContentType {}
