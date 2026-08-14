import XCTest

@MainActor
final class MenuBarUITests: XCTestCase
{
    func testMenuEnablesBatchArrangementAtCapacity()
    {
        let application = launchMenu(windowCount: 8)
        let batchAction = application.menuItems["Arrange App Windows 4 × 2"]

        XCTAssertTrue(batchAction.waitForExistence(timeout: 2))
        XCTAssertTrue(batchAction.isEnabled)
        application.typeKey(XCUIKeyboardKey.escape.rawValue, modifierFlags: [])
        application.terminate()
    }

    func testMenuDisablesBatchArrangementAboveCapacity()
    {
        let application = launchMenu(windowCount: 9)
        let batchAction = application.menuItems["Arrange App Windows 4 × 2"]

        XCTAssertTrue(batchAction.waitForExistence(timeout: 2))
        XCTAssertFalse(batchAction.isEnabled)
        application.typeKey(XCUIKeyboardKey.escape.rawValue, modifierFlags: [])
        application.terminate()
    }

    func testMenuExposesWindowManagementCommandGroups()
    {
        let application = launchMenu(windowCount: 4)

        XCTAssertTrue(application.menuItems["Common Layouts"].exists)
        XCTAssertTrue(application.menuItems["Thirds"].exists)
        XCTAssertTrue(application.menuItems["Size and Position"].exists)
        XCTAssertTrue(application.menuItems["Move and Resize"].exists)
        XCTAssertTrue(application.menuItems["Saved App Layouts"].exists)
        XCTAssertTrue(application.menuItems["Restore Previous Frame"].exists)
        XCTAssertTrue(application.menuItems["Window Actions"].exists)
        XCTAssertTrue(application.menuItems["Desktop"].exists)
        XCTAssertTrue(application.menuItems["Displays"].exists)
        application.typeKey(XCUIKeyboardKey.escape.rawValue, modifierFlags: [])
        application.terminate()
    }

    private func launchMenu(windowCount: Int) -> XCUIApplication
    {
        let application = XCUIApplication()
        application.launchArguments = [
            "--ui-testing",
            "--ui-testing-batch-window-count=\(windowCount)"
        ]
        application.launch()

        let statusItem = application.statusItems.firstMatch
        XCTAssertTrue(statusItem.waitForExistence(timeout: 3))
        statusItem.click()
        return application
    }
}
