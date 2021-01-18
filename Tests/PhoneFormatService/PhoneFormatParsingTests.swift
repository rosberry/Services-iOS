//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import XCTest
import Services

final class PhoneFormatParsingTests: XCTestCase {
    let service: PhoneFormatService = PhoneFormatServiceImp()

    func testFailingNumber() {
        XCTAssertFalse(service.validate(phoneNumber: "+5491187654321 ABC123", withRegionCode: "AR"))
    }

    func testUSNumberNoPrefix() {
        XCTAssertTrue(service.validate(phoneNumber: "650 253 0000", withRegionCode: "US"))
        XCTAssertEqual(service.internationalFormatOf(phoneNumber: "650 253 0000",
                                                     withoutRegionCode: "US"),
                       "650-253-0000")
        XCTAssertEqual(service.nationalFormatOf(phoneNumber: "650 253 0000", withoutRegionCode: "US"),
                       "(650) 253-0000")
        XCTAssertEqual(service.e164FormatOf(phoneNumber: "650 253 0000", withoutRegionCode: "US"),
                       "6502530000")

        XCTAssertTrue(service.validate(phoneNumber: "800 253 0000", withRegionCode: "US"))
        XCTAssertEqual(service.internationalFormatOf(phoneNumber: "800 253 0000",
                                                     withoutRegionCode: "US"),
                       "800-253-0000")
        XCTAssertEqual(service.nationalFormatOf(phoneNumber: "800 253 0000", withoutRegionCode: "US"),
                       "(800) 253-0000")
        XCTAssertEqual(service.e164FormatOf(phoneNumber: "800 253 0000", withoutRegionCode: "US"),
                       "8002530000")
    }

    func testUSNumber() {
        XCTAssertEqual(service.internationalFormatOf(phoneNumber: "650 253 0000",
                                                     withRegionCode: "US"),
                       "+1 650-253-0000")
        XCTAssertEqual(service.nationalFormatOf(phoneNumber: "650 253 0000", withRegionCode: "US"),
                       "(650) 253-0000")
        XCTAssertEqual(service.e164FormatOf(phoneNumber: "650 253 0000", withRegionCode: "US"),
                       "+16502530000")

        XCTAssertEqual(service.internationalFormatOf(phoneNumber: "800 253 0000",
                                                     withRegionCode: "US"),
                       "+1 800-253-0000")
        XCTAssertEqual(service.nationalFormatOf(phoneNumber: "800 253 0000", withoutRegionCode: "US"),
                       "(800) 253-0000")
        XCTAssertEqual(service.e164FormatOf(phoneNumber: "800 253 0000", withRegionCode: "US"),
                       "+18002530000")
    }

    func testBSNumber() {
        XCTAssertEqual(service.internationalFormatOf(phoneNumber: "242 365 1234",
                                                     withRegionCode: "BS"),
                       "+1 242-365-1234")
        XCTAssertEqual(service.nationalFormatOf(phoneNumber: "242 365 1234", withoutRegionCode: "US"),
                       "(242) 365-1234")
        XCTAssertEqual(service.e164FormatOf(phoneNumber: "242 365 1234", withRegionCode: "US"),
                       "+12423651234")
    }
}
