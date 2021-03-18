//
//  SnippetContentType.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/18.
//

import SwiftUI
import Foundation
import AppKit

protocol SnippetContentType {}
extension String: SnippetContentType {}
extension NSImage: SnippetContentType {}
