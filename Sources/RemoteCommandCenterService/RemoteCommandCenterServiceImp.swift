//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import MediaPlayer

public protocol RemoteCommandCenterServiceDelegate: class {

    func didPlay()
    func didPause()
    func didSkipBackward()
    func didSkipForward()
}

public final class RemoteCommandCenterServiceImp: RemoteCommandCenterService {

    private lazy var commandCenter: MPRemoteCommandCenter = .shared()

    private var isCommandCenterConfigured: Bool = false

    public weak var delegate: RemoteCommandCenterServiceDelegate?

    private lazy var commands: [MPRemoteCommand] = [commandCenter.playCommand,
                                                    commandCenter.pauseCommand,
                                                    commandCenter.skipBackwardCommand,
                                                    commandCenter.skipForwardCommand]

    // MARK: - Lifecycle

    public init() {
    }

    public func setupControlCenterIfNeeded(skipTimeInterval: CFTimeInterval) {
        guard isCommandCenterConfigured == false else {
            return
        }
        setupControlCenter(skipTimeInterval: skipTimeInterval)
        isCommandCenterConfigured = true
    }

    public func update(isEnabled: Bool) {
        commands.forEach { command in
            command.isEnabled = isEnabled
        }
    }

    public func reset() {
        commands.forEach { command in
            command.removeTarget(nil)
        }
        isCommandCenterConfigured = false
    }

    // MARK: - Private

    private func setupControlCenter(skipTimeInterval: CFTimeInterval) {
        commandCenter.playCommand.addTarget { [weak delegate] _ in
            delegate?.didPlay()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak delegate] _ in
            delegate?.didPause()
            return .success
        }

        commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(value: skipTimeInterval)]
        commandCenter.skipBackwardCommand.addTarget { [weak delegate] _ in
            delegate?.didSkipBackward()
            return .success
        }

        commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(value: skipTimeInterval)]
        commandCenter.skipForwardCommand.addTarget { [weak delegate] _ in
            delegate?.didSkipForward()
            return .success
        }
    }
}
