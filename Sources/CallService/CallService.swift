//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import CallKit
import Ion

public protocol HasCallService {

    var callService: CallService { get }
}

public protocol CallService: class {

    /// The source for call with changed state.
    var callEventSource: AnyEventSource<CXCall> { get }

    /// Returns the active calls of the telephony provider.
    var calls: [CXCall] { get }

    /// Returns true if there is at least one unended call.
    var hasCallInProgress: Bool { get }
}
