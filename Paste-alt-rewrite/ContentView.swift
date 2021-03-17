//
//  ContentView.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/14.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ClipboardElement(name: "DJ GAY", content: "DJ GAY")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
