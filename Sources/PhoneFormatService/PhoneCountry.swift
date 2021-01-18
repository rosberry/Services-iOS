//
//  Copyright © 2018 Rosberry. All rights reserved.
//

import Foundation

public struct PhoneCountry: Equatable {

    public let mobileCode: UInt64
    public let regionCode: String
    public let name: String

    public init(mobileCode: UInt64, regionCode: String, name: String) {
        self.mobileCode = mobileCode
        self.regionCode = regionCode
        self.name = name
    }
}

extension PhoneCountry: CustomStringConvertible {
    public var description: String {
        return "\(name) +\(mobileCode)"
    }
}
