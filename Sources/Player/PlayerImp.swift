//
//  Copyright © 2019 Second Phone LLC. All rights reserved.
//

import AVKit
import Foundation
import Ion
import MediaPlayer

public final class PlayerImpl: NSObject, Player {

    public typealias Dependencies = HasRemoteCommandCenterService & HasReachabilityService & HasNowPlayingInfoCenterService

    let dependencies: Dependencies

    private let trackPlayer: AVPlayer = {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }()

    private var trackItemObservers: [NSKeyValueObservation] = []
    private var trackPlayerObservers: [Any] = []

    public var track: Track?

    public var isTrackPlaying: Bool = false
    public var isTrackPaused: Bool = false
    public var isTrackFinishedPlaying: Bool = true
    public var isTrackSeeking: Bool = false
    public var isTrackInitiallyStarted: Bool = false
    public var isPlayingLocalTrack: Bool = false

    public var skipTimeInterval: CFTimeInterval = 15

    private var state: PlayerStatus = .preparing
    private var isFailedToPlayToEnd: Bool = false
    private var isPlaybackStalled: Bool = false
    private var isTrackFailedToStart: Bool = false
    private var lastStalledLoadedDuration: CFTimeInterval = 0
    private let stallThreshold: CFTimeInterval = 2

    private var chaseTime: CMTime = .zero

    private var lastTimeValue: CMTime?

    private var playerRate: Float = 1.0 {
        didSet {
            guard state == .playing else {
                return
            }
                trackPlayer.rate = playerRate
        }
    }

    private lazy var reachabilityStatusCollector = Collector(source: dependencies.reachabilityService.reachabilityStatusEventSource)

    // MARK: - Events Binding

    private let statusEmitter: Emitter<PlayerStatus> = .init()
    public lazy var playerStatusSource: AnyEventSource<PlayerStatus> = .init(statusEmitter)
    private let timeEmitter: Emitter<CFTimeInterval> = .init()
    public lazy var timeEventSource: AnyEventSource<CFTimeInterval> = .init(timeEmitter)
    private let playbackFinishedEmitter: Emitter<Player> = .init(valueStackDepth: 0)
    public lazy var playbackFinishedEventSource: AnyEventSource<Player> = .init(playbackFinishedEmitter)
    private let playbackInterruptionEmitter: Emitter<Player> = .init(valueStackDepth: 0)
    public lazy var playbackInterruptionEventSource: AnyEventSource<Player> = .init(playbackInterruptionEmitter)

    private let trackListenedToEmitter: Emitter<TrackListenedToEvent> = .init(valueStackDepth: 0)
    public lazy var trackListenedToEventSource: AnyEventSource<TrackListenedToEvent> = .init(trackListenedToEmitter)

    public var stopTime: CFTimeInterval?

    // MARK: - Lifecycle

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies

        super.init()

