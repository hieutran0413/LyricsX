//
//  PlayerManager.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Combine
import MusicPlayer
import CXShim

/// Observable wrapper around `MusicPlayers.Selected` that exposes the
/// current track, playback state, and player position to SwiftUI views.
@available(macOS 10.15, *)
final class PlayerManager: ObservableObject {

    static let shared = PlayerManager()

    // MARK: - Published state

    /// The underlying player agent
    let player: MusicPlayers.Selected

    @Published var currentTrack: MusicTrack?
    @Published var playbackState: PlaybackState = .stopped
    @Published var playerPosition: TimeInterval = 0

    // MARK: - Combine plumbing

    /// Keeps track/state/position subscriptions alive
    private var cancellables: [AnyCancellable] = []

    private init() {
        player = .shared
        currentTrack = player.currentTrack
        playbackState = player.playbackState
        playerPosition = player.playerPosition

        // Forward every track / state change into @Published.
        player.currentTrackWillChange.sink { [weak self] _ in
            self?.currentTrack = self?.player.currentTrack
        }.store(in: &cancellables)

        player.playbackStateWillChange.sink { [weak self] _ in
            self?.playbackState = self?.player.playbackState ?? .stopped
        }.store(in: &cancellables)
    }
}
