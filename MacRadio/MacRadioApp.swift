//
//  MacRadioApp.swift
//  MacRadio
//

import SwiftUI


@main
struct MacRadioApp: App {


    @NSApplicationDelegateAdaptor(AppDelegate.self)
    private var appDelegate



    var body: some Scene {


        Settings {

            EmptyView()

        }
    }
}
