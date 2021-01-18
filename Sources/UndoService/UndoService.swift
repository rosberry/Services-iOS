//
//  Copyright © 2020 Rosberry. All rights reserved.
//

public protocol HasUndoService {

    var undoService: UndoService { get }
}

public protocol UndoService: class {

    /// A Boolean value that indicates whether the receiver has any actions to undo.
    var canUndo: Bool { get }

    /// A Boolean value that indicates whether the receiver has any actions to redo.
    var canRedo: Bool { get }

    /// Registers the specified closure to implement a single undo operation that the target receives.
    /// - Parameters:
    ///   - target: The target of the undo operation.
    ///             The undo manager maintains an unowned reference to the target to prevent retain cycles.
    ///   - handler: A closure to be executed when an operation is undone.
    ///              The closure takes a single argument, the target of the undo operation.
    func registerUndo<TargetType>(withTarget target: TargetType, handler: @escaping (TargetType) -> Void) where TargetType: AnyObject

    /// Closes the top-level undo group if necessary and invokes undoNestedGroup().
    func undo()

    /// Performs the operations in the last group on the redo stack, if there are any, recording them on the undo stack as a single group.
    func redo()

    /// Disables the recording of undo operations, whether by `registerUndo(withTarget:selector:object:)` or by invocation-based undo.
    func disableUndoRegistration()

    /// Enables the recording of undo operations.
    func enableUndoRegistration()

    /// Calls handler inside undo grouping.
    /// - Parameter handler: The handler for undo actions.
    func groupUndo(handler: () -> Void)

    /// Clears the undo and redo stacks and re-enables the receiver.
    func removeAllActions()
}
