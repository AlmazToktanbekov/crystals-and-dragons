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

    /// Служебные команды не трогают мир, поэтому темнота им не мешает:
    /// выйти из игры или посмотреть рюкзак можно и в темноте.
    var isMetaCommand: Bool {
        switch self {
        case .quit, .help, .inventory: return true
        default:                       return false
        }
    }

    /// Что вообще можно делать в тёмной комнате.
    var isAllowedInDarkness: Bool {
        isMovement || isMetaCommand
    }
}
