import XCTest
@testable import GridWindowManager

final class FourByTwoBatchLayoutTests: XCTestCase
{
    private let layout = FourByTwoBatchLayout()

    func testRejectsCountsOutsideCapacity()
    {
        XCTAssertNil(layout.regions(forWindowCount: 0))
        XCTAssertNil(layout.regions(forWindowCount: 9))
    }

    func testMapsEightWindowsAcrossAllPositions()
    {
        let regions = layout.regions(forWindowCount: 8)

        XCTAssertEqual(regions?.count, 8)
        XCTAssertEqual(regions?.first?.minimumRow, 0)
        XCTAssertEqual(regions?.first?.minimumColumn, 0)
        XCTAssertEqual(regions?.last?.maximumRow, 1)
        XCTAssertEqual(regions?.last?.maximumColumn, 3)
    }

    func testPartialLayoutUsesLeadingPositions()
    {
        let regions = layout.regions(forWindowCount: 5)

        XCTAssertEqual(regions?.count, 5)
        XCTAssertEqual(regions?.last?.minimumRow, 1)
        XCTAssertEqual(regions?.last?.minimumColumn, 0)
    }
}
