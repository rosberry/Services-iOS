//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import KeychainAccess

public protocol HasKeychainService {

    var keychainService: KeychainService { get }
}

public protocol KeychainService {

    var keychain: Keychain { get }
}
