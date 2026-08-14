//
//  MacRadioApp.swift
//  MacRadio
//
//  Created by Андерс Фриден on 14.08.2026.
//

import SwiftUI


@main
struct MacRadioApp: App {

    @StateObject private var player = RadioPlayer()


    var body: some Scene {

        MenuBarExtra(
            "MacRadio",
            systemImage: "dot.radiowaves.left.and.right"
        ) {

            MenuBarView()
                .environmentObject(player)

        }
        .menuBarExtraStyle(.window)

    }
}
