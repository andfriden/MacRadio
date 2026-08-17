//
//  MediaCommandService.swift
//  MacRadio
//

import Foundation
import AppKit
import Combine
import MediaPlayer


final class MediaCommandService {

    private let player: RadioPlayer

    private let artworkService: ArtworkService

    private let nextStation: () -> Void

    private let previousStation: () -> Void


    private let commandCenter =
        MPRemoteCommandCenter.shared()


    private let nowPlayingInfoCenter =
        MPNowPlayingInfoCenter.default()


    private var cancellables = Set<AnyCancellable>()


    init(
        player: RadioPlayer,
        artworkService: ArtworkService,
        nextStation: @escaping () -> Void,
        previousStation: @escaping () -> Void
    ) {

        self.player = player

        self.artworkService = artworkService

        self.nextStation = nextStation

        self.previousStation = previousStation
    }


    // MARK: - Start


    func start() {

        configureCommands()

        observePlayer()

        observeArtwork()

        updateNowPlayingInfo()
    }


    // MARK: - Commands


    private func configureCommands() {

        configurePlayCommand()

        configurePauseCommand()

        configureToggleCommand()

        configurePreviousCommand()

        configureNextCommand()
    }


    private func configurePlayCommand() {

        commandCenter.playCommand.isEnabled = true


        commandCenter.playCommand.addTarget {
            [weak self] _ in

            guard let self else {

                return .commandFailed
            }


            switch self.player.state {

            case .paused,
                 .failed:

                self.player.toggle()

                return .success


            case .stopped:

                self.player.toggle()

                return .success


            default:

                return .commandFailed
            }
        }
    }


    private func configurePauseCommand() {

        commandCenter.pauseCommand.isEnabled = true


        commandCenter.pauseCommand.addTarget {
            [weak self] _ in

            guard let self else {

                return .commandFailed
            }


            guard self.player.state == .playing else {

                return .commandFailed
            }


            self.player.pause()

            return .success
        }
    }


    private func configureToggleCommand() {

        commandCenter
            .togglePlayPauseCommand
            .isEnabled = true


        commandCenter
            .togglePlayPauseCommand
            .addTarget {
                [weak self] _ in

                guard let self else {

                    return .commandFailed
                }


                self.player.toggle()

                return .success
            }
    }


    private func configurePreviousCommand() {

        commandCenter
            .previousTrackCommand
            .isEnabled = true


        commandCenter
            .previousTrackCommand
            .addTarget {
                [weak self] _ in

                guard let self else {

                    return .commandFailed
                }


                self.previousStation()

                return .success
            }
    }


    private func configureNextCommand() {

        commandCenter
            .nextTrackCommand
            .isEnabled = true


        commandCenter
            .nextTrackCommand
            .addTarget {
                [weak self] _ in

                guard let self else {

                    return .commandFailed
                }


                self.nextStation()

                return .success
            }
    }


    // MARK: - Player Observation


    private func observePlayer() {

        player.$state
            .receive(
                on: DispatchQueue.main
            )
            .sink { [weak self] _ in

                self?.updateNowPlayingInfo()
            }
            .store(
                in: &cancellables
            )


        player.$currentStation
            .receive(
                on: DispatchQueue.main
            )
            .sink { [weak self] _ in

                self?.updateNowPlayingInfo()
            }
            .store(
                in: &cancellables
            )


        player.$currentTrack
            .receive(
                on: DispatchQueue.main
            )
            .sink { [weak self] _ in

                self?.updateNowPlayingInfo()
            }
            .store(
                in: &cancellables
            )
    }


    private func observeArtwork() {

        artworkService.$image
            .receive(
                on: DispatchQueue.main
            )
            .sink { [weak self] _ in

                self?.updateNowPlayingInfo()
            }
            .store(
                in: &cancellables
            )
    }


    // MARK: - Now Playing


    private func updateNowPlayingInfo() {

        let state =
            player.state


        switch state {

        case .stopped:

            nowPlayingInfoCenter.nowPlayingInfo = nil

            nowPlayingInfoCenter.playbackState =
                .stopped


        case .playing,
             .buffering,
             .reconnecting:

            nowPlayingInfoCenter.nowPlayingInfo =
                makeNowPlayingInfo()

            nowPlayingInfoCenter.playbackState =
                .playing


        case .paused:

            nowPlayingInfoCenter.nowPlayingInfo =
                makeNowPlayingInfo()

            nowPlayingInfoCenter.playbackState =
                .paused


        case .connecting:

            nowPlayingInfoCenter.nowPlayingInfo =
                makeNowPlayingInfo()

            nowPlayingInfoCenter.playbackState =
                .paused


        case .failed:

            nowPlayingInfoCenter.nowPlayingInfo =
                makeNowPlayingInfo()

            nowPlayingInfoCenter.playbackState =
                .paused
        }
    }


    private func makeNowPlayingInfo()
        -> [String: Any]
    {

        var info: [String: Any] = [:]


        if let station =
            player.currentStation
        {

            info[
                MPMediaItemPropertyAlbumTitle
            ] =
                station.name
        }


        if !player.currentArtist.isEmpty {

            info[
                MPMediaItemPropertyArtist
            ] =
                player.currentArtist
        }


        if !player.currentTitle.isEmpty {

            info[
                MPMediaItemPropertyTitle
            ] =
                player.currentTitle
        }


        info[
            MPNowPlayingInfoPropertyIsLiveStream
        ] = true


        if let image =
            artworkService.image
        {

            info[
                MPMediaItemPropertyArtwork
            ] =
                MPMediaItemArtwork(
                    boundsSize: image.size
                ) { _ in

                    image
                }
        }


        return info
    }
}
