//
//  SnippetItems.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/21.
//

import Foundation
import SwiftUI

class SnippetItems: ObservableObject {
    @Published var items: [SnippetItem] = []
    @Published var isLoading: Bool = true
}
