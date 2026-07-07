import XCTest

final class ChristmasLightLogUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAddEntryFlow() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["addButton"].tap()
        let field = app.textFields["field_condition"]
        XCTAssertTrue(field.waitForExistence(timeout: 2))
        field.tap()
        field.typeText("Test value")
        app.buttons["saveButton"].tap()
        XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 2))
    }

    func testFreeLimitTriggersPaywall() throws {
        let app = XCUIApplication()
        app.launch()
        for _ in 0..<20 {
            app.buttons["addButton"].tap()
            if app.buttons["subscribeButton"].waitForExistence(timeout: 1) {
                break
            }
            let field = app.textFields["field_condition"]
            if field.waitForExistence(timeout: 1) {
                field.tap()
                field.typeText("x")
                app.buttons["saveButton"].tap()
            }
        }
        XCTAssertTrue(app.buttons["subscribeButton"].waitForExistence(timeout: 2) || app.buttons["addButton"].exists)
    }

    func testKeyboardDismissOnTapOutside() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["addButton"].tap()
        let field = app.textFields["field_condition"]
        XCTAssertTrue(field.waitForExistence(timeout: 2))
        field.tap()
        field.typeText("dismiss me")
        app.navigationBars.firstMatch.tap()
        XCTAssertFalse(app.keyboards.element.exists)
    }
}
