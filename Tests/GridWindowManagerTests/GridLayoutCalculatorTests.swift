import CoreGraphics
import XCTest
@testable import GridWindowManager

final class GridLayoutCalculatorTests: XCTestCase
{
    private let calculator = GridLayoutCalculator()
    private let screen = ScreenSnapshot(
        displayID: 1,
        frame: CGRect(x: 0, y: 0, width: 1220, height: 940),
        visibleFrame: CGRect(x: 10, y: 20, width: 1200, height: 900),
        backingScaleFactor: 2
    )

    func testEverySingleCellStaysWithinVisibleFrame()
    {
        for dimension in GridDimension.allCases
        {
            for row in 0..<dimension.rowCount
            {
                for column in 0..<dimension.columnCount
                {
                    let region = GridRegion(
                        dimension: dimension,
                        anchor: GridCell(row: row, column: column),
                        extent: GridCell(row: row, column: column)
                    )
                    let target = calculator.target(
                        for: .grid(region),
                        on: screen,
                        currentWindowFrame: .zero,
                        spacing: 8
                    )

                    XCTAssertTrue(screen.visibleFrame.contains(target.frame))
                    XCTAssertGreaterThan(target.frame.width, 0)
                    XCTAssertGreaterThan(target.frame.height, 0)
                }
            }
        }
    }

    func testFullGridTerminatesAtConfiguredOuterSpacing()
    {
        for dimension in GridDimension.allCases
        {
            let region = GridRegion(
                dimension: dimension,
                anchor: GridCell(row: 0, column: 0),
                extent: GridCell(
                    row: dimension.rowCount - 1,
                    column: dimension.columnCount - 1
                )
            )
            let target = calculator.target(
                for: .grid(region),
                on: screen,
                currentWindowFrame: .zero,
                spacing: 8
            )

            XCTAssertEqual(target.frame.minX, 18, accuracy: 0.001)
            XCTAssertEqual(target.frame.maxX, 1202, accuracy: 0.001)
            XCTAssertEqual(target.frame.minY, 28, accuracy: 0.001)
            XCTAssertEqual(target.frame.maxY, 912, accuracy: 0.001)
            XCTAssertEqual(target.edges, .all)
        }
    }

    func testAdjacentCellsRetainConfiguredGap()
    {
        let left = targetForCell(row: 1, column: 0, dimension: .three, spacing: 8)
        let right = targetForCell(row: 1, column: 1, dimension: .three, spacing: 8)
        let top = targetForCell(row: 0, column: 1, dimension: .three, spacing: 8)
        let bottom = targetForCell(row: 1, column: 1, dimension: .three, spacing: 8)

        XCTAssertEqual(right.frame.minX - left.frame.maxX, 8, accuracy: 0.5)
        XCTAssertEqual(top.frame.minY - bottom.frame.maxY, 8, accuracy: 0.5)
    }

    func testFourByTwoUsesFourColumnsAndTwoRows()
    {
        let topLeft = targetForCell(row: 0, column: 0, dimension: .fourByTwo, spacing: 0)
        let bottomRight = targetForCell(row: 1, column: 3, dimension: .fourByTwo, spacing: 0)

        XCTAssertEqual(topLeft.frame, CGRect(x: 10, y: 470, width: 300, height: 450))
        XCTAssertEqual(bottomRight.frame, CGRect(x: 910, y: 20, width: 300, height: 450))
        XCTAssertEqual(topLeft.edges, [.left, .top])
        XCTAssertEqual(bottomRight.edges, [.right, .bottom])
    }

    func testMultiCellSpanConsumesInternalGaps()
    {
        let region = GridRegion(
            dimension: .three,
            anchor: GridCell(row: 0, column: 0),
            extent: GridCell(row: 0, column: 1)
        )
        let span = calculator.target(
            for: .grid(region),
            on: screen,
            currentWindowFrame: .zero,
            spacing: 8
        )
        let first = targetForCell(row: 0, column: 0, dimension: .three, spacing: 8)
        let second = targetForCell(row: 0, column: 1, dimension: .three, spacing: 8)

        XCTAssertEqual(span.frame.minX, first.frame.minX, accuracy: 0.001)
        XCTAssertEqual(span.frame.maxX, second.frame.maxX, accuracy: 0.001)
    }

    func testZeroSpacingUsesEntireVisibleFrame()
    {
        let region = GridRegion(
            dimension: .four,
            anchor: GridCell(row: 0, column: 0),
            extent: GridCell(row: 3, column: 3)
        )
        let target = calculator.target(
            for: .grid(region),
            on: screen,
            currentWindowFrame: .zero,
            spacing: 0
        )

        XCTAssertEqual(target.frame, screen.visibleFrame)
    }

    func testOversizedSpacingStillProducesPositiveCells()
    {
        let tinyScreen = ScreenSnapshot(
            displayID: 2,
            frame: CGRect(x: 0, y: 0, width: 8, height: 8),
            visibleFrame: CGRect(x: 0, y: 0, width: 8, height: 8),
            backingScaleFactor: 2
        )
        let region = GridRegion(
            dimension: .four,
            anchor: GridCell(row: 3, column: 3),
            extent: GridCell(row: 3, column: 3)
        )
        let target = calculator.target(
            for: .grid(region),
            on: tinyScreen,
            currentWindowFrame: .zero,
            spacing: 32
        )

        XCTAssertGreaterThanOrEqual(target.frame.width, 0.5)
        XCTAssertGreaterThanOrEqual(target.frame.height, 0.5)
        XCTAssertTrue(tinyScreen.visibleFrame.contains(target.frame))
    }

    func testCenterPreservesWindowSizeAndCentersIt()
    {
        let currentFrame = CGRect(x: 100, y: 100, width: 600, height: 400)
        let target = calculator.target(
            for: .preset(.center),
            on: screen,
            currentWindowFrame: currentFrame,
            spacing: 8
        )

        XCTAssertEqual(target.frame.size, currentFrame.size)
        XCTAssertEqual(target.frame.midX, screen.visibleFrame.midX, accuracy: 0.001)
        XCTAssertEqual(target.frame.midY, screen.visibleFrame.midY, accuracy: 0.001)
        XCTAssertTrue(target.edges.isEmpty)
    }

    func testCommonPresetsMapToExpectedRegions()
    {
        let left = calculator.target(
            for: .preset(.leftHalf),
            on: screen,
            currentWindowFrame: .zero,
            spacing: 0
        )
        let bottomRight = calculator.target(
            for: .preset(.bottomRightQuarter),
            on: screen,
            currentWindowFrame: .zero,
            spacing: 0
        )

        XCTAssertEqual(left.frame, CGRect(x: 10, y: 20, width: 600, height: 900))
        XCTAssertEqual(bottomRight.frame, CGRect(x: 610, y: 20, width: 600, height: 450))
        XCTAssertEqual(left.edges, [.left, .top, .bottom])
        XCTAssertEqual(bottomRight.edges, [.right, .bottom])
    }

    private func targetForCell(
        row: Int,
        column: Int,
        dimension: GridDimension,
        spacing: CGFloat
    ) -> LayoutTarget
    {
        let region = GridRegion(
            dimension: dimension,
            anchor: GridCell(row: row, column: column),
            extent: GridCell(row: row, column: column)
        )
        return calculator.target(
            for: .grid(region),
            on: screen,
            currentWindowFrame: .zero,
            spacing: spacing
        )
    }
}
