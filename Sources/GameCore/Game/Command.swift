import Foundation

/// Команда игрока — результат разбора введённой строки.
///
/// enum с ассоциированными значениями удобен тем, что контроллер
/// работает уже с готовым «намерением» игрока, а не со строками.
enum Command: Equatable {
    case move(Direction)
    case get(String)
    case drop(String)
    case eat(String)
    case open(String)
    case fight
    case look
    case inventory
    case help
    case quit

    /// В тёмной комнате разрешено только движение (доп. задание).
    var isMovement: Bool {
        if case .move = self { return true }
        return false
    }
}
