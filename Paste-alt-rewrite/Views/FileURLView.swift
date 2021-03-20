//
//  FileURLView.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/20.
//

import SwiftUI

struct FileURLView: View {
    var fileURL: FileURLStruct

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Image(nsImage: fileURL.icon)
                    .resizable()
                    .scaledToFit()
                    .padding(geometry.size.height * 0.1)
                Text(fileURL.url)
                    .font(.system(size: geometry.size.height * 0.07))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .lineLimit(3)
            }
            .padding(.bottom, geometry.size.width / 10)
            .padding(.horizontal, geometry.size.width * 0.02)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
