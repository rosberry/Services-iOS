//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import PhoneNumberKit

public final class PhoneFormatServiceImp: PhoneFormatService {
    private lazy var phoneNumberKit = PhoneNumberKit()
    private lazy var formatter = PartialFormatter(phoneNumberKit: phoneNumberKit)

    public lazy var allCountries: [PhoneCountry] = {
        phoneNumberKit.allCountries().compactMap { regionCode -> PhoneCountry? in
            guard regionCode != "001", // world
                  let mobileCode = phoneNumberKit.countryCode(for: regionCode),
                  let name = Locale.current.localizedString(forRegionCode: regionCode) else {
                return nil
            }
            return PhoneCountry(mobileCode: mobileCode, regionCode: regionCode, name: name)
        }.sorted { country1, country2 -> Bool in
            country1.name < country2.name
        }
    }()

    public var defaultCountry: PhoneCountry? {
        allCountries.first { country in
            country.regionCode == defaultRegionCode
        }
    }

    public var defaultRegionCode: String {
        PhoneNumberKit.defaultRegionCode()
    }

    public init() {}

    public func validate(phoneNumber: String, withRegionCode regionCode: String?) -> Bool {
        let regionCode = regionCode ?? defaultRegionCode
        guard let countryCode = phoneNumberKit.countryCode(for: regionCode),
              let number = try? phoneNumberKit.parse(phoneNumber, withRegion: regionCode),
              number.countryCode == countryCode else {
            return false
        }
        return true
    }

    public func internationalFormatOf(phoneNumber: String, withRegionCode regionCode: String?) -> String? {
        format(phoneNumber: phoneNumber, toType: .international, withRegionCode: regionCode)
    }

    public func nationalFormatOf(phoneNumber: String, withRegionCode regionCode: String?) -> String? {
        format(phoneNumber: phoneNumber, toType: .national, withRegionCode: regionCode)
    }

    public func e164FormatOf(phoneNumber: String, withRegionCode regionCode: String?) -> String? {
        format(phoneNumber: phoneNumber, toType: .e164, withRegionCode: regionCode)
    }

    public func internationalFormatOf(phoneNumber: String, withoutRegionCode regionCode: String?) -> String? {
        format(phoneNumber: phoneNumber, toType: .international, withoutRegionCode: regionCode)
    }

    public func nationalFormatOf(phoneNumber: String, withoutRegionCode regionCode: String?) -> String? {
        format(phoneNumber: phoneNumber, toType: .national, withoutRegionCode: regionCode)
    }

    public func e164FormatOf(phoneNumber: String, withoutRegionCode regionCode: String?) -> String? {
        format(phoneNumber: phoneNumber, toType: .e164, withoutRegionCode: regionCode)
    }

    public func partialFormatOf(phoneNumber: String, regionCode: String?) -> String {
        let regionCode = regionCode ?? defaultRegionCode
        return PartialFormatter(phoneNumberKit: phoneNumberKit, defaultRegion: regionCode).formatPartial(phoneNumber)
    }

    public func phoneNumberURL(_ phoneNumber: String) -> URL? {
        guard let phoneNumber = try? phoneNumberKit.parse(phoneNumber) else {
            return nil
        }
        return URL(string: "tel://\(phoneNumberKit.format(phoneNumber, toType: .e164))")
    }

    // MARK: - Private

    private func format(phoneNumber: String, toType type: PhoneNumberFormat, withRegionCode regionCode: String?) -> String? {
        let regionCode = regionCode ?? defaultRegionCode
        guard let countryCode = phoneNumberKit.countryCode(for: regionCode) else {
            return nil
        }

        let phoneNumberString = "+\(countryCode)\(phoneNumber)"
        guard let phoneNumber = try? phoneNumberKit.parse(phoneNumberString) else {
            return nil
        }
        return phoneNumberKit.format(phoneNumber, toType: type)
    }

    private func format(phoneNumber: String, toType type: PhoneNumberFormat, withoutRegionCode regionCode: String?) -> String? {
        let regionCode = regionCode ?? defaultRegionCode
        if let phoneNumber = try? phoneNumberKit.parse(phoneNumber, withRegion: regionCode) {
            return phoneNumberKit.format(phoneNumber, toType: type, withPrefix: false)
        }
        return nil
    }
}
