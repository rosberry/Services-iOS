//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import KeychainAccess

public class KeychainServiceImp: KeychainService, ServiceInitializable {

    public let keychain: Keychain

    required public init(dependencies: Any = []) {
        self.keychain = .init()
    }
}
