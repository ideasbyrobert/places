import Foundation

struct FourByTwoBatchLayout: Sendable
{
    static let capacity = GridDimension.fourByTwo.columnCount
        * GridDimension.fourByTwo.rowCount

    func regions(forWindowCount windowCount: Int) -> [GridRegion]?
    {
        guard (1...Self.capacity).contains(windowCount)
        else
        {
            return nil
        }
        let dimension = GridDimension.fourByTwo
        return (0..<windowCount).map
        {
            index in
            let cell = GridCell(
                row: index / dimension.columnCount,
                column: index % dimension.columnCount
            )
            return GridRegion(dimension: dimension, anchor: cell, extent: cell)
        }
    }
}
