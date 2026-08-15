//
//  MarqueeText.swift
//  MacRadio
//
//  Created by Андерс Фриден on 15.08.2026.
//

import SwiftUI


struct MarqueeText: View {

    let text: String


    @State private var offset: CGFloat = 0


    var body: some View {

        GeometryReader { geometry in

            Text(text)
                .lineLimit(1)
                .fixedSize()
                .offset(x: offset)
                .onAppear {

                    let textWidth = textWidth()

                    let availableWidth = geometry.size.width


                    if textWidth > availableWidth {

                        offset = availableWidth


                        withAnimation(
                            .linear(
                                duration: Double(textWidth / 25)
                            )
                            .repeatForever(
                                autoreverses: false
                            )
                        ) {

                            offset = -textWidth

                        }
                    }
                }
        }
        .clipped()
    }



    private func textWidth() -> CGFloat {

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 13)
        ]


        return (
            text as NSString
        )
        .size(
            withAttributes: attributes
        )
        .width
    }
}
