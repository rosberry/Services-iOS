//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class UndoServiceImp: UndoManager, UndoService, ServiceInitializable {
    public init(dependencies: Any = []) {}

    // MARK: - Lifecycle

    override public func undo() {
        guard canUndo else {
            return
        }

        super.undo()
    }

    override public func redo() {
        guard canRedo else {
            return
        }

        super.redo()
    }
}

public extension UndoManager {

    /// Calls handler inside undo grouping.
    /// - Parameter handler: The handler for undo actions.
    func groupUndo(handler: () -> Void) {
        beginUndoGrouping()
        handler()
        endUndoGrouping()
    }
}