        setupInterruptionObserver()
        setupReachabilityObserver()
        dependencies.remoteCommandCenterService.update(isEnabled: false)
    }

    deinit {
        unsubscribePlayerObservers()
        NotificationCenter.default.removeObserver(self)
    }

    public func setup() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, mode: .default, options: [.allowAirPlay,
                                                                          .defaultToSpeaker,
                                                                          .allowBluetoothA2DP])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }

    public func play(_ track: Track) {
        stopTime = nil
        timeEmitter.emit(0)
        statusEmitter.emit(.playing)

        self.track = track

        isFailedToPlayToEnd = false
        dependencies.remoteCommandCenterService.setupControlCenterIfNeeded(skipTimeInterval: skipTimeInterval)
        dependencies.remoteCommandCenterService.update(isEnabled: false)
        dependencies.nowPlayingInfoCenterService.update(title: track.title, duration: track.duration)

        isPlaybackStalled = true
        playFile(at: track.url)
        state = .playing
    }

    public func stop() {
        trackPlayer.replaceCurrentItem(with: nil)
        track = nil
        trackPlayer.rate = 1.0
        pause()
        isTrackPaused = false
        stopTime = lastTimeValue?.seconds
        lastTimeValue = nil
        state = .playing
        dependencies.nowPlayingInfoCenterService.removeInfo()
        dependencies.remoteCommandCenterService.update(isEnabled: false)
        dependencies.remoteCommandCenterService.reset()
    }

    public func pause() {
        state = .paused
        isTrackPlaying = false
        isTrackPaused = true
        trackPlayer.currentItem?.cancelPendingSeeks()
        trackPlayer.pause()
        statusEmitter.emit(.paused)
        dependencies.nowPlayingInfoCenterService.update(isPlaying: false, seconds: trackPlayer.currentTime().seconds)
    }

    public func resume() {
        if isFailedToPlayToEnd,
            let currentTime = trackPlayer.currentItem?.currentTime() {
            seek(toTime: currentTime.seconds)
            return
        }

        stopTime = nil
        state = .playing
        isPlaybackStalled = false
        isTrackPlaying = true
        isTrackFinishedPlaying = false
        isTrackPaused = false
        statusEmitter.emit(.playing)
        trackPlayer.rate = playerRate

        dependencies.nowPlayingInfoCenterService.update(isPlaying: true, seconds: trackPlayer.currentTime().seconds)
        dependencies.remoteCommandCenterService.update(isEnabled: true)
    }

    public func updatePlayerRate(_ rate: Float) {
        playerRate = rate
    }

    public func skipForward() {
        guard let duration = track?.duration,
            duration > skipTimeInterval else {
            return
        }

        seek(toTime: trackPlayer.currentTime().seconds + skipTimeInterval)
    }

    public func skipBackward() {
        seek(toTime: trackPlayer.currentTime().seconds - skipTimeInterval)
    }

    public func prepareForSeek() {
        guard !isTrackPaused else {
            return
        }
        trackPlayer.currentItem?.cancelPendingSeeks()
        trackPlayer.pause()
    }

    public func seek(toTime time: CFTimeInterval, completion: (() -> Void)? = nil) {
        if !isTrackInitiallyStarted {
            return
        }

        stopPlayingAndSeek(to: CMTime(seconds: time, preferredTimescale: .init(NSEC_PER_SEC)), completion: completion)
    }

    // MARK: - Private

    private func stopPlayingAndSeek(to time: CMTime, completion: (() -> Void)? = nil) {
        if isTrackPlaying {
            trackPlayer.pause()
        }

        dependencies.nowPlayingInfoCenterService.update(isPlaying: false, seconds: time.seconds)

        chaseTime = time

        if !isTrackSeeking {
            trySeekToChaseTime(completion)
        }
    }

    private func trySeekToChaseTime(_ completion: (() -> Void)? = nil) {
        guard trackPlayer.currentItem?.status == .readyToPlay else {
            return
        }
        actuallySeekToTime(completion)
    }

    private func actuallySeekToTime(_ completion: (() -> Void)? = nil) {
        isTrackSeeking = true
        let seekTimeInProgress = chaseTime
        trackPlayer.seek(to: seekTimeInProgress,
                          toleranceBefore: .zero,
                          toleranceAfter: .zero,
                          completionHandler: { [weak self] _ in

            guard let self = self else {
                return
            }
            if CMTimeCompare(seekTimeInProgress, self.chaseTime) == 0 {
                self.isTrackSeeking = false
                self.timeEmitter.emit(seekTimeInProgress.seconds)
                self.handleSeek()
                completion?()
            }
            else {
                self.trySeekToChaseTime()
            }
        })
    }

    private func playFile(at url: URL) {
        isTrackFinishedPlaying = false
        isTrackInitiallyStarted = false
        unsubscribePlayerObservers()
        trackPlayer.replaceCurrentItem(with: nil)

        let item = AVPlayerItem(url: url)
        setupObservers(for: item)
        item.preferredForwardBufferDuration = skipTimeInterval

        trackPlayer.replaceCurrentItem(with: item)
        trackPlayer.rate = playerRate
    }

    private func handleSeek() {
        isTrackSeeking = false
        if isFailedToPlayToEnd {
            isFailedToPlayToEnd = false
            resume()
        }
        if isTrackFinishedPlaying {
            resume()
        }

        if isPlaybackStalled {
            updateLastStalledDuration()
        }
        else {
            resumeIfNeeded()
        }

        if isTrackPlaying {
            statusEmitter.emit(.playing)
        }

        dependencies.nowPlayingInfoCenterService.update(playbackTime: trackPlayer.currentTime().seconds)
    }

    // MARK: Observation

    private func setupReachabilityObserver() {
        reachabilityStatusCollector.subscribe { [weak self] isReachable in
            self?.handleReachabilityStatusUpdate(isReachable: isReachable)
        }
    }

    private func handleReachabilityStatusUpdate(isReachable: Bool) {
        guard let track = track, isTrackFailedToStart else {
            return
        }
        playFile(at: track.url)
        isTrackFailedToStart = false
    }

    private func handleTimeRangesUpdate(for item: AVPlayerItem) {
        guard let timeRange = item.loadedTimeRanges.first?.timeRangeValue else {
            return
        }

        let loadedDuration = timeRange.start.seconds + timeRange.duration.seconds

        if isTrackInitiallyStarted {
            if isPlaybackStalled,
                loadedDuration - lastStalledLoadedDuration >= stallThreshold {
                isPlaybackStalled = false
                resumeIfNeeded()
            }
        }
        else if loadedDuration >= stallThreshold {
            initiallyStartPlayingIfNeeded()
        }
    }

    private func handleStatusUpdate(for item: AVPlayerItem) {
        if isPlayingLocalTrack,
           item.status == .readyToPlay {
            initiallyStartPlayingIfNeeded()
        }
        else if item.status == .failed,
                !isTrackInitiallyStarted {
            isTrackFailedToStart = true
        }
    }

    @discardableResult
    private func resumeIfNeeded() -> Bool {
        let shouldResume = state == .playing
        if shouldResume {
            resume()
        }
        return shouldResume
    }

    private func initiallyStartPlayingIfNeeded() {
        if resumeIfNeeded() {
            isTrackInitiallyStarted = true
        }
    }

    private func setupObservers(for item: AVPlayerItem) {
        unsubscribePlayerObservers()

        let statusObserver = item.observe(\.status, options: [.old, .new]) { [weak self] (item: AVPlayerItem, _) in
            self?.handleStatusUpdate(for: item)
        }
        trackItemObservers.append(statusObserver)

        if !isPlayingLocalTrack {
            let bufferObserver = item.observe(\.loadedTimeRanges, options: [.old, .new]) { [weak self] (item: AVPlayerItem, _) in
                self?.handleTimeRangesUpdate(for: item)
            }
            trackItemObservers.append(bufferObserver)
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: item)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFailToPlayToEndTime),
                                               name: .AVPlayerItemFailedToPlayToEndTime,
                                               object: item)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playbackStalled),
                                               name: .AVPlayerItemPlaybackStalled,
                                               object: item)

        let interval = CMTime(seconds: 0.1, preferredTimescale: .init(NSEC_PER_SEC))
        let timeObserver = trackPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.handleTimeChange(time)
        }
        trackPlayerObservers.append(timeObserver)
    }

    private func handleTimeChange(_ time: CMTime) {
        guard trackPlayer.currentItem != nil else {
            return
        }

        timeEmitter.emit(time.seconds)

        lastTimeValue = time
    }

    private func unsubscribePlayerObservers() {
        for observer in trackItemObservers {
            observer.invalidate()
        }
        trackItemObservers.removeAll()
        trackPlayerObservers.forEach { observer in
            trackPlayer.removeTimeObserver(observer)
        }
        trackPlayerObservers.removeAll()

        NotificationCenter.default.removeObserver(self,
                                                  name: .AVPlayerItemDidPlayToEndTime,
                                                  object: trackPlayer.currentItem)
        NotificationCenter.default.removeObserver(self,
                                                  name: .AVPlayerItemFailedToPlayToEndTime,
                                                  object: trackPlayer.currentItem)
        NotificationCenter.default.removeObserver(self,
                                                  name: .AVPlayerItemPlaybackStalled,
                                                  object: trackPlayer.currentItem)
    }

    @objc private func playerDidFinishPlaying() {
        isTrackFinishedPlaying = true
        isTrackInitiallyStarted = false
        isTrackPlaying = false
        dependencies.nowPlayingInfoCenterService.update(isPlaying: false, seconds: trackPlayer.currentTime().seconds)
        statusEmitter.emit(.paused)
        playbackFinishedEmitter.emit(self)
        state = .paused
        timeEmitter.emit(0)
    }

    @objc private func playerDidFailToPlayToEndTime() {
        isFailedToPlayToEnd = true
        pause()
    }

    @objc private func playbackStalled() {
        isPlaybackStalled = true
        updateLastStalledDuration()
        dependencies.nowPlayingInfoCenterService.resetPlaybackRateInfo()
    }

    private func updateLastStalledDuration() {
        if let loadedDuration = trackPlayer.currentItem?.loadedTimeRanges.first?.timeRangeValue.duration.seconds {
            lastStalledLoadedDuration = loadedDuration
        }
    }

    // MARK: - Interruption

    private func setupInterruptionObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: nil)
    }

    @objc func handleInterruption(notification: Foundation.Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        switch type {
            case .began:
                var shouldPausePlayback = true
                if let wasSuspended = userInfo[AVAudioSessionInterruptionWasSuspendedKey] as? Bool {
                    shouldPausePlayback = !wasSuspended
                }
                if shouldPausePlayback {
                    pause()
                    playbackInterruptionEmitter.emit(self)
            }
            case .ended:
                if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                    let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                    if options.contains(.shouldResume) {
                        resume()
                        playbackInterruptionEmitter.emit(self)
                    }
            }
            @unknown default:
                break
        }
    }
}
