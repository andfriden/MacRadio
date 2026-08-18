//
//  AddStationView.swift
//  MacRadio
//

import SwiftUI


struct AddStationView: View {

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var streamURL = ""
    @State private var logoURL = ""

    @State private var errorMessage: String?


    private var canAddStation: Bool {

        !name.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
        &&
        URL(
            string:
                streamURL.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
        ) != nil
    }


    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 20
        ) {

            Text(
                "Add Station"
            )
            .font(
                .title2
            )
            .fontWeight(
                .semibold
            )


            Form {

                TextField(
                    "Name",
                    text: $name
                )


                TextField(
                    "Stream URL",
                    text: $streamURL
                )


                TextField(
                    "Logo URL (Optional)",
                    text: $logoURL
                )
            }


            if let errorMessage {

                Text(
                    errorMessage
                )
                .font(
                    .caption
                )
                .foregroundStyle(
                    .red
                )
            }


            HStack {

                Spacer()


                Button(
                    "Cancel"
                ) {

                    dismiss()
                }


                Button(
                    "Add"
                ) {

                    addStation()
                }
                .keyboardShortcut(
                    .defaultAction
                )
                .disabled(
                    !canAddStation
                )
            }
        }
        .padding(
            24
        )
        .frame(
            width: 420
        )
    }


    // MARK: - Actions

    private func addStation() {

        let trimmedName =
            name.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let trimmedStreamURL =
            streamURL.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let trimmedLogoURL =
            logoURL.trimmingCharacters(
                in: .whitespacesAndNewlines
            )


        guard
            !trimmedName.isEmpty,
            let streamURL = URL(
                string: trimmedStreamURL
            )
        else {

            errorMessage =
                "Please enter a valid station name and stream URL."

            return
        }


        let artworkURL =
            trimmedLogoURL.isEmpty
            ? nil
            : URL(
                string: trimmedLogoURL
            )


        do {

            try appState.stationManager.addStation(
                name: trimmedName,
                streamURL: streamURL,
                artworkURL: artworkURL
            )

            dismiss()

        } catch {

            errorMessage =
                "Unable to save the station."
        }
    }
}
