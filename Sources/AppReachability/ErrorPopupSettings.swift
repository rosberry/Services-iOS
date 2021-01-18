//
// Copyright © 2020 Rosberry. All rights reserved.
//

public protocol ErrorPopupSettings {
    var isDismissible: Bool { get }
    var actionHandler: (() -> Void)? { get }
    var closeHandler: (() -> Void)? { get }
}
