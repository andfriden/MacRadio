//
//  MenuBarIcon.swift
//  MacRadio
//
//  Created by Андерс Фриден on 16.08.2026.
//

import SwiftUI


struct MenuBarIcon: View {

    let state: PlayerState


    var body: some View {

        Image(
            systemName: "dot.radiowaves.left.and.right"
        )
        .symbolRenderingMode(.hierarchical)
        .foregroundStyle(
            color
        )
    }


    private var color: Color {

        switch state {

        case .playing:

            return .green


        case .connecting,
             .buffering,
             .reconnecting:

            return .blue


        case .failed:

            return .red


        case .paused,
             .stopped:

            return .gray
        }
    }
}
