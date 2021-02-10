//
//  Copyright © 2019 Second Phone LLC. All rights reserved.
//

import Foundation
import Ion

public protocol HasPlayer {
    var player: Player { get }
}

public typealias TrackListenedToEvent = (id: UInt64, isListenedTo: Bool)

public enum PlayerStatus {
    case preparing
    case playing
    case paused
}

public protocol Player: class {

    var skipTimeInterval: CFTimeInterval { get set }

    var isTrackFinishedPlaying: Bool { get }
    var isTrackPlaying: Bool { get }
    var isTrackSeeking: Bool { get }
    var isTrackPaused: Bool { get }

    var track: Track? { get }
    var stopTime: CFTimeInterval? { get }

    var playerStatusSource: AnyEventSource<PlayerStatus> { get }
    var timeEventSource: AnyEventSource<CFTimeInterval> { get }
    var playbackFinishedEventSource: AnyEventSource<Player> { get }
    var playbackInterruptionEventSource: AnyEventSource<Player> { get }
    var trackListenedToEventSource: AnyEventSource<TrackListenedToEvent> { get }

    func setup() throws

    func play(_ track: Track)
    func resume()
    func pause()
    func stop()
    func changeRate(withRate rate: Float)

    func skipForward()
    func skipBackward()
    func prepareForSeek()
    func seek(toTime time: CFTimeInterval, completion: (() -> Void)?)
}
