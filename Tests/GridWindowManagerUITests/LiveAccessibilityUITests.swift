import CoreGraphics
import XCTest

@MainActor
final class LiveAccessibilityUITests: XCTestCase
{
    func testRealAppArrangesAndRestoresFixtureWindow() throws
    {
        try XCTSkipUnless(
            Self.liveModeEnabled,
            "Run with --live-app-accessibility to move fixture windows."
        )
        let manager = XCUIApplication()
        let fixture = XCUIApplication(
            bundleIdentifier: "com.ideasbyrobert.GridWindowManager.WindowFixtureApp"
        )
        fixture.launch()
        defer
        {
            fixture.terminate()
            manager.terminate()
        }

        let fixtureWindow = fixture.windows.firstMatch
        XCTAssertTrue(fixtureWindow.waitForExistence(timeout: 5))
        fixture.activate()
        let originalFrame = fixtureWindow.frame

        manager.launchArguments =
        [
            "--ui-testing-live-target-bundle-identifier=com.ideasbyrobert.GridWindowManager.WindowFixtureApp",
            "--ui-testing-live-arrange-and-restore"
        ]
        manager.launch()
        if manager.staticTexts["Allow Window Arrangement"].waitForExistence(timeout: 1)
        {
            throw XCTSkip("The GridWindowManager app is not authorized for Accessibility.")
        }

        XCTAssertTrue(waitUntil(timeout: 5)
        {
            !approximatelyEqual(fixtureWindow.frame, originalFrame, tolerance: 4)
        })
        let arrangedFrame = fixtureWindow.frame
        XCTAssertLessThan(arrangedFrame.width, originalFrame.width)

        XCTAssertTrue(waitUntil(timeout: 5)
        {
            approximatelyEqual(fixtureWindow.frame, originalFrame, tolerance: 4)
        })
    }

    private func waitUntil(
        timeout: TimeInterval,
        condition: () -> Bool
    ) -> Bool
    {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline
        {
            if condition()
            {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        return condition()
    }

    private func approximatelyEqual(
        _ first: CGRect,
        _ second: CGRect,
        tolerance: CGFloat
    ) -> Bool
    {
        abs(first.minX - second.minX) <= tolerance
            && abs(first.minY - second.minY) <= tolerance
            && abs(first.width - second.width) <= tolerance
            && abs(first.height - second.height) <= tolerance
    }

    private static var liveModeEnabled: Bool
    {
#if GRIDWINDOWMANAGER_RUN_APP_AX_UI_TESTS
        true
#else
        false
#endif
    }
}
