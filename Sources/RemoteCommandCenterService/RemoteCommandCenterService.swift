//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public protocol HasRemoteCommandCenterService {

    var remoteCommandCenterService: RemoteCommandCenterService { get }
}

public protocol RemoteCommandCenterService: class {

    var delegate: RemoteCommandCenterServiceDelegate? { get set }

    func setupControlCenterIfNeeded(skipTimeInterval: CFTimeInterval)
    func update(isEnabled: Bool)
    func reset()
}
