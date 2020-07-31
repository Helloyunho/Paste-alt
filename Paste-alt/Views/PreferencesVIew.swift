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
    @ObservedObject private var launchAtLogin = DetectLaunchAtLoginChange()
    var body: some View {
        Preferences.Container(contentWidth: 450.0) {
            Preferences.Section(title: "Set open snippet key:") {
                KeyboardShortcuts.Recorder(for: .openSnippetsView)
            }
            Preferences.Section(title: "Launch at login:") {
                Toggle("Launch at login button", isOn: $launchAtLogin.launchAtLoginBool)
                    .labelsHidden()
            }
        }
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
