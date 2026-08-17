//
//  SettingsView.swift
//  MacRadio
//

import SwiftUI


struct SettingsView: View {

    @EnvironmentObject var appState: AppState


    var body: some View {

        Form {

            Section(
                "Notifications"
            ) {

                Toggle(
                    "Enable Notifications",
                    isOn:
                        $appState.settings.notificationsEnabled
                )
            }
        }
        .formStyle(
            .grouped
        )
        .padding()
        .frame(
            width: 320
        )
    }
}
