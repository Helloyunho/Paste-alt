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
    @State var alertDeleteAllDatas = false
    
    var body: some View {
        Preferences.Container(contentWidth: 450.0) {
            Preferences.Section(title: "Set snippet open shortcut:") {
                KeyboardShortcuts.Recorder(for: .openSnippetsView)
            }
            Preferences.Section(title: "Launch at login:") {
                LaunchAtLogin.Toggle()
            }
            Preferences.Section(title: "") {
                Button("Delete All Datas...") {
                    self.alertDeleteAllDatas = true
                }
            }
        }
        .alert(isPresented: $alertDeleteAllDatas) {
            Alert(title: Text("Are you sure?"), message: Text("Once all data is deleted you can no longer recover your data!"), primaryButton: .destructive(Text("Yes")) {
                DispatchQueue.main.async {
                    try? dbPool.write { db in
                        try SnippetItem.deleteAll(db)
                        try SnippetContentTable.deleteAll(db)
                    }
                    NotificationCenter.default.post(.init(name: .DeleteAllCommandCalled))
                }
            }, secondaryButton: .cancel(Text("No")))
        }
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
