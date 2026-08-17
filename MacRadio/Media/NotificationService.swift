//
//  NotificationService.swift
//  MacRadio
//

import Foundation
import Combine
import UserNotifications


final class NotificationService {

    private let player: RadioPlayer

    private let settings: AppSettings

    private let center =
        UNUserNotificationCenter.current()


    private var cancellables = Set<AnyCancellable>()

    private var lastTrackID: String?


    init(
        player: RadioPlayer,
        settings: AppSettings
    ) {

        self.player = player

        self.settings = settings
    }


    // MARK: - Start


    func start() {

        observeTrack()

        observeSettings()

        updateAuthorization()
    }


    // MARK: - Authorization


    private func updateAuthorization() {

        guard settings.notificationsEnabled else {

            return
        }


        center.getNotificationSettings {
            [weak self] notificationSettings in

            guard let self else {

                return
            }


            switch notificationSettings.authorizationStatus {

            case .notDetermined:

                self.requestAuthorization()


            case .authorized,
                 .provisional:

                break


            case .denied:

                print(
                    "NOTIFICATIONS: permission denied"
                )


            @unknown default:

                break
            }
        }
    }


    private func requestAuthorization() {

        center.requestAuthorization(
            options: [
                .alert,
                .sound
            ]
        ) { granted, error in

            if let error {

                print(
                    "NOTIFICATIONS AUTH ERROR:",
                    error.localizedDescription
                )

                return
            }


            print(
                "NOTIFICATIONS AUTHORIZED:",
                granted
            )
        }
    }


    // MARK: - Track Observation


    private func observeTrack() {

        player.$currentTrack
            .receive(
                on: DispatchQueue.main
            )
            .sink { [weak self] track in

                self?.handleTrackChange(
                    track
                )
            }
            .store(
                in: &cancellables
            )
    }


    private func observeSettings() {

        settings.$notificationsEnabled
            .receive(
                on: DispatchQueue.main
            )
            .sink { [weak self] enabled in

                guard let self else {

                    return
                }


                if enabled {

                    self.updateAuthorization()

                } else {

                    self.lastTrackID = nil
                }
            }
            .store(
                in: &cancellables
            )
    }


    // MARK: - Track Change


    private func handleTrackChange(
        _ track: Track?
    ) {

        guard settings.notificationsEnabled else {

            return
        }


        guard let track else {

            lastTrackID = nil

            return
        }


        let trackID =
            "\(track.artist)|\(track.title)"


        guard trackID != lastTrackID else {

            return
        }


        lastTrackID = trackID


        guard player.state == .playing ||
              player.state == .paused
        else {

            return
        }


        sendTrackNotification(
            track
        )
    }


    // MARK: - Notification


    private func sendTrackNotification(
        _ track: Track
    ) {

        guard settings.notificationsEnabled else {

            return
        }


        center.getNotificationSettings {
            [weak self] notificationSettings in

            guard let self else {

                return
            }


            guard
                notificationSettings.authorizationStatus ==
                    .authorized ||
                notificationSettings.authorizationStatus ==
                    .provisional
            else {

                return
            }


            let content =
                UNMutableNotificationContent()


            content.title =
                track.artist


            content.body =
                "\(track.title) • \(self.stationName)"


            content.sound =
                .default


            let request =
                UNNotificationRequest(
                    identifier:
                        UUID().uuidString,
                    content:
                        content,
                    trigger:
                        nil
                )


            self.center.add(
                request
            ) { error in

                if let error {

                    print(
                        "NOTIFICATION ERROR:",
                        error.localizedDescription
                    )
                }
            }
        }
    }


    // MARK: - Station


    private var stationName: String {

        player.currentStation?.name
            ?? "MacRadio"
    }
}
