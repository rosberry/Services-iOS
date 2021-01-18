//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import XCTest
import Services

final class PhoneFormatHelpersTests: XCTestCase {
    let service: PhoneFormatService = PhoneFormatServiceImp()

    func testDefaultCountry() {
        let defaultRegionCode = service.defaultRegionCode
        let countries = service.allCountries
        guard let defaultCountry = service.defaultCountry else {
            return XCTFail("no default country")
        }

        XCTAssertEqual(defaultCountry.regionCode, defaultRegionCode)
        XCTAssertTrue(countries.contains(defaultCountry))
    }

    func phoneNumberURL() {
        let url = service.phoneNumberURL("800 253 0000")
        XCTAssertNotNil(url)
        XCTAssertEqual(service.phoneNumberURL("800 253 0000"), URL(string: "tel://+18002530000"))
    }
}
