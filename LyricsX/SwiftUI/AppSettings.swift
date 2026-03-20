//
//  AppSettings.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AppKit
import Combine

/// Centralized, observable settings model that replaces the GenericID-typed
/// `UserDefaults.DefaultsKeys` approach. Every stored property is backed by
/// `UserDefaults.standard` through manual sync in `didSet`.
///
/// Usage: inject via `@ObservedObject` in SwiftUI views, or
/// access `AppSettings.shared` from non-SwiftUI code.
@available(macOS 10.15, *)
final class AppSettings: ObservableObject {

    static let shared = AppSettings()

    private let defaults = UserDefaults.standard

    // MARK: - Menu / Toggle

    @Published var desktopLyricsEnabled: Bool {
        didSet { defaults.set(desktopLyricsEnabled, forKey: "DesktopLyricsEnabled") }
    }
    @Published var menuBarLyricsEnabled: Bool {
        didSet { defaults.set(menuBarLyricsEnabled, forKey: "MenuBarLyricsEnabled") }
    }

    // MARK: - General

    @Published var preferredPlayerIndex: Int {
        didSet { defaults.set(preferredPlayerIndex, forKey: "PreferredPlayerIndex") }
    }
    @Published var launchAndQuitWithPlayer: Bool {
        didSet { defaults.set(launchAndQuitWithPlayer, forKey: "LaunchAndQuitWithPlayer") }
    }
    @Published var lyricsSavingPathPopUpIndex: Int {
        didSet { defaults.set(lyricsSavingPathPopUpIndex, forKey: "LyricsSavingPathPopUpIndex") }
    }
    @Published var lyricsCustomSavingPathBookmark: Data? {
        didSet { defaults.set(lyricsCustomSavingPathBookmark, forKey: "LyricsCustomSavingPathBookmark") }
    }
    @Published var loadLyricsBesideTrack: Bool {
        didSet { defaults.set(loadLyricsBesideTrack, forKey: "LoadLyricsBesideTrack") }
    }
    @Published var strictSearchEnabled: Bool {
        didSet { defaults.set(strictSearchEnabled, forKey: "StrictSearchEnabled") }
    }
    @Published var preferBilingualLyrics: Bool {
        didSet { defaults.set(preferBilingualLyrics, forKey: "PreferBilingualLyrics") }
    }
    @Published var chineseConversionIndex: Int {
        didSet { defaults.set(chineseConversionIndex, forKey: "ChineseConversionIndex") }
    }

    @Published var combinedMenubarLyrics: Bool {
        didSet { defaults.set(combinedMenubarLyrics, forKey: "CombinedMenubarLyrics") }
    }
    @Published var hideLyricsWhenMousePassingBy: Bool {
        didSet { defaults.set(hideLyricsWhenMousePassingBy, forKey: "HideLyricsWhenMousePassingBy") }
    }
    @Published var disableLyricsWhenPaused: Bool {
        didSet { defaults.set(disableLyricsWhenPaused, forKey: "DisableLyricsWhenPaused") }
    }
    @Published var disableLyricsWhenScreenShot: Bool {
        didSet { defaults.set(disableLyricsWhenScreenShot, forKey: "DisableLyricsWhenSreenShot") }
    }

    // MARK: - Display (Desktop)

    @Published var desktopLyricsOneLineMode: Bool {
        didSet { defaults.set(desktopLyricsOneLineMode, forKey: "DesktopLyricsOneLineMode") }
    }
    @Published var desktopLyricsVerticalMode: Bool {
        didSet { defaults.set(desktopLyricsVerticalMode, forKey: "DesktopLyricsVerticalMode") }
    }
    @Published var desktopLyricsDraggable: Bool {
        didSet { defaults.set(desktopLyricsDraggable, forKey: "DesktopLyricsDraggable") }
    }
    @Published var desktopLyricsXPositionFactor: CGFloat {
        didSet { defaults.set(desktopLyricsXPositionFactor, forKey: "DesktopLyricsXPositionFactor") }
    }
    @Published var desktopLyricsYPositionFactor: CGFloat {
        didSet { defaults.set(desktopLyricsYPositionFactor, forKey: "DesktopLyricsYPositionFactor") }
    }
    @Published var desktopLyricsEnableFurigana: Bool {
        didSet { defaults.set(desktopLyricsEnableFurigana, forKey: "DesktopLyricsEnableFurigana") }
    }
    @Published var desktopLyricsFontName: String {
        didSet { defaults.set(desktopLyricsFontName, forKey: "DesktopLyricsFontName") }
    }
    @Published var desktopLyricsFontSize: Int {
        didSet { defaults.set(desktopLyricsFontSize, forKey: "DesktopLyricsFontSize") }
    }

    // MARK: - Display (Lyrics Window)

    @Published var lyricsWindowFontName: String {
        didSet { defaults.set(lyricsWindowFontName, forKey: "LyricsWindowFontName") }
    }
    @Published var lyricsWindowFontSize: Int {
        didSet { defaults.set(lyricsWindowFontSize, forKey: "LyricsWindowFontSize") }
    }

    // MARK: - Filter

