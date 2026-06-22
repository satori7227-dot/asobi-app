import XCTest

final class ScreenshotTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func test_captureAppStoreScreenshots() throws {
        let app = XCUIApplication()
        app.launchArguments += [
            "-asobi.onboarding.v1.done", "YES",
            "-AppleLanguages", "(ja)",
            "-AppleLocale", "ja_JP",
        ]
        app.launch()

        attachScreenshot(name: "01_scene_picker")

        let drinkingTile = app.descendants(matching: .any)["scene-tile-drinking"]
        XCTAssertTrue(drinkingTile.waitForExistence(timeout: 5), "drinking scene tile not found")
        drinkingTile.tap()
        sleep(1)
        attachScreenshot(name: "02_context_input")

        let searchButton = app.buttons["ゲームを探す"]
        XCTAssertTrue(searchButton.waitForExistence(timeout: 5), "search button not found")
        searchButton.tap()
        sleep(2)
        attachScreenshot(name: "03_proposal")

        let firstCard = app.descendants(matching: .any)["proposal-card-0"]
        XCTAssertTrue(firstCard.waitForExistence(timeout: 5), "first proposal card not found")
        firstCard.tap()
        sleep(2)
        attachScreenshot(name: "04_game_detail")

        let closeButton = app.buttons["game-detail-close-button"]
        if closeButton.exists { closeButton.tap() }
        sleep(1)

        app.navigationBars.buttons.element(boundBy: 0).tap()
        sleep(1)
        app.navigationBars.buttons.element(boundBy: 0).tap()
        sleep(1)
        let toolsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'ツール' OR label CONTAINS[c] 'tools'")).firstMatch
        if toolsButton.waitForExistence(timeout: 2) {
            toolsButton.tap()
            sleep(1)
            attachScreenshot(name: "05_tools")
        } else {
            attachScreenshot(name: "05_scene_picker_alt")
        }
    }

    private func attachScreenshot(name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
