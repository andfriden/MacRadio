//
//  AppDelegate.swift
//  MacRadio
//
//  Created by Андерс Фриден on 15.08.2026.
//

import Cocoa
import SwiftUI
import Combine


final class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!

    private var popover: NSPopover!

    private let appState = AppState()
    
    private var cancellable: AnyCancellable?



    func applicationDidFinishLaunching(_ notification: Notification) {

        setupMenuBar()

        setupPopover()

        observePlayerState()

    }



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


        popover.contentViewController = NSHostingController(
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

    private func observePlayerState() {


        cancellable =
        appState.player.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in

                self?.updateMenuBarIcon()

            }

    }
     
    private var iconColor: NSColor {


        switch appState.player.state {


        case .playing:

            return .systemGreen



        case .connecting:

            return .systemBlue



        case .paused,
             .stopped:

            return .labelColor

        }

    }
    
    private func updateMenuBarIcon() {

        guard let button = statusItem.button,
              let image = NSImage(named: "MacRadioSignal")
        else {
            return
        }


        let coloredImage = NSImage(
            size: image.size
        )


        coloredImage.lockFocus()


        iconColor.setFill()
        
        

        let rect = NSRect(
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
