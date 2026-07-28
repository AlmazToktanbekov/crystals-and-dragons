import Foundation

/// Протокол генератора лабиринта.
///
/// Отдельный протокол нужен, чтобы игру можно было тестировать
/// с «предсказуемым» лабиринтом вместо случайного.
protocol MazeGenerating {
    func generate(roomCount: Int) -> Maze
}

/// Случайный генератор на основе обхода в глубину (DFS).
///
/// Как это работает:
/// 1. Берём пустую сетку, в которую заведомо влезает нужное число комнат.
/// 2. Идём из случайной клетки, каждый раз выбирая случайного непосещённого
///    соседа и запоминая дверь к нему. Если соседей нет — откатываемся назад.
///    Останавливаемся, как только набрали ровно столько комнат, сколько просили.
/// 3. В итоге получается «остовное дерево»: все комнаты соединены,
///    и лабиринт гарантированно проходим — изолированных кусков не бывает.
///    Незанятые клетки сетки комнатами не становятся.
/// 4. Потом добавляем немного случайных дверей, чтобы появились кольца
///    и лабиринт стал интереснее.
struct RandomMazeGenerator: MazeGenerating {

    /// Меньше четырёх комнат делать бессмысленно.
    static let minimumRoomCount = 4

    /// Вероятность добавить комнате лишнюю дверь (для разнообразия).
    private let extraDoorChance: Double

    init(extraDoorChance: Double = 0.2) {
        self.extraDoorChance = extraDoorChance
    }

    func generate(roomCount: Int) -> Maze {
        let requested = max(roomCount, Self.minimumRoomCount)
        let size = Self.gridSize(for: requested)

        let plan = carvePlan(roomCount: requested, in: size)
        let maze = Maze(width: size.width, height: size.height, positions: plan.rooms)
        for door in plan.doors {
            maze.openDoor(from: door.from, to: door.direction)
        }

        addExtraDoors(in: maze)

        return maze
    }

    /// Габариты сетки, близкие к квадрату и заведомо вмещающие все комнаты.
    /// Например, для 7 комнат получится сетка 3x3, две клетки останутся пустыми.
    static func gridSize(for roomCount: Int) -> (width: Int, height: Int) {
        let requested = max(roomCount, minimumRoomCount)
        let width = max(2, Int(Double(requested).squareRoot().rounded()))
        let height = max(2, Int((Double(requested) / Double(width)).rounded(.up)))
        return (width, height)
    }

    // MARK: - Шаг 1: остовное дерево (гарантия связности)

    private struct Door {
        let from: Position
        let direction: Direction
    }

    private struct Plan {
        let rooms: Set<Position>
        let doors: [Door]
    }

    /// Выбираем клетки будущих комнат и двери между ними.
    /// Комнат получается ровно `roomCount`, и все они связаны в дерево.
    private func carvePlan(roomCount: Int, in size: (width: Int, height: Int)) -> Plan {
        func insideGrid(_ position: Position) -> Bool {
            (0..<size.width).contains(position.x) && (0..<size.height).contains(position.y)
        }

        let start = Position(
            x: Int.random(in: 0..<size.width),
            y: Int.random(in: 0..<size.height)
        )

        var visited: Set<Position> = [start]
        var doors: [Door] = []
        var stack: [Position] = [start]

        while visited.count < roomCount, let current = stack.last {
            // Куда ещё можно пойти из текущей клетки?
            let options = Direction.allCases.filter { direction in
                let next = current.moved(direction)
                return insideGrid(next) && !visited.contains(next)
            }

            guard let direction = options.randomElement() else {
                stack.removeLast()   // тупик — откатываемся назад
                continue
            }

            let next = current.moved(direction)
            doors.append(Door(from: current, direction: direction))
            visited.insert(next)
            stack.append(next)
        }

        return Plan(rooms: visited, doors: doors)
    }

    // MARK: - Шаг 2: немного лишних дверей

    private func addExtraDoors(in maze: Maze) {
        for room in maze.allRooms {
            guard Double.random(in: 0...1) < extraDoorChance else { continue }

            let closed = Direction.allCases.filter { direction in
                maze.contains(room.position.moved(direction)) && !room.doors.contains(direction)
            }
            guard let direction = closed.randomElement() else { continue }
            maze.openDoor(from: room.position, to: direction)
        }
    }
}
