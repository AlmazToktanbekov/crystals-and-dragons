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
/// 1. Берём сетку комнат без дверей.
/// 2. Идём из случайной комнаты, каждый раз выбирая случайного непосещённого
///    соседа и прорубая к нему дверь. Если соседей нет — откатываемся назад.
/// 3. В итоге получается «остовное дерево»: все комнаты соединены,
///    и лабиринт гарантированно проходим — изолированных кусков не бывает.
/// 4. Потом добавляем немного случайных дверей, чтобы появились кольца
///    и лабиринт стал интереснее.
struct RandomMazeGenerator: MazeGenerating {

    /// Вероятность добавить комнате лишнюю дверь (для разнообразия).
    private let extraDoorChance: Double

    init(extraDoorChance: Double = 0.2) {
        self.extraDoorChance = extraDoorChance
    }

    func generate(roomCount: Int) -> Maze {
        let size = Self.gridSize(for: roomCount)
        let maze = Maze(width: size.width, height: size.height)

        carvePassages(in: maze)
        addExtraDoors(in: maze)

        return maze
    }

    /// Подбираем размеры прямоугольной матрицы, близкие к квадрату.
    /// Например, для 10 комнат получится сетка 3x4 = 12 комнат.
    static func gridSize(for roomCount: Int) -> (width: Int, height: Int) {
        let requested = max(roomCount, 4)
        let width = max(2, Int(Double(requested).squareRoot().rounded()))
        let height = max(2, Int((Double(requested) / Double(width)).rounded(.up)))
        return (width, height)
    }

    // MARK: - Шаг 1: остовное дерево (гарантия связности)

    private func carvePassages(in maze: Maze) {
        let start = Position(
            x: Int.random(in: 0..<maze.width),
            y: Int.random(in: 0..<maze.height)
        )

        var visited: Set<Position> = [start]
        var stack: [Position] = [start]

        while let current = stack.last {
            // Куда ещё можно пойти из текущей комнаты?
            let options = Direction.allCases.filter { direction in
                let next = current.moved(direction)
                return maze.contains(next) && !visited.contains(next)
            }

            guard let direction = options.randomElement() else {
                stack.removeLast()   // тупик — откатываемся назад
                continue
            }

            let next = current.moved(direction)
            maze.openDoor(from: current, to: direction)
            visited.insert(next)
            stack.append(next)
        }
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
