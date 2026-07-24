import Foundation

/// Реализация GameView для консоли: печатает текст и раскрашивает его.
final class ConsoleView: GameView {

    private let useColors: Bool

    init(useColors: Bool = true) {
        self.useColors = useColors
    }

    // MARK: - Начало игры

    func showWelcome() {
        print("")
        print("=== Crystals and Dragons ===".colored(.bold, enabled: useColors))
        print("Find the key, open the chest and get the Holy Grail.".colored(.gray, enabled: useColors))
        print("Type 'help' to see all commands.".colored(.gray, enabled: useColors))
        print("")
    }

    func showRoomCountPrompt() {
        print("How many rooms should the maze have?")
    }

    func showInvalidRoomCount(minimum: Int) {
        showError("Please enter a number greater than or equal to \(minimum).")
    }

    func showMazeCreated(width: Int, height: Int, stepLimit: Int) {
        showInfo("A maze of \(width)x\(height) = \(width * height) rooms has been created.")
        showInfo("You have \(stepLimit) steps before you starve. Good luck!")
        print("")
    }

    // MARK: - Комната

    func showRoom(_ room: Room) {
        print(description(of: room).colored(.cyan, enabled: useColors))
    }

    func showDarkness() {
        print("Can't see anything in this dark place!".colored(.gray, enabled: useColors))
    }

    func showMonster(_ monster: Monster) {
        print("There is an evil \(monster.name) in the room!".colored(.red, enabled: useColors))
    }

    func showMonsterTimer(seconds: Int, canFight: Bool) {
        let hint = canFight ? " (you have a sword: try 'fight')" : ""
        print("You have \(seconds) seconds to act!\(hint)".colored(.yellow, enabled: useColors))
    }

    func showStatus(_ player: Player) {
        let text = "Steps left: \(player.stepsLeft)/\(player.maxSteps) | Coins: \(player.coins)"
        print(text.colored(.gray, enabled: useColors))
    }

    /// Строка описания комнаты ровно в формате из задания.
    private func description(of room: Room) -> String {
        let doors = Direction.allCases
            .filter { room.doors.contains($0) }
            .map(\.rawValue)
            .joined(separator: ", ")

        let items = room.items.isEmpty
            ? "nothing"
            : room.items.map(\.displayName).joined(separator: ", ")

        return "You are in the room \(room.position.description). "
            + "There are \(room.doors.count) doors: \(doors). "
            + "Items in the room: \(items)."
    }

    // MARK: - Сообщения

    func showInfo(_ text: String) {
        print(text.colored(.blue, enabled: useColors))
    }

    func showSuccess(_ text: String) {
        print(text.colored(.green, enabled: useColors))
    }

    func showWarning(_ text: String) {
        print(text.colored(.yellow, enabled: useColors))
    }

    func showError(_ text: String) {
        print(text.colored(.red, enabled: useColors))
    }

    // MARK: - Справка, инвентарь, финал

    func showHelp() {
        let lines = [
            "Commands:",
            "  N, S, W, E      move north / south / west / east",
            "  get [item]      pick up an item (gold goes straight to your purse)",
            "  drop [item]     leave an item in the room",
            "  eat [item]      eat food and restore your strength",
            "  open chest      open the chest (you need the key)",
            "  fight           attack a monster (you need the sword)",
            "  look            look around again",
            "  inventory       show what you carry",
            "  help            show this text",
            "  quit            leave the dungeon"
        ]
        print(lines.joined(separator: "\n").colored(.gray, enabled: useColors))
    }

    func showInventory(_ player: Player) {
        let items = player.inventory.isEmpty
            ? "nothing"
            : player.inventory.map(\.displayName).joined(separator: ", ")
        print("You carry: \(items). Coins: \(player.coins).".colored(.magenta, enabled: useColors))
    }

    func showVictory(_ player: Player) {
        print("")
        print("The chest opens and the Holy Grail is yours. YOU WIN!".colored(.green, enabled: useColors))
        print("Steps left: \(player.stepsLeft), coins collected: \(player.coins).".colored(.green, enabled: useColors))
        print("")
    }

    func showDefeat(_ player: Player) {
        print("")
        print("You have run out of strength and died of hunger in the dragon's dungeon."
            .colored(.red, enabled: useColors))
        print("Coins collected: \(player.coins). GAME OVER.".colored(.red, enabled: useColors))
        print("")
    }

    func showGoodbye() {
        print("Farewell, brave adventurer!".colored(.gray, enabled: useColors))
    }
}
