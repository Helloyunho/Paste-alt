//
//  ClipboardElement.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/17.
//

import SwiftUI
import UIImageColors

struct ClipboardElement: View {
    var name: String
    var content: SnippetContentType
    var image: NSImage?
    
    var body: some View {
        let image = self.image ?? NSImage(named: "BlankAppIcon")!
        let colorBasedImage = image.getColors()?.background ?? NSColor.systemIndigo
        let lightedColor = colorBasedImage.lighter(by: 10)

        GeometryReader { geometry in
            VStack(spacing: 0) {
                GeometryReader { geometry in
                    VStack {
                        GeometryReader { geometry in
                            HStack(spacing: 0) {
                                Image(nsImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.height * 0.75, height: geometry.size.height * 0.75)
                                    .clipShape(Circle())
                                    .padding(.vertical, geometry.size.height * 0.125)
                                    .padding(.leading, geometry.size.height * 0.125)
                                VStack {
                                    Text(name)
                                        .foregroundColor(lightedColor.isDarkText ? .black : .white)
                                        .font(.custom("SF Pro Rounded", size: geometry.size.height * 0.25))
                                        .fontWeight(.bold)
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.75)
                        .background(RoundedRectangle(cornerRadius: geometry.size.width / 2)
                                        .fill(Color(lightedColor)))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: geometry.size.width, height: geometry.size.height / 3)
                .background(Rectangle().fill(Color(colorBasedImage)))
                GeometryReader { geometry in
                    if let contentText = content as? String {
                        Text(contentText)
                            .foregroundColor(.black)
                            .font(.footnote)
                            .padding(.horizontal, geometry.size.width * 0.02)
                            .padding(.top, geometry.size.height * 0.02)
                            .padding(.bottom, geometry.size.width / 10)
                    } else if let contentImage = content as? NSImage {
                        Image(nsImage: contentImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height * 2 / 3)
                .background(Rectangle().fill(Color.white))
            }
            .clipShape(RoundedRectangle(cornerRadius: geometry.size.width / 10))
        }
        .aspectRatio(1.0, contentMode: .fit)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ClipboardElement_Previews: PreviewProvider {
    static var previews: some View {
        ClipboardElement(name: "DJ GAY", content: "DJ GAY")
    }
}
