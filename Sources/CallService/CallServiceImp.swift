//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import CallKit
import Ion

public final class CallServiceImp: NSObject, CallService, ServiceInitializable {
    public typealias Dependencies = Any

    public lazy var callEventSource = AnyEventSource(callEmitter)

    public var calls: [CXCall] {
        return callObserver.calls
    }

    public var hasCallInProgress: Bool {
        return calls.contains { call in
            call.hasEnded == false
        }
    }

    private lazy var callEmitter: Emitter<CXCall> = {
        let emitter = Emitter<CXCall>()
        emitter.valueStackDepth = 0
        return emitter
    }()

    private lazy var callObserver: CXCallObserver = .init()

    // MARK: - Lifecycle

    override public init() {
        super.init()
        setupObserver()
    }

    public init(dependencies: Any) {
        super.init()
        setupObserver()
    }

    private func setupObserver() {
        callObserver.setDelegate(self, queue: nil)
    }
}

// MARK: - CXCallObserverDelegate

extension CallServiceImp: CXCallObserverDelegate {

    public func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        callEmitter.emit(call)
    }
}
