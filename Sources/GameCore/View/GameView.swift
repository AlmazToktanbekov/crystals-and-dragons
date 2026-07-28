import Foundation

/// «View» из MVC: всё, что игра умеет показать игроку.
///
/// Контроллер знает только этот протокол и не знает про print(), цвета
/// и форматирование строк. Захотим сделать UIKit-версию — напишем другой
/// класс, реализующий GameView, а логику не тронем вообще.
protocol GameView {
    func showWelcome()
    func showRoomCountPrompt()
    func showInvalidRoomCount(minimum: Int)
    func showMazeCreated(roomCount: Int, stepLimit: Int)

    /// Обычное описание комнаты (координаты, двери, предметы).
    func showRoom(_ room: Room)
    /// Тёмная комната: игрок ничего не видит.
    func showDarkness()
    /// «There is an evil dragon in the room!»
    func showMonster(_ monster: Monster)
    /// Подсказка про пять секунд.
    func showMonsterTimer(seconds: Int, canFight: Bool)
    func showStatus(_ player: Player)

    func showInfo(_ text: String)
    func showSuccess(_ text: String)
    func showWarning(_ text: String)
    func showError(_ text: String)

    func showHelp()
    func showInventory(_ player: Player)
    func showVictory(_ player: Player)
    func showDefeat(_ player: Player)
    func showGoodbye()
}
