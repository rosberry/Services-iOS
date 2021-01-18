//
//  Copyright © 2018 Rosberry. All rights reserved.
//

import Foundation

public final class Phone {
    public var number: String
    public var country: PhoneCountry

    public init(number: String, country: PhoneCountry) {
        self.number = number
        self.country = country
    }
}
