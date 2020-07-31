//
//  PreferencesVIew.swift
//  Paste-alt
//
//  Created by Helloyunho on 2020/07/29.
//  Copyright © 2020 Helloyunho. All rights reserved.
//

import SwiftUI
import Preferences
import KeyboardShortcuts

struct PreferencesView: View {
    var body: some View {
        Preferences.Container(contentWidth: 450.0) {
            Preferences.Section(title: "Set open snippet key:") {
                HStack {
                    KeyboardShortcuts.Recorder(for: .openSnippetsView)
                }
            }
        }
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
