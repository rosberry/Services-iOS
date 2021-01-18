//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import XCTest
import Services
import Ion

final class AppReachabilityServiceTest: XCTestCase {

    private final class MockedReachabilityService: ReachabilityService {
        var isReachable: Bool = true {
            didSet {
                reachabilityStatusEmitter.emit(isReachable)
            }
        }

        private var reachabilityStatusEmitter: Emitter<Bool> = .init(valueStackDepth: 0)
        private(set) lazy var reachabilityStatusEventSource: AnyEventSource<Bool> = .init(reachabilityStatusEmitter)

        func start() {
        }

        func cancel() {
        }

    }

    private class Dependencies: HasReachabilityService {

        let reachabilityService: ReachabilityService

        init(reachabilityService: ReachabilityService) {
            self.reachabilityService = reachabilityService
        }
    }

    private class MockErrorPopupRoute: ErrorPopupRoute {

        let showEventHandler: (Error, ErrorPopupSettings) -> Void
        let hideEventHandler: () -> Void
        private var settings: ErrorPopupSettings?

        init(showEventHandler: @escaping (Error, ErrorPopupSettings) -> Void,
             hideEventHandler: @escaping () -> Void) {
            self.showEventHandler = showEventHandler
            self.hideEventHandler = hideEventHandler
        }

        func show(_ error: Error, settings: ErrorPopupSettings) {
            self.settings = settings
            showEventHandler(error, settings)
        }

        func hide(completionHandler: (() -> Void)?) {
            self.settings?.closeHandler?()
            completionHandler?()
            hideEventHandler()
        }
    }

    func testWhenReachable() {
        let (reachabilityService, service) = services()
        reachabilityService.isReachable = true
        var isActionTriggered = false
        var isShowEventTriggered = false
        var isHideEventTriggered = false
        let router = MockErrorPopupRoute(showEventHandler: { error, settings in
            isShowEventTriggered = true
        }, hideEventHandler: {
            isHideEventTriggered = true
        })
        service.doIfReachable(router: router, isPopupDismissible: false) {
            isActionTriggered = true
        }
        XCTAssertTrue(isActionTriggered)
        XCTAssertFalse(isShowEventTriggered)
        XCTAssertFalse(isHideEventTriggered)
    }

    func testWhenNotReachableAndThenBecomeReachable() {
        let (reachabilityService, service) = services()
        reachabilityService.isReachable = false
        var isActionTriggered = false
        var isShowEventTriggered = false
        var isHideEventTriggered = false
        let router = MockErrorPopupRoute(showEventHandler: { error, settings in
            isShowEventTriggered = true
        }, hideEventHandler: {
            isHideEventTriggered = true
        })
        service.doIfReachable(router: router, isPopupDismissible: false) {
            isActionTriggered = true
        }
        XCTAssertFalse(isActionTriggered)
        XCTAssertTrue(isShowEventTriggered)
        XCTAssertFalse(isHideEventTriggered)
        
        reachabilityService.isReachable = true
        XCTAssertTrue(isActionTriggered)
        XCTAssertTrue(isShowEventTriggered)
        XCTAssertTrue(isHideEventTriggered)
    }

    func testWhenNotReachableAndThenHideAndThenReachable() {
        let (reachabilityService, service) = services()
        reachabilityService.isReachable = false
        var isActionTriggered = false
        var isShowEventTriggered = false
        var isHideEventTriggered = false
        let router = MockErrorPopupRoute(showEventHandler: { error, settings in
            isShowEventTriggered = true
        }, hideEventHandler: {
            isHideEventTriggered = true
        })
        service.doIfReachable(router: router, isPopupDismissible: false) {
            isActionTriggered = true
        }
        XCTAssertFalse(isActionTriggered)
        XCTAssertTrue(isShowEventTriggered)
        XCTAssertFalse(isHideEventTriggered)

        router.hide(completionHandler: nil)
        XCTAssertFalse(isActionTriggered)
        XCTAssertTrue(isHideEventTriggered)
        XCTAssertTrue(isShowEventTriggered)

        reachabilityService.isReachable = true
        XCTAssertFalse(isActionTriggered)
        XCTAssertTrue(isShowEventTriggered)
        XCTAssertTrue(isHideEventTriggered)
    }

    private func services() -> (MockedReachabilityService, AppReachabilityService) {
        let reachabilityService: MockedReachabilityService = .init()
        let service = AppReachabilityServiceImp(dependencies: Dependencies(reachabilityService: reachabilityService))
        return (reachabilityService, service)
    }
}
