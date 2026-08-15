import SwiftUI


struct MenuBarView: View {
    
    
    @EnvironmentObject var appState: AppState
    
    
    
    var body: some View {
        
        VStack(spacing: 12) {
            
            
            Image(systemName: "dot.radiowaves.left.and.right")
                .font(.system(size: 28))
                .foregroundStyle(.primary)
            
            
            
            Text("MacRadio")
                .font(.title3)
                .fontWeight(.bold)
            
            
            
            Divider()
            
            
            
            playerStatus
            
            
            
            Divider()
            
            
            
            HStack(spacing: 20) {
                
                
                Button {
                    
                    previousStation()
                    
                } label: {
                    
                    Image(systemName: "backward.fill")
                    
                }
                
                
                
                Button {
                    
                    appState.player.toggle()
                    
                } label: {
                    
                    Image(systemName: playPauseIcon)
                    
                }
                
                
                
                Button {
                    
                    nextStation()
                    
                } label: {
                    
                    Image(systemName: "forward.fill")
                    
                }
                
            }
            .font(.title3)
            
            
            
            Divider()
            
            
            
            Text("Stations")
                .font(.headline)
            
            
            
            ForEach(appState.stationManager.stations) { station in
                
                
                Button {
                    
                    
                    appState.stationManager.select(station)
                    
                    appState.player.play(
                        station: station
                    )
                    
                    
                } label: {
                    
                    
                    HStack {
                        
                        
                        Image(systemName: "radio")
                        
                        
                        Text(station.name)
                        
                        
                        Spacer()
                        
                    }
                    
                }
                
            }
            
            
            
            Divider()
            
            
            Button {
                
                
                NSApplication.shared.terminate(nil)
                
                
            } label: {
                
                
                Label(
                    "Quit MacRadio",
                    systemImage: "xmark.circle"
                )
                
            }
            
            
        }
        .padding(12)
        .frame(width: 300)
        
    }
    
    
    
    
    @ViewBuilder
    private var playerStatus: some View {
        
        
        switch appState.player.state {
            
            
        case .playing:
            
            
            HStack(alignment: .center, spacing: 6) {
                
                Text("▶")
                    .font(.system(size: 13))
                
                MarqueeText(
                    text: stationName
                )
                .frame(height: 18)
                
            }
            .frame(width: 260)
            
            
            
        case .paused:
            
            
            MarqueeText(
                text: "⏸ \(stationName)"
            )
            .frame(width: 260)
            
            
            
        case .connecting:
            
            
            Text(
                "⏳ \(stationName)"
            )
            
            
            
        case .stopped:
            
            
            Text(
                "⏹ Стоп"
            )
            
        }
        
    }
    
    private var stationName: String {
        
        let station =
        appState.player.currentStation?.name
        ?? ""
        
        let artist =
        appState.player.currentTrack?.artist
        ?? ""
        
        let track =
        appState.player.currentTrack?.title
        ?? ""
        
        
        if !artist.isEmpty && !track.isEmpty {
            
            return "\(artist) — \(track) — \(station)"
            
        }
        
        
        if !station.isEmpty {
            
            return station
            
        }
        
        
        return "MacRadio"
    }
    
    
    
    private var playPauseIcon: String {
        
        switch appState.player.state {
            
        case .playing:
            
            return "pause.fill"
            
            
        default:
            
            return "play.fill"
            
        }
        
    }
    
    
    
    private func nextStation() {
        
        if let station = appState.stationManager.nextStation() {
            
            appState.player.play(
                station: station
            )
            
        }
        
    }
    
    
    
    private func previousStation() {
        
        if let station = appState.stationManager.previousStation() {
            
            appState.player.play(
                station: station
            )
            
        }
        
    }
}
