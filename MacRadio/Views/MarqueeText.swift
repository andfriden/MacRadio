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



    var body: some View {


        GeometryReader { geometry in


            Text(text)
                .font(.system(size: 13))
                .lineLimit(1)
                .fixedSize()
                .offset(x: offset)
                .background(

                    GeometryReader { textGeometry in


                        Color.clear
                            .onAppear {


                                updateSize(
                                    textSize:
                                        textGeometry.size.width,
                                    container:
                                        geometry.size.width
                                )


                            }


                            .onChange(
                                of: textGeometry.size.width
                            ) {


                                updateSize(
                                    textSize:
                                        textGeometry.size.width,
                                    container:
                                        geometry.size.width
                                )


                            }


                    }

                )


        }
        .clipped()
        .onChange(
            of: text
        ) {


            offset = 0

            animationID = UUID()


            DispatchQueue.main.async {


                startAnimation(
                    id: animationID
                )


            }

        }
        .onDisappear {


            animationID = UUID()

        }


    }







    private func updateSize(
        textSize: CGFloat,
        container: CGFloat
    ) {


        textWidth = textSize

        containerWidth = container


        startAnimation(
            id: animationID
        )

    }








    private func startAnimation(
        id: UUID
    ) {


        let distance =
        textWidth - containerWidth



        guard distance > 0 else {

            offset = 0

            return

        }



        offset = 0



        DispatchQueue.main.asyncAfter(
            deadline: .now() + 2
        ) {


            guard id == animationID else {

                return

            }



            withAnimation(
                .linear(
                    duration:
                        Double(distance) / 18
                )
            ) {


                offset = -distance

            }



            DispatchQueue.main.asyncAfter(
                deadline:
                    .now()
                    +
                    Double(distance) / 18
                    +
                    2
            ) {


                guard id == animationID else {

                    return

                }



                withAnimation(
                    .linear(
                        duration:
                            Double(distance) / 18
                    )
                ) {


                    offset = 0

                }



                DispatchQueue.main.asyncAfter(
                    deadline:
                        .now()
                        +
                        Double(distance) / 18
                        +
                        2
                ) {


                    guard id == animationID else {

                        return

                    }


                    startAnimation(
                        id: id
                    )

                }


            }

        }

    }


}
