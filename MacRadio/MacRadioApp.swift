import SwiftUI


@main
struct MacRadioApp: App {

    @StateObject private var appState = AppState()


    var body: some Scene {

        MenuBarExtra(
            "MacRadio",
            systemImage: "radio"
        ) {

            MenuBarView()
                .environmentObject(appState)

        }

    }
}
