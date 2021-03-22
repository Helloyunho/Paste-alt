//
//  ClipboardElement.swift
//  Paste-alt-rewrite
//
//  Created by Helloyunho on 2021/03/17.
//

import SwiftUI
import UIImageColors
import PDFKit

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
                                        .font(.custom("SF Pro Rounded", size: geometry.size.height * 0.3))
                                        .fontWeight(.bold)
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.75)
                        .background(Color(lightedColor).opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: geometry.size.width / 2))
                        .shadow(color: Color.black.opacity(0.2), radius: geometry.size.height * 0.1)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: geometry.size.width, height: geometry.size.height / 3)
                .background(Color(colorBasedImage).opacity(0.8))
                GeometryReader { geometry in
                    if let contentText = content as? String {
                        Text(contentText)
                            .font(.system(size: geometry.size.height * 0.07))
                            .foregroundColor(.black)
                            .padding(.horizontal, geometry.size.width * 0.02)
                            .padding(.top, geometry.size.height * 0.02)
                    } else if let contentImage = content as? NSImage {
                        Image(nsImage: contentImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    } else if let contentText = content as? NSAttributedString {
                        AttributedText(attributedText: contentText)
                            .padding(.horizontal, geometry.size.width * 0.02)
                            .padding(.top, geometry.size.height * 0.02)
                    } else if let contentColor = content as? NSColor {
                        Text(contentColor.hexString(contentColor.alphaComponent != 1))
                            .foregroundColor(Color(contentColor.isDarkText ? contentColor.darker(by: 20) : contentColor.lighter(by: 20)))
                            .font(.custom("SF Pro Rounded", size: geometry.size.height * 0.2))
                            .fontWeight(.bold)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .background(Color(contentColor))
                    } else if let contentURL = content as? URLWithMetadatas {
                        ContentURLView(contentURL: contentURL)
                    } else if let fileURL = content as? FileURLStruct {
                        FileURLView(fileURL: fileURL)
                    } else if let pdf = content as? PDFDocument {
                        PDFRepresentedView(pdfDocument: pdf)
                            .padding(.horizontal, geometry.size.width * 0.02)
                            .padding(.top, geometry.size.height * 0.02)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height * 2 / 3)
                .background(VisualEffectView(blendingMode: .withinWindow, appearance: NSAppearance(named: .aqua)))
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

// #18F72DF2
