//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import KeychainAccess

public class KeychainServiceImp: KeychainService {

    public let keychain: Keychain

    public init(keychain: Keychain = .init()) {
        self.keychain = keychain
    }
}