    @Published var lyricsFilterEnabled: Bool {
        didSet { defaults.set(lyricsFilterEnabled, forKey: "LyricsFilterEnabled") }
    }
    @Published var lyricsSmartFilterEnabled: Bool {
        didSet { defaults.set(lyricsSmartFilterEnabled, forKey: "LyricsSmartFilterEnabled") }
    }
    @Published var lyricsFilterKeys: [String] {
        didSet { defaults.set(lyricsFilterKeys, forKey: "LyricsFilterKeys") }
    }

    // MARK: - Lab

    @Published var useSystemWideNowPlaying: Bool {
        didSet { defaults.set(useSystemWideNowPlaying, forKey: "UseSystemWideNowPlaying") }
    }
    @Published var writeiTunesWithTranslation: Bool {
        didSet { defaults.set(writeiTunesWithTranslation, forKey: "WriteiTunesWithTranslation") }
    }
    @Published var writeToiTunesAutomatically: Bool {
        didSet { defaults.set(writeToiTunesAutomatically, forKey: "WriteToiTunesAutomatically") }
    }
    @Published var globalLyricsOffset: Int {
        didSet { defaults.set(globalLyricsOffset, forKey: "GlobalLyricsOffset") }
    }

    // MARK: - Blacklists

    @Published var noSearchingTrackIds: [String] {
        didSet { defaults.set(noSearchingTrackIds, forKey: "NoSearchingTrackIds") }
    }
    @Published var noSearchingAlbumNames: [String] {
        didSet { defaults.set(noSearchingAlbumNames, forKey: "NoSearchingAlbumNames") }
    }

    // MARK: - Init (read from UserDefaults)

    private init() {
        desktopLyricsEnabled = defaults.bool(forKey: "DesktopLyricsEnabled")
        menuBarLyricsEnabled = defaults.bool(forKey: "MenuBarLyricsEnabled")

        preferredPlayerIndex = defaults.integer(forKey: "PreferredPlayerIndex")
        launchAndQuitWithPlayer = defaults.bool(forKey: "LaunchAndQuitWithPlayer")
        lyricsSavingPathPopUpIndex = defaults.integer(forKey: "LyricsSavingPathPopUpIndex")
        lyricsCustomSavingPathBookmark = defaults.data(forKey: "LyricsCustomSavingPathBookmark")
        loadLyricsBesideTrack = defaults.bool(forKey: "LoadLyricsBesideTrack")
        strictSearchEnabled = defaults.bool(forKey: "StrictSearchEnabled")
        preferBilingualLyrics = defaults.bool(forKey: "PreferBilingualLyrics")
        chineseConversionIndex = defaults.integer(forKey: "ChineseConversionIndex")

        combinedMenubarLyrics = defaults.bool(forKey: "CombinedMenubarLyrics")
        hideLyricsWhenMousePassingBy = defaults.bool(forKey: "HideLyricsWhenMousePassingBy")
        disableLyricsWhenPaused = defaults.bool(forKey: "DisableLyricsWhenPaused")
        disableLyricsWhenScreenShot = defaults.bool(forKey: "DisableLyricsWhenSreenShot")

        desktopLyricsOneLineMode = defaults.bool(forKey: "DesktopLyricsOneLineMode")
        desktopLyricsVerticalMode = defaults.bool(forKey: "DesktopLyricsVerticalMode")
        desktopLyricsDraggable = defaults.bool(forKey: "DesktopLyricsDraggable")
        desktopLyricsXPositionFactor = CGFloat(defaults.double(forKey: "DesktopLyricsXPositionFactor"))
        desktopLyricsYPositionFactor = CGFloat(defaults.double(forKey: "DesktopLyricsYPositionFactor"))
        desktopLyricsEnableFurigana = defaults.bool(forKey: "DesktopLyricsEnableFurigana")
        desktopLyricsFontName = defaults.string(forKey: "DesktopLyricsFontName") ?? ".AppleSystemUIFont"
        desktopLyricsFontSize = defaults.integer(forKey: "DesktopLyricsFontSize")

        lyricsWindowFontName = defaults.string(forKey: "LyricsWindowFontName") ?? ".AppleSystemUIFont"
        lyricsWindowFontSize = defaults.integer(forKey: "LyricsWindowFontSize")

        lyricsFilterEnabled = defaults.bool(forKey: "LyricsFilterEnabled")
        lyricsSmartFilterEnabled = defaults.bool(forKey: "LyricsSmartFilterEnabled")
        lyricsFilterKeys = defaults.stringArray(forKey: "LyricsFilterKeys") ?? []

        useSystemWideNowPlaying = defaults.bool(forKey: "UseSystemWideNowPlaying")
        writeiTunesWithTranslation = defaults.bool(forKey: "WriteiTunesWithTranslation")
        writeToiTunesAutomatically = defaults.bool(forKey: "WriteToiTunesAutomatically")
        globalLyricsOffset = defaults.integer(forKey: "GlobalLyricsOffset")

        noSearchingTrackIds = defaults.stringArray(forKey: "NoSearchingTrackIds") ?? []
        noSearchingAlbumNames = defaults.stringArray(forKey: "NoSearchingAlbumNames") ?? []
    }
}
