//
//  String+Extensions.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/20.
//

import Foundation

extension String {
    func validateUrl () -> Bool {
        let urlRegEx = "(http:\\/\\/www\\.|https:\\/\\/www\\.|http:\\/\\/|https:\\/\\/)?[a-z0-9]+([\\-\\.]{1}[a-z0-9]+)*\\.[a-z]{2,5}(:[0-9]{1,5})?(\\/.*)?"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: self)
    }

    func validColorHex () -> Bool {
        let colorRegEx = "#(?:[0-9a-fA-F]{3}){1,2}$|#(?:[0-9a-fA-F]{4}){1,2}$"
        return NSPredicate(format: "SELF MATCHES %@", colorRegEx).evaluate(with: self)
    }
}
