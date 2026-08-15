//
//  MarqueeText.swift
//  MacRadio
//
//  Created by Андерс Фриден on 15.08.2026.
//

import SwiftUI
import AppKit


struct MarqueeText: View {

    let text: String


    @State private var offset: CGFloat = 0


    var body: some View {

        GeometryReader { geometry in

            let textWidth = text.widthOfString(
                usingFont: .systemFont(ofSize: 13)
            )


            HStack {

                Text(text)
                    .font(.system(size: 13))
                    .lineLimit(1)
                    .fixedSize()

            }
            .offset(x: offset)
            .onAppear {

                startAnimation(
                    textWidth: textWidth,
                    containerWidth: geometry.size.width
                )

            }

        }
        .clipped()
    }



    private func startAnimation(
        textWidth: CGFloat,
        containerWidth: CGFloat
    ) {


        let distance = textWidth - containerWidth


        guard distance > 0 else {

            return

        }



        DispatchQueue.main.asyncAfter(
            deadline: .now() + 1.5
        ) {


            withAnimation(
                .linear(
                    duration: Double(distance) / 25
                )
            ) {

                offset = -distance

            }



            DispatchQueue.main.asyncAfter(
                deadline: .now()
                + Double(distance) / 25
                + 2
            ) {


                withAnimation(
                    .linear(duration: 0.8)
                ) {

                    offset = 0

                }



                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 1
                ) {

                    startAnimation(
                        textWidth: textWidth,
                        containerWidth: containerWidth
                    )

                }

            }

        }

    }

}



private extension String {


    func widthOfString(
        usingFont font: NSFont
    ) -> CGFloat {

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]


        return (self as NSString)
            .size(
                withAttributes: attributes
            )
            .width
    }

}
