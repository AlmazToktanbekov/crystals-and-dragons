import XCTest
@testable import GameCore

/// Проверяем честность мира: ключ и сундук есть, они достижимы,
/// а шагов заведомо хватает на путь «старт -> ключ -> сундук».
final class WorldPopulatorTests: XCTestCase {

    private let generator = RandomMazeGenerator()
    private let populator = WorldPopulator()

    func testKeyAndChestAlwaysExist() {
        for _ in 0..<30 {
            let world = populator.populate(maze: generator.generate(roomCount: 16))
            let items = world.maze.allRooms.flatMap(\.items)

            XCTAssertEqual(items.filter { $0 is Key }.count, 1)
            XCTAssertEqual(items.filter { $0 is Chest }.count, 1)
            XCTAssertEqual(items.filter { $0 is Torchlight }.count, 1)
            XCTAssertEqual(items.filter { $0 is Sword }.count, 1)
        }
    }

    func testStepLimitIsEnoughToReachKeyAndChest() {
        for roomCount in [4, 9, 16, 30] {
            for _ in 0..<20 {
                let world = populator.populate(maze: generator.generate(roomCount: roomCount))
                XCTAssertGreaterThan(
                    world.player.stepsLeft,
                    world.requiredSteps,
                    "Лимит шагов меньше кратчайшего пути до победы"
                )
            }
        }
    }

    func testKeyAndChestAreReachableFromStart() {
        for _ in 0..<30 {
            let world = populator.populate(maze: generator.generate(roomCount: 20))
            let reachable = world.maze.distances(from: world.player.position)

            let keyRoom = world.maze.allRooms.first { $0.items.contains { $0 is Key } }
            let chestRoom = world.maze.allRooms.first { $0.items.contains { $0 is Chest } }

            XCTAssertNotNil(keyRoom.flatMap { reachable[$0.position] })
            XCTAssertNotNil(chestRoom.flatMap { reachable[$0.position] })
        }
    }

    func testCriticalRoomsAreNeverDark() {
        for _ in 0..<30 {
            let world = populator.populate(maze: generator.generate(roomCount: 20))

            let critical = world.maze.allRooms.filter { room in
                room.position == world.player.position
                    || room.items.contains { $0 is Key || $0 is Chest || $0 is Torchlight }
            }
            XCTAssertTrue(critical.allSatisfy { !$0.isDark })
        }
    }
}
