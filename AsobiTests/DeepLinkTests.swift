import XCTest
@testable import Asobi

final class DeepLinkTests: XCTestCase {
    func testParsesSceneURL() {
        let link = DeepLink(url: URL(string: "asobi://scene/drinking")!)
        XCTAssertEqual(link, .scene(id: "drinking"))
    }

    func testParsesSceneURLWithTrailingSlash() {
        let link = DeepLink(url: URL(string: "asobi://scene/family/")!)
        XCTAssertEqual(link, .scene(id: "family"))
    }

    func testParsesFavoritesURL() {
        let link = DeepLink(url: URL(string: "asobi://favorites")!)
        XCTAssertEqual(link, .favorites)
    }

    func testParsesCollectionsURL() {
        let link = DeepLink(url: URL(string: "asobi://collections")!)
        XCTAssertEqual(link, .collections)
    }

    func testRejectsUnknownScheme() {
        XCTAssertNil(DeepLink(url: URL(string: "https://example.com/scene/drinking")!))
    }

    func testRejectsUnknownHost() {
        XCTAssertNil(DeepLink(url: URL(string: "asobi://unknown")!))
    }

    func testRejectsSceneURLWithoutId() {
        XCTAssertNil(DeepLink(url: URL(string: "asobi://scene/")!))
        XCTAssertNil(DeepLink(url: URL(string: "asobi://scene")!))
    }

    func testParsesGameURL() {
        let link = DeepLink(url: URL(string: "asobi://game/yamanote-abc12345")!)
        XCTAssertEqual(link, .game(id: "yamanote-abc12345"))
    }

    func testParsesGameURLWithTrailingSlash() {
        let link = DeepLink(url: URL(string: "asobi://game/g1/")!)
        XCTAssertEqual(link, .game(id: "g1"))
    }

    func testRejectsGameURLWithoutId() {
        XCTAssertNil(DeepLink(url: URL(string: "asobi://game/")!))
        XCTAssertNil(DeepLink(url: URL(string: "asobi://game")!))
    }
}
