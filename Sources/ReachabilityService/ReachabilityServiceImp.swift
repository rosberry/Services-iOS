//
// Copyright (c) 2020 Rosberry. All rights reserved.
//

import Ion
import Network

public class ReachabilityServiceImp: ReachabilityService, ServiceInitializable {
    public typealias Dependencies = Any

    private lazy var monitor: NWPathMonitor = {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak emitter] path in
            emitter?.emit(path.status == .satisfied)
        }
        return monitor
    }()

    private let emitter: Emitter<Bool> = Emitter(valueStackDepth: 0)

    private(set) lazy public var reachabilityStatusEventSource: AnyEventSource<Bool> = .init(emitter)

    public var isReachable: Bool {
        monitor.currentPath.status == .satisfied
    }

    required public init(dependencies: Any = []) {}

    // MARK: - Monitoring

    public func start() {
        monitor.start(queue: .main)
    }

    public func cancel() {
        monitor.cancel()
    }
}
