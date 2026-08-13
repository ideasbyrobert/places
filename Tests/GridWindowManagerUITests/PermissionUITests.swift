import XCTest

@MainActor
final class PermissionUITests: XCTestCase
{
    func testPermissionSurfaceExplainsTheAccessibilityBoundary()
    {
        let application = XCUIApplication()
        application.launchArguments = ["--ui-testing", "--ui-testing-permission"]
        application.launch()

        let ready = application.staticTexts["Ready to Arrange Windows"]
        let required = application.staticTexts["Allow Window Arrangement"]
        XCTAssertTrue(
            ready.waitForExistence(timeout: 3) || required.waitForExistence(timeout: 3)
        )
    }
}
