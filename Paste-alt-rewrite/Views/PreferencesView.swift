//
//  PreferencesView.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/19.
//

import KeyboardShortcuts
import LaunchAtLogin
import Preferences
import SwiftUI

struct PreferencesView: View {
    var body: some View {
        Preferences.Container(contentWidth: 450.0) {
            Preferences.Section(title: "Set snippet open shortcut:") {
                KeyboardShortcuts.Recorder(for: .openSnippetsView)
            }
            Preferences.Section(title: "Launch at login:") {
                LaunchAtLogin.Toggle()
            }
        }
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
