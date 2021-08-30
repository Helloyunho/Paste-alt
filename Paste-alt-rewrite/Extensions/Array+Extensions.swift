//
//  Array+Extensions.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/18.
//

import Foundation

// From https://stackoverflow.com/a/50205000/9376340
extension Array where Element: Equatable {
    mutating func move(_ element: Element, to newIndex: Index) -> Bool {
        if let oldIndex: Int = self.firstIndex(of: element) {
            self.move(from: oldIndex, to: newIndex)
            return true
        } else {
            return false
        }
    }

    mutating func remove(_ element: Element) -> Bool {
        if let index: Int = self.firstIndex(of: element) {
            self.remove(at: index)
            return true
        } else {
            return false
        }
    }
}

extension Array {
    mutating func move(from oldIndex: Index, to newIndex: Index) {
        // Don't work for free and use swap when indices are next to each other - this
        // won't rebuild array and will be super efficient.
        if oldIndex == newIndex { return }
        if abs(newIndex - oldIndex) == 1 {
            return self.swapAt(oldIndex, newIndex)
        }
        self.insert(self.remove(at: oldIndex), at: newIndex)
    }
}
