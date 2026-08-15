//
//  AppDelegate.swift
//  MacRadio
//
//  Created by Андерс Фриден on 15.08.2026.
//

import Cocoa
import SwiftUI


final class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!

    private var popover: NSPopover!

    private let appState = AppState()



    func applicationDidFinishLaunching(_ notification: Notification) {

        setupMenuBar()

        setupPopover()

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


        NSColor.systemGreen.setFill()


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
