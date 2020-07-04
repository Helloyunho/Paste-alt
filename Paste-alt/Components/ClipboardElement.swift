//
//  ClipboardElement.swift
//  Paste-alt
//
//  Created by Helloyunho on 2020/06/21.
//  Copyright © 2020 Helloyunho. All rights reserved.
//

import SwiftUI

func geometryGetter(_ geometry: GeometryProxy) -> CGFloat {
    return geometry.frame(in: .global).size.width >= geometry.frame(in: .global).size.height
        ? geometry.frame(in: .global).size.height : geometry.frame(in: .global).size.width
}

func getImageColor(_ image: NSImage) -> NSColor {
    return image.averageColor ?? NSColor.systemIndigo
}

struct ClipboardElement: View {
    var image: NSImage
    var name: String
    var content: String
    var selected: Bool
    var body: some View {
        HStack {
            let averageColor = getImageColor(self.image)
            let lightedAverageColor = averageColor.lighter(by: 10)
            let blackOpacityApplied = Color.black.opacity(0.3)

            GeometryReader { geometry in
                let geometryGetted = geometryGetter(geometry)
                let cornerRadius = geometryGetted * 0.05
                let imageSize = geometryGetted * 0.2

                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color(averageColor))
                        .frame(
                            width: geometryGetted,
                            height: geometryGetted
                        ).shadow(
                            color: blackOpacityApplied, radius: imageSize
                        ).overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(
                                    Color(averageColor.invertColor()),
                                    lineWidth: selected ? geometryGetted * 0.016 : 0))
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: geometryGetted)
                                .fill(
                                    Color(lightedAverageColor)
                                )
                                .frame(
                                    width: geometryGetted * 0.94,
                                    height: geometryGetted * 0.236
                                )
                                .shadow(
                                    color: blackOpacityApplied,
                                    radius: geometryGetted * 0.0472
                                )
                            Image(nsImage: self.image)
                                .resizable()
                                .frame(
                                    width: imageSize,
                                    height: imageSize
                                )
                                .clipShape(Circle())
                                .offset(x: -geometryGetted * 0.336, y: 0)
                            Text(self.name)
                                .font(.custom("SF Pro Rounded", size: geometryGetted * 0.08))
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .foregroundColor(
                                    lightedAverageColor.isDarkText ? .black : .white
                                )
                                .frame(
                                    width: geometryGetted * 0.672,
                                    height: geometryGetted * 0.096
                                )
                                .offset(
                                    x: geometryGetted * 0.114)
                        }
                        ZStack {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(Color.white)
                                .frame(
                                    width: geometryGetted * 0.9,
                                    height: geometryGetted * 0.654
                                )
                            Text(self.content).font(.footnote).multilineTextAlignment(.leading)
                                .frame(
                                    width: geometryGetted * 0.86,
                                    height: geometryGetted * 0.61,
                                    alignment: .topLeading
                                ).foregroundColor(.black)
                        }
                    }
                }
            }
        }
    }
}

struct ClipboardElement_Previews: PreviewProvider {
    static var previews: some View {
        ClipboardElement(
            image: NSImage(named: "chino")!, name: "Discord",
            content: """
                Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Neque volutpat ac tincidunt vitae semper quis lectus nulla at. Metus vulputate eu scelerisque felis imperdiet proin fermentum. Viverra accumsan in nisl nisi scelerisque. Aliquet sagittis id consectetur purus ut faucibus pulvinar elementum.
                """, selected: false
        )
        .background(Color.white)
    }
}
