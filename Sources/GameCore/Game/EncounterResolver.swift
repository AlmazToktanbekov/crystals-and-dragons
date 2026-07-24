import Foundation

/// Чем закончилась встреча с монстром (правила взяты из задания).
enum EncounterOutcome: Equatable {
    /// Игрок не успел за 5 секунд: −10% сил и отброс в предыдущую комнату.
    case tooSlow
    /// Успел, но не повезло (1/3): −10% сил, отброс назад, команда не выполняется.
    case punished
    /// Успел (1/3): команда выполняется, но −10% сил.
    case hurtButActed
    /// Успел (1/3): команда выполняется, потерь нет.
    case unharmed
}

/// Кто решает исход встречи. Отдельный протокол — чтобы в тестах
/// заменить случайность на заранее заданный результат.
protocol EncounterResolving {
    func resolve(playerActedInTime: Bool) -> EncounterOutcome
}

/// Стандартные правила: не успел — наказание, успел — бросок кубика на три исхода.
struct RandomEncounterResolver: EncounterResolving {

    func resolve(playerActedInTime: Bool) -> EncounterOutcome {
        guard playerActedInTime else { return .tooSlow }

        switch Int.random(in: 0..<3) {
        case 0:  return .punished
        case 1:  return .hurtButActed
        default: return .unharmed
        }
    }
}
