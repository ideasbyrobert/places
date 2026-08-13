import CoreGraphics
import Foundation

struct MoveHistoryEntry: Sendable
{
    let token: ManagedWindowToken
    let previousFrame: CGRect
    let managedFrame: CGRect
}
