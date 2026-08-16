//
//  MacRadioApp.swift
//  MacRadio
//

import SwiftUI


@main
struct MacRadioApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self)
    private var appDelegate


    @StateObject private var stationManager: StationManager


    init() {

        let settings = AppSettings()

        _stationManager = StateObject(
            wrappedValue: StationManager(
                settings: settings
            )
        )
    }


    var body: some Scene {

        WindowGroup {

            StationListView()

        }
        .environmentObject(
            stationManager
        )


        Settings {

            EmptyView()

        }
    }
}
