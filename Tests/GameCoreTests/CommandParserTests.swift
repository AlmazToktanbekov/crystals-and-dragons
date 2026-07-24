import XCTest
@testable import GameCore

final class CommandParserTests: XCTestCase {

    private let parser = CommandParser()

    func testMovementCommands() {
        XCTAssertEqual(parser.parse("N"), .move(.north))
        XCTAssertEqual(parser.parse("s"), .move(.south))
        XCTAssertEqual(parser.parse("  W  "), .move(.west))
        XCTAssertEqual(parser.parse("east"), .move(.east))
        XCTAssertEqual(parser.parse("go north"), .move(.north))
    }

    func testItemCommands() {
        XCTAssertEqual(parser.parse("get key"), .get("key"))
        XCTAssertEqual(parser.parse("GET GOLD"), .get("gold"))
        XCTAssertEqual(parser.parse("drop torchlight"), .drop("torchlight"))
        XCTAssertEqual(parser.parse("eat apple"), .eat("apple"))
    }

    func testOpenDefaultsToChest() {
        XCTAssertEqual(parser.parse("open"), .open("chest"))
        XCTAssertEqual(parser.parse("open chest"), .open("chest"))
    }

    func testServiceCommands() {
        XCTAssertEqual(parser.parse("fight"), .fight)
        XCTAssertEqual(parser.parse("inventory"), .inventory)
        XCTAssertEqual(parser.parse("help"), .help)
        XCTAssertEqual(parser.parse("quit"), .quit)
    }

    func testUnknownInput() {
        XCTAssertNil(parser.parse(""))
        XCTAssertNil(parser.parse("dance"))
        XCTAssertNil(parser.parse("get"))
    }

    func testOnlyMovementIsMovement() {
        XCTAssertTrue(Command.move(.north).isMovement)
        XCTAssertFalse(Command.get("key").isMovement)
        XCTAssertFalse(Command.fight.isMovement)
    }
}
