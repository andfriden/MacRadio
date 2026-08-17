//
//  AppDelegate.swift
//  MacRadio
//

import Cocoa
import SwiftUI
import Combine


final class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!

    private var popover: NSPopover!

    private let appState = AppState()

    private var cancellable: AnyCancellable?

    private var workspaceObservers: [NSObjectProtocol] = []

    private var distributedObservers: [NSObjectProtocol] = []

    private var shouldResumeAfterSystemPause = false

    private var systemPauseInProgress = false


    func applicationDidFinishLaunching(
        _ notification: Notification
    ) {

        setupMenuBar()

        setupPopover()

        observePlayerState()

        observeSystemEvents()
    }


    func applicationWillTerminate(
        _ notification: Notification
    ) {

        removeSystemObservers()
    }


    // MARK: - Menu Bar


    private func setupMenuBar() {

        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )


        if let button = statusItem.button {

            button.action = #selector(togglePopover)

            button.target = self
        }


        updateMenuBarIcon()
    }


    private func setupPopover() {

        popover = NSPopover()

        popover.behavior = .transient


        popover.contentSize = NSSize(
            width: 320,
            height: 420
        )


        popover.contentViewController =
            NSHostingController(
                rootView:
                    MenuBarView()
                        .environmentObject(appState)
            )
    }


    @objc
    private func togglePopover() {

        guard let button = statusItem.button
        else {
            return
        }


        if popover.isShown {

            popover.performClose(nil)

        } else {

            popover.show(
                relativeTo: button.bounds,
                of: button,
                preferredEdge: .minY
            )
        }
    }


    // MARK: - Player State


    private func observePlayerState() {

        cancellable =
            appState.player.$state
                .receive(on: DispatchQueue.main)
                .sink { [weak self] state in

                    guard let self else {
                        return
                    }


                    if state == .paused &&
                       !systemPauseInProgress {

                        shouldResumeAfterSystemPause = false
                    }


                    updateMenuBarIcon()
                }
    }


    // MARK: - System Events


    private func observeSystemEvents() {

        let workspaceCenter =
            NSWorkspace.shared.notificationCenter


        let willSleepObserver =
            workspaceCenter.addObserver(
                forName: NSWorkspace.willSleepNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in

                self?.handleSystemPause()
            }


        let didWakeObserver =
            workspaceCenter.addObserver(
                forName: NSWorkspace.didWakeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in

                self?.handleSystemResume()
            }


        workspaceObservers = [
            willSleepObserver,
            didWakeObserver
        ]


        let distributedCenter =
            DistributedNotificationCenter.default()


        let screenLockedObserver =
            distributedCenter.addObserver(
                forName:
                    Notification.Name(
                        "com.apple.screenIsLocked"
                    ),
                object: nil,
                queue: .main
            ) { [weak self] _ in

                self?.handleSystemPause()
            }


        let screenUnlockedObserver =
            distributedCenter.addObserver(
                forName:
                    Notification.Name(
                        "com.apple.screenIsUnlocked"
                    ),
                object: nil,
                queue: .main
            ) { [weak self] _ in

                self?.handleSystemResume()
            }


        distributedObservers = [
            screenLockedObserver,
            screenUnlockedObserver
        ]
    }


    private func removeSystemObservers() {

        let workspaceCenter =
            NSWorkspace.shared.notificationCenter


        for observer in workspaceObservers {

            workspaceCenter.removeObserver(
                observer
            )
        }


        workspaceObservers.removeAll()


        let distributedCenter =
            DistributedNotificationCenter.default()


        for observer in distributedObservers {

            distributedCenter.removeObserver(
                observer
            )
        }


        distributedObservers.removeAll()
    }


    private func handleSystemPause() {

        guard appState.player.state == .playing
        else {
            return
        }


        shouldResumeAfterSystemPause = true

        systemPauseInProgress = true

        appState.player.pause()

        systemPauseInProgress = false
    }


    private func handleSystemResume() {

        guard shouldResumeAfterSystemPause
        else {
            return
        }


        shouldResumeAfterSystemPause = false


        guard appState.player.state == .paused
        else {
            return
        }


        appState.player.resume()
    }


    // MARK: - Menu Bar Icon


    private var iconColor: NSColor {

        switch appState.player.state {

        case .playing:

            return .systemGreen


        case .connecting,
             .buffering,
             .reconnecting:

            return .systemBlue


        case .failed:

            return .systemRed


        case .paused,
             .stopped:

            return .white
        }
    }


    private func updateMenuBarIcon() {

        guard let button = statusItem.button,
              let image =
                NSImage(
                    named: "MacRadioSignal"
                )
        else {
            return
        }


        let coloredImage =
            NSImage(
                size: image.size
            )


        coloredImage.lockFocus()


        iconColor.setFill()


        let rect =
            NSRect(
                origin: .zero,
                size: image.size
            )


        rect.fill(
            using: .sourceOver
        )


        image.draw(
            in: rect,
            from: .zero,
            operation: .destinationIn,
            fraction: 1.0
        )


        coloredImage.unlockFocus()


        button.image = coloredImage

        button.imagePosition = .imageOnly
    }
}
