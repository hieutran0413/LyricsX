//
//  LyricsManager.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Combine
import LyricsCore
import LyricsService
import MusicPlayer
import CXShim

/// Observable model that owns the lyrics lifecycle: searching for lyrics when
/// the track changes, storing the current lyrics, and managing the per-track
/// offset. Extracted from the old `AppController`.
@available(macOS 10.15, *)
final class LyricsManager: ObservableObject {

    static let shared = LyricsManager()

    // MARK: - Public state

    /// Currently loaded lyrics (may have been auto-fetched or manually chosen).
    @Published var currentLyrics: Lyrics? {
        didSet {
            currentLineIndex = nil
            highlightedRange = nil
            if let lyrics = currentLyrics {
                lyrics.filtrate()
                lyrics.recognizeLanguage()
            }
        }
    }

    /// The index of the current lyrics line, updated by the playback timer.
    @Published var currentLineIndex: Int?

    /// The sub-range inside the current line for karaoke-style highlighting.
    @Published var highlightedRange: ClosedRange<Int>?

    /// Per-track offset in milliseconds, adjustable by the user.
    @Published var lyricsOffset: Int = 0

    // MARK: - Search state

    /// Active lyrics-search cancellable (set while a search is in progress).
    var searchCanceller: AnyCancellable?

    // MARK: - Private

    private let player = PlayerManager.shared
    private let settings = AppSettings.shared
    private var cancellables: [AnyCancellable] = []
    private var positionTimer: Timer?

    // MARK: - Init

    private init() {
        // React to track changes.
        player.player.currentTrackWillChange
            .sink { [weak self] _ in
                DispatchQueue.main.async { self?.handleTrackChange() }
            }
            .store(in: &cancellables)

        // React to playback state changes to start / stop position timer.
        player.player.playbackStateWillChange
            .sink { [weak self] state in
                DispatchQueue.main.async {
                    if state.isPlaying {
                        self?.startPositionTimer()
                    } else {
                        self?.stopPositionTimer()
                    }
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Lyrics lifecycle

    func handleTrackChange() {
        stopPositionTimer()
        searchCanceller?.cancel()
        currentLyrics = nil
        lyricsOffset = 0

        guard let track = player.currentTrack else { return }

        // Check blacklists.
        if settings.noSearchingTrackIds.contains(track.id) {
            return
        }
        if let album = track.album, settings.noSearchingAlbumNames.contains(album) {
            return
        }

        // Try loading from local file first, then fall back to online search.
        if let lyrics = loadLocalLyrics(for: track) {
            currentLyrics = lyrics
        } else {
            searchLyrics(for: track)
        }

        if player.playbackState.isPlaying {
            startPositionTimer()
        }
    }

    // MARK: - Position tracking

    private func startPositionTimer() {
        stopPositionTimer()
        positionTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateLineIndex()
        }
    }

    private func stopPositionTimer() {
        positionTimer?.invalidate()
        positionTimer = nil
    }

    private func updateLineIndex() {
        guard let lyrics = currentLyrics else {
            currentLineIndex = nil
            return
        }
        let position = player.playerPosition + Double(lyricsOffset + settings.globalLyricsOffset) / 1000.0
        let idx = lyrics.lineIndex(at: position)
        if idx != currentLineIndex {
            currentLineIndex = idx
        }
    }

    // MARK: - Local loading

    private func loadLocalLyrics(for track: MusicTrack) -> Lyrics? {
        // Load from lyrics saving path.
        let (url, security) = lyricsSavingPath()
        if security {
            guard url.startAccessingSecurityScopedResource() else { return nil }
        }
        defer {
            if security { url.stopAccessingSecurityScopedResource() }
        }

        let title = track.title?.replacingOccurrences(of: "/", with: ":")
        let artist = track.artist?.replacingOccurrences(of: "/", with: ":")
        guard let title, let artist else { return nil }

        let fileName = "\(title) - \(artist).lrcx"
        let fileURL = url.appendingPathComponent(fileName)

        if let data = try? String(contentsOf: fileURL, encoding: .utf8) {
            var lyrics = Lyrics(data)
            lyrics?.metadata.localURL = fileURL
            lyrics?.metadata.title = title
            lyrics?.metadata.artist = artist
            return lyrics
        }
        return nil
    }

    // MARK: - Online search

    private func searchLyrics(for track: MusicTrack) {
        let req = LyricsSearchRequest(
            searchTerm: .info(title: track.title ?? "", artist: track.artist ?? ""),
            title: track.title ?? "",
            artist: track.artist ?? "",
            duration: track.duration ?? 0
        )
        let provider = LyricsProviders.Group()
        searchCanceller = provider.lyricsPublisher(request: req)
            .collect(8.0)
            .sink { [weak self] lyrics in
                DispatchQueue.main.async {
                    guard let self else { return }
                    let best = lyrics
                        .sorted { $0.quality > $1.quality }
                        .first
                    if let best {
                        best.metadata.title = track.title
                        best.metadata.artist = track.artist
                        best.metadata.needsPersist = true
                        self.currentLyrics = best
                        best.persist()
                    }
                }
            }
    }

    // MARK: - Helpers

    private func lyricsSavingPath() -> (URL, security: Bool) {
        if settings.lyricsSavingPathPopUpIndex != 0,
           let bookmark = settings.lyricsCustomSavingPathBookmark {
            var isStale = false
            if let url = try? URL(resolvingBookmarkData: bookmark, options: [.withSecurityScope], bookmarkDataIsStale: &isStale) {
                return (url, true)
            }
        }
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("LyricsX")
        return (directory, false)
    }

    /// Write current lyrics to Apple Music / iTunes.
    func writeToiTunes(overwrite: Bool) {
        guard let lyrics = currentLyrics,
              let track = player.currentTrack else { return }
        let content = lyrics.lines.map(\.content).joined(separator: "\n")
        if overwrite || track.lyrics == nil || track.lyrics?.isEmpty == true {
            track.setLyrics(content)
        }
    }
}
