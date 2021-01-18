//
//  Copyright © 2020 Rosberry. All rights reserved.
//

public protocol HasAppReachabilityService {
    var appReachabilityService: AppReachabilityService { get }
}

public protocol AppReachabilityService {

    func doIfReachable(router: ErrorPopupRoute, isPopupDismissible: Bool, action: @escaping () -> Void)
}

public extension AppReachabilityService {
    func doIfReachable(router: ErrorPopupRoute, action: @escaping () -> Void) {
        doIfReachable(router: router, isPopupDismissible: true, action: action)
    }
}
