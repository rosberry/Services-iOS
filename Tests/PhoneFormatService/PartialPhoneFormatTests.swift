//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import XCTest
import Services

final class PartialPhoneFormatTests: XCTestCase {
    let service: PhoneFormatService = PhoneFormatServiceImp()

    // 07739555555
    func testUKMobileNumber() {
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "0", regionCode: "GB"), "0")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "07", regionCode: "GB"), "07")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "077", regionCode: "GB"), "077")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "0773", regionCode: "GB"), "0773")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "07739", regionCode: "GB"), "07739")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "077395", regionCode: "GB"), "07739 5")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "0773955", regionCode: "GB"), "07739 55")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "07739555", regionCode: "GB"), "07739 555")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "077395555", regionCode: "GB"), "07739 5555")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "0773955555", regionCode: "GB"), "07739 55555")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "07739555555", regionCode: "GB"), "07739 555555")
    }

    // 07739555555,9
    func testUKMobileNumberWithDigitsPausesAndWaits() {
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "07739555555,", regionCode: "GB"), "07739 555555,")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "07739555555,9", regionCode: "GB"), "07739 555555,9")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "07739555555,9,", regionCode: "GB"),
                       "07739555555,9,") // not quite the expected, should keep formatting and just add pauses and waits during typing.
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "07739555555,9,1", regionCode: "GB"), "07739 555555,9,1")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "07739555555,9,1;", regionCode: "GB"),
                       "07739555555,9,1;") // not quite the expected, should keep formatting and just add pauses and waits during typing.
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "07739555555,9,1;2", regionCode: "GB"), "07739 555555,9,1;2")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "07739555555,9,1;2;", regionCode: "GB"),
                       "07739555555,9,1;2;") // not quite the expected, should keep formatting and just add pauses and waits during typing.
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "07739555555,9,1;2;5", regionCode: "GB"), "07739 555555,9,1;2;5")
    }

    // 8002530000
    func testUSTollFreeNumber() {
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "8", regionCode: "US"), "8")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "80", regionCode: "US"), "80")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "800", regionCode: "US"), "800")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "8002", regionCode: "US"), "800-2")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "80025", regionCode: "US"), "800-25")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "800253", regionCode: "US"), "800-253")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "8002530", regionCode: "US"), "800-2530")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "80025300", regionCode: "US"), "(800) 253-00")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "800253000", regionCode: "US"), "(800) 253-000")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "8002530000", regionCode: "US"), "(800) 253-0000")
    }

    // *144
    func testBrazilianOperatorService() {
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "*", regionCode: "BR"), "*")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "*1", regionCode: "BR"), "*1")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "*14", regionCode: "BR"), "*14")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "*144", regionCode: "BR"), "*144")
    }

    // *#06#
    func testImeiCodeRetrieval() {
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "*", regionCode: "BR"), "*")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "*#", regionCode: "BR"), "*#")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "*#0", regionCode: "BR"), "*#0")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "*#06", regionCode: "BR"), "*#06")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "*#06#", regionCode: "BR"), "*#06#")
    }

    // *#*6#
    func testAsteriskShouldNotBeRejectedInTheMiddle() {
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "*", regionCode: "BR"), "*")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "*#", regionCode: "BR"), "*#")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "*#*", regionCode: "BR"), "*#*")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "*#*6", regionCode: "BR"), "*#*6")
        XCTAssertEqual(service.partialFormatOf(phoneNumber: "*#*6#", regionCode: "BR"), "*#*6#")
    }
}
