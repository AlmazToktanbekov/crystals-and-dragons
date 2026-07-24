import Foundation

/// Игрок: где стоит, что несёт, сколько осталось сил.
///
/// «Жизненная сила», «здоровье» и «лимит шагов» в этой игре — одно и то же
/// (так сказано в задании), поэтому здесь одно поле `stepsLeft`.
final class Player {
    /// Текущая комната.
    var position: Position
    /// Комната, из которой пришли (монстр может отбросить нас назад).
    private(set) var previousPosition: Position

    /// Максимальный запас шагов (может расти от еды и падать от монстров).
    private(set) var maxSteps: Int
    /// Сколько шагов осталось.
    private(set) var stepsLeft: Int

    private(set) var inventory: [Item] = []
    private(set) var coins: Int = 0

    init(position: Position, stepLimit: Int) {
        self.position = position
        self.previousPosition = position
        self.maxSteps = stepLimit
        self.stepsLeft = stepLimit
    }

    var isAlive: Bool { stepsLeft > 0 }

    /// Есть ли в инвентаре предмет с таким именем.
    func hasItem(named name: String) -> Bool {
        inventory.contains { $0.name.lowercased() == name.lowercased() }
    }

    /// Несёт ли игрок источник света (факел).
    var carriesLight: Bool {
        inventory.contains { $0 is LightSource }
    }

    /// Несёт ли игрок оружие (меч).
    var carriesWeapon: Bool {
        inventory.contains { $0 is Weapon }
    }

    func item(named name: String) -> Item? {
        inventory.first { $0.name.lowercased() == name.lowercased() }
    }

    func take(_ item: Item) {
        inventory.append(item)
    }

    @discardableResult
    func removeItem(named name: String) -> Item? {
        guard let index = inventory.firstIndex(where: { $0.name.lowercased() == name.lowercased() }) else {
            return nil
        }
        return inventory.remove(at: index)
    }

    // MARK: - Перемещение

    /// Переход в соседнюю комнату: запоминаем откуда пришли и тратим шаг.
    func move(to newPosition: Position) {
        previousPosition = position
        position = newPosition
        stepsLeft = max(0, stepsLeft - 1)
    }

    /// Монстр отбрасывает игрока назад. Шаг за это не тратится.
    func throwBack() {
        position = previousPosition
    }

    // MARK: - Здоровье

    /// Монстр отнимает 10% жизненной силы (то есть лимита ходов).
    func loseHealth(percent: Int) {
        let loss = max(1, maxSteps * percent / 100)
        maxSteps = max(0, maxSteps - loss)
        stepsLeft = max(0, stepsLeft - loss)
    }

    /// Еда увеличивает и запас, и остаток шагов.
    func eat(_ food: Edible) {
        maxSteps += food.nutrition
        stepsLeft += food.nutrition
    }

    func addCoins(_ amount: Int) {
        coins += amount
    }
}
