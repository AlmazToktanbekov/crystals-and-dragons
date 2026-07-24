import Foundation

/// Базовый протокол любого игрового предмета.
///
/// Это главный пример полиморфизма в проекте: комната хранит `[Item]`,
/// то есть массив «чего угодно, что является предметом». Игре не важно,
/// ключ там лежит или золото — она работает с общим интерфейсом.
protocol Item {
    /// Имя для команд игрока: `get key` -> ищем предмет с name == "key".
    var name: String { get }
    /// Как предмет показывается на экране (у золота это "gold (320 coins)").
    var displayName: String { get }
    /// Можно ли положить предмет в инвентарь (сундук — нельзя).
    var isPortable: Bool { get }
}

// Значения по умолчанию: большинство предметов показываются своим именем
// и спокойно кладутся в рюкзак. Конкретные типы переопределяют это при желании.
extension Item {
    var displayName: String { name }
    var isPortable: Bool { true }
}

/// Предмет, который светит. Пока такой предмет у игрока в руках
/// или лежит в комнате — тёмная комната считается освещённой.
protocol LightSource: Item {}

/// Съедобный предмет: восстанавливает жизненные силы (лимит шагов).
protocol Edible: Item {
    var nutrition: Int { get }
}

/// Оружие: даёт игроку команду `fight`.
protocol Weapon: Item {}

// MARK: - Конкретные предметы

/// Ключ — нужен, чтобы открыть сундук.
struct Key: Item {
    let name = "key"
}

/// Сундук. Его нельзя поднять, но можно открыть ключом — это победа.
struct Chest: Item {
    let name = "chest"
    let isPortable = false
}

/// Факел. Освещает тёмные комнаты.
struct Torchlight: LightSource {
    let name = "torchlight"
}

/// Меч. Позволяет драться с монстрами.
struct Sword: Weapon {
    let name = "sword"
}

/// Еда. `nutrition` — сколько шагов добавится к лимиту.
struct Food: Edible {
    let name: String
    let nutrition: Int
}

/// Золото. Отличается тем, что в инвентарь не попадает:
/// при `get gold` монеты сразу прибавляются к кошельку игрока.
struct Gold: Item {
    let name = "gold"
    let amount: Int

    var displayName: String { "gold (\(amount) coins)" }
}

/// Обычный предмет без особых свойств (можно носить с собой просто так).
struct SimpleItem: Item {
    let name: String
}
