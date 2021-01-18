//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import XCTest
import Base
import Services

protocol HasIntValue: class {
    var value: Int { get }
}

final class TestService: ServiceInitializable {
    typealias Dependencies = HasIntValue

    let dependencies: Dependencies
    required init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func fetchValue() -> Int {
        return dependencies.value
    }
}

final class TestServiceFactory: ServiceFactory, HasIntValue {
    let value: Int = 548

    lazy var uniqueTestService: TestService = provide(TestService.self, scope: .unique)
    lazy var sharedTestService: TestService = provide(TestService.self, scope: .shared)
    lazy var namedTestService: TestService = provide(TestService.self, scope: .named("hello"))
    lazy var anotherNamedTestService: TestService = provide(TestService.self, scope: .named("bye"))
    lazy var singletonTestService: TestService = provide(TestService.self, scope: .singleton)
}

final class ServiceFactoryTests: XCTestCase {

    func testDependencyInjection() {
        let factory = TestServiceFactory()
        let service = factory.uniqueTestService
        XCTAssert(service.fetchValue() == factory.value)
    }

    func testUniqueInstance() {
        XCTAssert(TestServiceFactory().uniqueTestService !== TestServiceFactory().uniqueTestService)
    }

    func testSharedInstance() {
        var strongRef: TestService? = TestServiceFactory().sharedTestService
        let weakRef = WeakRef(object: TestServiceFactory().sharedTestService)
        XCTAssert(strongRef === weakRef.object)

        strongRef = nil
        XCTAssert(weakRef.object == nil)
    }

    func testSingletonInstance() {
        XCTAssert(TestServiceFactory().singletonTestService === TestServiceFactory().singletonTestService)
    }

    func testNamedInstance() {
        XCTAssert(TestServiceFactory().namedTestService === TestServiceFactory().namedTestService)
        XCTAssert(TestServiceFactory().namedTestService !== TestServiceFactory().sharedTestService)

        XCTAssert(TestServiceFactory().anotherNamedTestService === TestServiceFactory().anotherNamedTestService)
        XCTAssert(TestServiceFactory().anotherNamedTestService !== TestServiceFactory().namedTestService)
        XCTAssert(TestServiceFactory().anotherNamedTestService !== TestServiceFactory().sharedTestService)
    }
}
