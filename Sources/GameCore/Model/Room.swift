import Foundation

/// Комната лабиринта — «клетка» игрового мира.
final class Room {
    let position: Position

    /// Двери комнаты. Set, потому что в одну сторону дверь бывает только одна.
    var doors: Set<Direction> = []

    /// Предметы, лежащие на полу.
    var items: [Item] = []

    /// Монстр (если есть).
    var monster: Monster?

    /// Тёмная ли это комната изначально (доп. задание).
    var isDark: Bool = false

    /// Стала ли комната освещённой навсегда.
    /// Ставится в true, когда игрок бросил здесь факел.
    var isPermanentlyLit: Bool = false

    init(position: Position) {
        self.position = position
    }

    /// Лежит ли в комнате источник света.
    var containsLightSource: Bool {
        items.contains { $0 is LightSource }
    }

    /// Живой монстр в комнате (nil, если монстра нет или он убит).
    var livingMonster: Monster? {
        guard let monster, monster.isAlive else { return nil }
        return monster
    }

    /// Найти предмет по имени, которое ввёл игрок.
    func item(named name: String) -> Item? {
        items.first { $0.name.lowercased() == name.lowercased() }
    }

    /// Забрать предмет из комнаты (вернёт nil, если такого предмета нет).
    @discardableResult
    func removeItem(named name: String) -> Item? {
        guard let index = items.firstIndex(where: { $0.name.lowercased() == name.lowercased() }) else {
            return nil
        }
        return items.remove(at: index)
    }

    func addItem(_ item: Item) {
        items.append(item)
    }
}
