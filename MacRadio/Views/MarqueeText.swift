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
    @State private var textWidth: CGFloat = 0
    
    
    
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
                                
                                textWidth = textGeometry.size.width
                                
                                animate(
                                    containerWidth: geometry.size.width
                                )
                                
                            }
                            .onChange(
                                of: textGeometry.size.width
                            ) {
                                
                                textWidth = textGeometry.size.width
                                
                                animate(
                                    containerWidth: geometry.size.width
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
            
        }
        
    }
    
    
    
    private func animate(
        containerWidth: CGFloat
    ) {
        
        let distance = textWidth - containerWidth
        
        
        guard distance > 0 else {
            
            return
            
        }
        
        
        offset = 0
        
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 2
        ) {
            
            
            withAnimation(
                .linear(
                    duration: Double(distance) / 18
                )
            ) {
                
                offset = -distance
                
            }
            
            
            
            DispatchQueue.main.asyncAfter(
                deadline: .now()
                + Double(distance) / 18
                + 2
            ) {
                
                
                withAnimation(
                    .linear(
                        duration: Double(distance) / 18
                    )
                ) {
                    
                    offset = 0
                    
                }
                
                
                
                DispatchQueue.main.asyncAfter(
                    deadline: .now()
                    + Double(distance) / 18
                    + 2
                ) {
                    
                    
                    animate(
                        containerWidth: containerWidth
                    )
                    
                }
                
            }
            
        }
        
    }
}
