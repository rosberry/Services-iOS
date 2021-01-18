//
//  Copyright © 2019 SecondPhone LLC. All rights reserved.
//

import Foundation

public protocol Track {
    var title: String { get }
    var duration: TimeInterval { get }
    var url: URL { get }
}
