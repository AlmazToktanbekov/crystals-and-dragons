import XCTest
@testable import GameCore

/// Проверяем главное требование задания: лабиринт не должен быть непроходимым.
final class MazeGeneratorTests: XCTestCase {

    private let generator = RandomMazeGenerator()

    func testMazeIsAlwaysConnected() {
        // Генерация случайная, поэтому прогоняем много раз.
        for roomCount in [4, 9, 12, 25, 40] {
            for _ in 0..<20 {
                let maze = generator.generate(roomCount: roomCount)
                XCTAssertTrue(maze.isConnected, "Лабиринт из \(roomCount) комнат оказался несвязным")
            }
        }
    }

    func testEveryRoomHasFromOneToFourDoors() {
        let maze = generator.generate(roomCount: 20)

        for room in maze.allRooms {
            XCTAssertGreaterThanOrEqual(room.doors.count, 1)
            XCTAssertLessThanOrEqual(room.doors.count, 4)
        }
    }

    func testDoorsAreTwoWay() {
        let maze = generator.generate(roomCount: 16)

        for room in maze.allRooms {
            for direction in room.doors {
                let neighbour = maze.room(at: room.position.moved(direction))
                XCTAssertNotNil(neighbour, "Дверь ведёт за пределы лабиринта")
                XCTAssertTrue(
                    neighbour?.doors.contains(direction.opposite) ?? false,
                    "У соседа нет ответной двери"
                )
            }
        }
    }

    func testGridIsBigEnoughForRequestedRoomCount() {
        for roomCount in [4, 7, 10, 33] {
            let size = RandomMazeGenerator.gridSize(for: roomCount)
            XCTAssertGreaterThanOrEqual(size.width * size.height, roomCount)
        }
    }
}
