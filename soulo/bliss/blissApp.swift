//
//  blissApp.swift
//  bliss
//
//  Created by Nagulan Vijayakumar on 21/06/26.
//
import SwiftUI
import FirebaseCore

@main
struct BlissApp: App {

    init() {
        FirebaseApp.configure()
    }

    @StateObject private var healthManager = HealthKitManager()
    @StateObject private var userManager = UserManager()
    @StateObject private var blissManager = BlissContentManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthManager)
                .environmentObject(userManager)
                .environmentObject(blissManager)
                .preferredColorScheme(.dark)
        }
    }
}
