//
//  StationListView.swift
//  MacRadio
//

import SwiftUI


struct StationListView: View {

    @EnvironmentObject private var stationManager: StationManager


    var body: some View {

        List {

            ForEach(
                stationManager.stations
            ) { station in

                StationRowView(
                    station: station
                )
            }
        }
        .listStyle(
            .sidebar
        )
    }
}


#Preview {

    StationListView()
        .environmentObject(
            StationManager(
                settings: AppSettings()
            )
        )
}
