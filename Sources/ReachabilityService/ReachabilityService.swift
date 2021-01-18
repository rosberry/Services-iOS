//
// Copyright (c) 2020 Rosberry. All rights reserved.
//

import Ion

public protocol HasReachabilityService {
    var reachabilityService: ReachabilityService { get }
}

public protocol ReachabilityService {

    /// The current reachability status.
    var isReachable: Bool { get }

    /// The source for reachability statuses. Sends statuses every time the connection status changes.
    var reachabilityStatusEventSource: AnyEventSource<Bool> { get }

    /// Starts monitoring reachability changes.
    func start()

    /// Stops monitoring reachability updates.
    func cancel()
}
