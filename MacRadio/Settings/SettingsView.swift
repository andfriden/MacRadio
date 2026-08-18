//
//  SettingsView.swift
//  MacRadio
//

import SwiftUI


struct SettingsView: View {

    @EnvironmentObject var appState: AppState

    @State private var showingAddStation = false


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
                   
                    Button {
                        showingAddStation = true
                    } label: {
                        Label(
                            "Add Station",
                            systemImage: "plus"
                        )
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
        .sheet(
            isPresented: $showingAddStation
        ) {

            AddStationView()
                .environmentObject(
                    appState
                )
        }
    }
}
