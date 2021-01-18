//
//  Copyright © 2020 Rosberry. All rights reserved.
//

public protocol ServiceInitializable: class {
    associatedtype Dependencies
    init(dependencies: Dependencies)
}
