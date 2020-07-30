//
//  PreferencesVIew.swift
//  Paste-alt
//
//  Created by Helloyunho on 2020/07/29.
//  Copyright © 2020 Helloyunho. All rights reserved.
//

import SwiftUI
import Preferences

struct PreferencesVIew: View {
    var body: some View {
        Preferences.Container(contentWidth: 450.0) {
            Preferences.Section(title: "General") {
                HStack {
                    Text("Test")
                }
            }
        }
    }
}

struct PreferencesVIew_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesVIew()
    }
}
