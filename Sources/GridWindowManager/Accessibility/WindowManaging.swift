import Foundation

protocol WindowManaging: Sendable
{
    func captureFocusedWindow(
        processIdentifier: pid_t,
        converter: ScreenCoordinateConverter
    ) async -> WindowCaptureResult

    func captureStandardWindows(
        processIdentifier: pid_t,
        converter: ScreenCoordinateConverter
    ) async -> Result<[ManagedWindowSnapshot], MoveFailure>

    func captureFocusedWindowForLifecycle(
        processIdentifier: pid_t,
        converter: ScreenCoordinateConverter
    ) async -> WindowCaptureResult

    func captureStandardWindow(
        at point: CGPoint,
        converter: ScreenCoordinateConverter
    ) async -> WindowCaptureResult

    func snapshot(
        for token: ManagedWindowToken,
        converter: ScreenCoordinateConverter
    ) async -> WindowCaptureResult

    func apply(
        target: LayoutTarget,
        to token: ManagedWindowToken,
        converter: ScreenCoordinateConverter,
        command: LayoutCommand?,
        historyPreviousFrame: CGRect?
    ) async -> MoveResult

    func perform(
        _ action: WindowLifecycleAction,
        on token: ManagedWindowToken,
        converter: ScreenCoordinateConverter
    ) async -> WindowOperationResult

    func undoLast(converter: ScreenCoordinateConverter) async -> MoveResult

    func lastCommand(for token: ManagedWindowToken) async -> LayoutCommand?
}
