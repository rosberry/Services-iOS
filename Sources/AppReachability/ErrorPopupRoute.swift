//
// Copyright © 2020 Rosberry. All rights reserved.
//

public protocol ErrorPopupRoute: class {
    func show(_ error: Error, settings: ErrorPopupSettings)
    func hide(completionHandler: (() -> Void)?)
}
