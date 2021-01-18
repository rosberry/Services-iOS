//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public protocol PhoneFormatService {
    var allCountries: [PhoneCountry] { get }
    var defaultCountry: PhoneCountry? { get }
    var defaultRegionCode: String { get }

    func validate(phoneNumber: String, withRegionCode regionCode: String?) -> Bool
    func internationalFormatOf(phoneNumber: String, withRegionCode regionCode: String?) -> String?
    func internationalFormatOf(phoneNumber: String, withoutRegionCode regionCode: String?) -> String?
    func nationalFormatOf(phoneNumber: String, withRegionCode regionCode: String?) -> String?
    func nationalFormatOf(phoneNumber: String, withoutRegionCode regionCode: String?) -> String?
    func e164FormatOf(phoneNumber: String, withRegionCode regionCode: String?) -> String?
    func e164FormatOf(phoneNumber: String, withoutRegionCode regionCode: String?) -> String?
    func partialFormatOf(phoneNumber: String, regionCode: String?) -> String
    func phoneNumberURL(_ phoneNumber: String) -> URL?
}
