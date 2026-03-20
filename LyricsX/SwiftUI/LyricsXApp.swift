//
//  LyricsXApp.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

/// SwiftUI App scene definition – prepared for future use once the project
/// raises its deployment target to macOS 13+ and removes the old
/// storyboard-based AppDelegate entry point.
///
/// **Current status**: This file compiles but is NOT the app entry point.
/// The existing `@NSApplicationMain AppDelegate` remains authoritative.
/// Once all migration phases are complete:
///   1. Remove `@NSApplicationMain` from AppDelegate.swift.
///   2. Delete the "Main storyboard file base name" entry from Info.plist.
///   3. Uncomment `@main` below.
///
@available(macOS 13.0, *)
// @main  // Uncomment when ready to switch to SwiftUI lifecycle
struct LyricsXApp: App {

    // AppDelegate adapter — keeps existing menu, shortcut and lifecycle
    // logic alive during the migration. Remove once all phases are done.
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    // Observable singletons injected into the environment.
    @StateObject private var settings = AppSettings.shared
    @StateObject private var playerManager = PlayerManager.shared
    @StateObject private var lyricsManager = LyricsManager.shared

    var body: some Scene {
        // Phase 2 will add MenuBarExtra here.
        // Phase 3 will add the Lyrics HUD Window here.
        // Phase 6 will add the Settings scene here.

        // Placeholder window (hidden) — macOS requires at least one scene.
        // This will be replaced by real windows in later phases.
        Window("LyricsX", id: "main") {
            Text("LyricsX is running in the menu bar.")
                .frame(width: 280, height: 80)
                .environmentObject(settings)
                .environmentObject(playerManager)
                .environmentObject(lyricsManager)
        }
        .defaultSize(width: 280, height: 80)
    }
}
