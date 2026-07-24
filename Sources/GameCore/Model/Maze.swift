import Foundation

/// Лабиринт — прямоугольная матрица комнат.
///
/// Класс отвечает за хранение комнат и за «геометрию»: где сосед,
/// как открыть дверь, как посчитать расстояния. Правил игры здесь нет.
final class Maze {
    let width: Int
    let height: Int

    private var rooms: [Position: Room]

    init(width: Int, height: Int) {
        self.width = width
        self.height = height

        var storage: [Position: Room] = [:]
        for y in 0..<height {
            for x in 0..<width {
                let position = Position(x: x, y: y)
                storage[position] = Room(position: position)
            }
        }
        self.rooms = storage
    }

    var roomCount: Int { width * height }

    /// Все комнаты в стабильном порядке (слева направо, сверху вниз).
    var allRooms: [Room] {
        rooms.values.sorted {
            ($0.position.y, $0.position.x) < ($1.position.y, $1.position.x)
        }
    }

    func contains(_ position: Position) -> Bool {
        (0..<width).contains(position.x) && (0..<height).contains(position.y)
    }

    func room(at position: Position) -> Room? {
        rooms[position]
    }

    /// Прорубить дверь между комнатой и её соседом.
    /// Дверь всегда двусторонняя: она появляется у обеих комнат.
    func openDoor(from position: Position, to direction: Direction) {
        let neighbourPosition = position.moved(direction)
        guard let room = rooms[position], let neighbour = rooms[neighbourPosition] else { return }
        room.doors.insert(direction)
        neighbour.doors.insert(direction.opposite)
    }

    /// Куда можно шагнуть из комнаты (список доступных соседей).
    func neighbours(of position: Position) -> [Position] {
        guard let room = rooms[position] else { return [] }
        return room.doors.map { position.moved($0) }.filter { rooms[$0] != nil }
    }

    /// Поиск в ширину (BFS): кратчайшее число шагов от `start` до каждой комнаты.
    ///
    /// Нужен для двух вещей:
    /// 1) проверить, что лабиринт связный (до всех комнат можно дойти);
    /// 2) выдать игроку такой лимит шагов, которого точно хватит до ключа и сундука.
    func distances(from start: Position) -> [Position: Int] {
        var result: [Position: Int] = [start: 0]
        var queue: [Position] = [start]
        var head = 0

        while head < queue.count {
            let current = queue[head]
            head += 1
            let currentDistance = result[current] ?? 0

            for neighbour in neighbours(of: current) where result[neighbour] == nil {
                result[neighbour] = currentDistance + 1
                queue.append(neighbour)
            }
        }
        return result
    }

    /// Связный ли лабиринт: из любой комнаты можно добраться до любой другой.
    var isConnected: Bool {
        guard let start = allRooms.first?.position else { return true }
        return distances(from: start).count == roomCount
    }
}
