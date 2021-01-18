//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Ion

public final class AppReachabilityServiceImp: AppReachabilityService {

    private enum InfoPopupAppearanceState<Value> {
        case presented(Value)
        case dismissed
    }

    private struct DefaultErrorPopupSettings: ErrorPopupSettings {
        let isDismissible: Bool
        let actionHandler: (() -> Void)?
        let closeHandler: (() -> Void)?
    }

    public enum AppError: Error {
        case noInternetConnection
    }

    public typealias Dependencies = HasReachabilityService

    private let dependencies: Dependencies
    private lazy var reachabilityCollector: Collector = .init(source: dependencies.reachabilityService.reachabilityStatusEventSource)
    private var noInternetPopupState: InfoPopupAppearanceState<() -> Void> = .dismissed
    private var isStarted: Bool = false

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    public func doIfReachable(router: ErrorPopupRoute, isPopupDismissible: Bool, action: @escaping () -> Void) {
        startIfNeeded(router: router)
        guard dependencies.reachabilityService.isReachable else {
            noInternetPopupState = .presented(action)
            let settings = DefaultErrorPopupSettings(isDismissible: isPopupDismissible, actionHandler: nil) { [weak self] in
                self?.noInternetPopupState = .dismissed
            }
            router.show(AppError.noInternetConnection, settings: settings)
            return
        }
        action()
    }

    private func startIfNeeded(router: ErrorPopupRoute) {
        guard !isStarted else {
            return
        }
        isStarted = true
        reachabilityCollector.subscribe(ObjectMatcher(object: true)) { [weak self, weak router] _ in
            switch self?.noInternetPopupState {
            case let .presented(action):
                router?.hide(completionHandler: action)
                self?.noInternetPopupState = .dismissed
            default:
                return
            }
        }
    }
}
