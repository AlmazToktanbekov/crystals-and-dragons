import Foundation

/// Сторона света = дверь из комнаты.
///
/// `enum` идеально подходит: направлений ровно четыре, и компилятор
/// сам проследит, чтобы мы обработали все случаи в `switch`.
enum Direction: String, CaseIterable {
    case north = "N"
    case south = "S"
    case west  = "W"
    case east  = "E"

    /// Противоположное направление.
    /// Нужно, чтобы дверь была общей для двух комнат:
    /// если из комнаты A есть дверь на север, то из комнаты B — на юг.
    var opposite: Direction {
        switch self {
        case .north: return .south
        case .south: return .north
        case .west:  return .east
        case .east:  return .west
        }
    }

    /// Насколько меняются координаты при движении в эту сторону.
    /// Ось Y направлена вниз (как строки в матрице), поэтому север — это -1.
    var offset: (dx: Int, dy: Int) {
        switch self {
        case .north: return (0, -1)
        case .south: return (0, 1)
        case .west:  return (-1, 0)
        case .east:  return (1, 0)
        }
    }

    /// Читаемое имя для сообщений игроку.
    var title: String {
        switch self {
        case .north: return "north"
        case .south: return "south"
        case .west:  return "west"
        case .east:  return "east"
        }
    }

    /// Разбор пользовательского ввода: "n", "N", "north" -> .north
    init?(input: String) {
        let text = input.lowercased()
        guard let match = Direction.allCases.first(where: {
            $0.rawValue.lowercased() == text || $0.title == text
        }) else {
            return nil
        }
        self = match
    }
}
