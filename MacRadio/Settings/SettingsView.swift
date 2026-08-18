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


            Section(
                "Stations"
            ) {

                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {

                    Text(
                        "Your stations are stored in a local stations.json file."
                    )
                    .font(
                        .caption
                    )
                    .foregroundStyle(
                        .secondary
                    )


                    Button(
                        "Open Stations File"
                    ) {

                        appState.stationManager
                            .openStationsFile()
                    }


                    Button(
                        "Reload Stations"
                    ) {

                        appState.stationManager
                            .reload()
                    }


                    Button(
                        "Reset to Default Stations"
                    ) {

                        appState.stationManager
                            .resetToDefaults()
                    }
                }
                .padding(
                    .vertical,
                    4
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
