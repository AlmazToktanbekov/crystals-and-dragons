import Foundation

/// Координаты комнаты в прямоугольной матрице лабиринта.
///
/// `Hashable` нужен, чтобы Position можно было класть в Set и использовать
/// как ключ словаря (мы так храним комнаты и результаты поиска в ширину).
struct Position: Hashable {
    let x: Int
    let y: Int

    /// Соседняя позиция в указанном направлении.
    func moved(_ direction: Direction) -> Position {
        Position(x: x + direction.offset.dx, y: y + direction.offset.dy)
    }

    var description: String { "[\(x),\(y)]" }
}
