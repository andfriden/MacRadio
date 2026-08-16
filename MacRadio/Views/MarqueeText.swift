//
//  MarqueeText.swift
//  MacRadio
//

import SwiftUI


struct MarqueeText: View {


    let text: String


    @State private var offset: CGFloat = 0

    @State private var textWidth: CGFloat = 0

    @State private var containerWidth: CGFloat = 0

    @State private var animationID = UUID()
    
    private var needsScrolling: Bool {

        textWidth > containerWidth

    }



    var body: some View {


        GeometryReader { geometry in


            Text(text)
                .font(.system(size: 13))
                .lineLimit(1)
                .fixedSize()
                .frame(
                    width: containerWidth,
                    alignment: needsScrolling ? .leading : .center
                )
                .offset(
                    x: needsScrolling ? offset : 0
                )
                .background {


                    GeometryReader { textGeometry in


                        Color.clear
                            .onAppear {

                                updateSizes(
                                    textWidth: textGeometry.size.width,
                                    containerWidth: geometry.size.width
                                )

                            }
                            .onChange(
                                of: textGeometry.size.width
                            ) { _, newWidth in

                                updateSizes(
                                    textWidth: newWidth,
                                    containerWidth: geometry.size.width
                                )

                            }

                    }

                }

        }
        .clipped()
        .onChange(
            of: text
        ) {

            resetAnimation()

        }

    }



    private func updateSizes(
        textWidth: CGFloat,
        containerWidth: CGFloat
    ) {


        self.textWidth = textWidth

        self.containerWidth = containerWidth


        startAnimation()

    }



    private func resetAnimation() {


        animationID = UUID()

        offset = 0


        DispatchQueue.main.async {

            startAnimation()

        }

    }



    private func startAnimation() {


        let distance =
        textWidth - containerWidth



        guard distance > 0 else {

            return

        }



        let currentID = animationID



        DispatchQueue.main.asyncAfter(
            deadline: .now() + 2
        ) {


            guard currentID == animationID else {

                return

            }



            withAnimation(
                .linear(
                    duration: Double(distance) / 25
                )
            ) {

                offset = -distance

            }



            DispatchQueue.main.asyncAfter(
                deadline:
                    .now()
                    + Double(distance) / 25
                    + 2
            ) {


                guard currentID == animationID else {

                    return

                }



                withAnimation(
                    .linear(
                        duration: Double(distance) / 25
                    )
                ) {

                    offset = 0

                }



                DispatchQueue.main.asyncAfter(
                    deadline:
                        .now()
                        + Double(distance) / 25
                        + 2
                ) {


                    guard currentID == animationID else {

                        return

                    }


                    startAnimation()

                }

            }

        }

    }

}
