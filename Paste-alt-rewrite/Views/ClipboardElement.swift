//
//  ClipboardElement.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/17.
//

import SwiftUI

protocol StringOrImage {}
extension String: StringOrImage {}
extension Image: StringOrImage {}

struct ClipboardElement: View {
    var name: String
    var content: StringOrImage
    var image: Image?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                GeometryReader { geometry in
                    VStack {
                        GeometryReader { geometry in
                            HStack(spacing: 0) {
                                (image ?? Image("BlankAppIcon"))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.height * 0.75, height: geometry.size.height * 0.75)
                                    .clipShape(Circle())
                                    .padding(.vertical, geometry.size.height * 0.125)
                                    .padding(.leading, geometry.size.height * 0.125)
                                VStack {
                                    Text(name)
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
                                        .fill(Color.purple))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: geometry.size.width, height: geometry.size.height / 3)
                .background(Rectangle().fill(Color.blue))
                GeometryReader { geometry in
                    if let contentText = content as? String {
                        Text(contentText)
                            .foregroundColor(.black)
                            .font(.footnote)
                            .padding(.horizontal, geometry.size.width * 0.02)
                            .padding(.top, geometry.size.height * 0.02)
                            .padding(.bottom, geometry.size.width / 10)
                    } else if let contentImage = content as? Image {
                        contentImage
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
