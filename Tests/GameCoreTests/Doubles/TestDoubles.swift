import Foundation
@testable import GameCore

/// «Поддельный» экран: вместо печати запоминает, что игра хотела показать.
/// Так тест может проверить исход партии, не читая консоль.
final class SpyView: GameView {

    private(set) var messages: [String] = []
    private(set) var didWin = false
    private(set) var didLose = false
    private(set) var darknessShown = 0

    func showWelcome() {}
    func showRoomCountPrompt() {}
    func showInvalidRoomCount(minimum: Int) {}
    func showMazeCreated(width: Int, height: Int, stepLimit: Int) {}

    func showRoom(_ room: Room) {
        messages.append("room \(room.position.description)")
    }

    func showDarkness() {
        darknessShown += 1
        messages.append("dark")
    }

    func showMonster(_ monster: Monster) {
        messages.append("monster \(monster.name)")
    }

    func showMonsterTimer(seconds: Int, canFight: Bool) {}
    func showStatus(_ player: Player) {}

    func showInfo(_ text: String) { messages.append(text) }
    func showSuccess(_ text: String) { messages.append(text) }
    func showWarning(_ text: String) { messages.append(text) }
    func showError(_ text: String) { messages.append(text) }

    func showHelp() {}
    func showInventory(_ player: Player) {}

    func showVictory(_ player: Player) {
        didWin = true
    }

    func showDefeat(_ player: Player) {
        didLose = true
    }

    func showGoodbye() {}
}

/// «Поддельная» клавиатура: выдаёт заранее заготовленные строки.
final class ScriptedInput: InputReading {

    private var lines: [String]

    init(_ lines: [String]) {
        self.lines = lines
    }

    func read(prompt: String) -> String? {
        lines.isEmpty ? nil : lines.removeFirst()
    }

    func read(prompt: String, timeout: TimeInterval) -> String? {
        read(prompt: prompt)
    }
}

/// Исход встречи с монстром задаётся вручную — никакой случайности в тестах.
struct FixedEncounterResolver: EncounterResolving {

    let outcome: EncounterOutcome

    func resolve(playerActedInTime: Bool) -> EncounterOutcome {
        playerActedInTime ? outcome : .tooSlow
    }
}
