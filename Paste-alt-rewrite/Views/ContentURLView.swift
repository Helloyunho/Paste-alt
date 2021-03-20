//
//  ContentURLView.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/20.
//

import SwiftUI

struct ContentURLView: View {
    @ObservedObject var contentURL: URLWithMetadatas

    var body: some View {
        GeometryReader { geometry in
            VStack {
                if let image = contentURL.previewImage {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding(geometry.size.height * 0.1)
                } else {
                    Image(systemName: "network")
                        .resizable()
                        .scaledToFit()
                        .padding(geometry.size.height * 0.1)
                }
                Text(contentURL.title ?? contentURL.url)
                    .font(.system(size: geometry.size.height * 0.07))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .lineLimit(1)
                Text(contentURL.description ?? " ")
                    .font(.system(size: geometry.size.height * 0.05))
                    .foregroundColor(.black)
                    .lineLimit(1)
                Text(contentURL.title != nil ? contentURL.url : " ")
                    .font(.system(size: geometry.size.height * 0.05))
                    .foregroundColor(.black)
                    .lineLimit(1)
            }
            .padding(.bottom, geometry.size.width / 10)
            .padding(.horizontal, geometry.size.width * 0.02)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
