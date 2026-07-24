import Foundation

protocol CommandParsing {
    func parse(_ input: String) -> Command?
}

/// Превращает строку игрока в команду.
///
/// Вся «грязная» работа с текстом собрана здесь и нигде больше:
/// контроллер про строки уже ничего не знает. Такой класс легко тестировать.
struct CommandParser: CommandParsing {

    func parse(_ input: String) -> Command? {
        let words = input
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .split(separator: " ")
            .map(String.init)

        guard let keyword = words.first else { return nil }
        // Всё после первого слова — название предмета ("get gold", "eat apple").
        let argument = words.dropFirst().joined(separator: " ")

        // Одиночная буква/слово направления: n, s, w, e, north...
        if let direction = Direction(input: keyword), argument.isEmpty {
            return .move(direction)
        }

        switch keyword {
        case "go", "move":
            guard let direction = Direction(input: argument) else { return nil }
            return .move(direction)
        case "get", "take", "pick":
            return argument.isEmpty ? nil : .get(argument)
        case "drop", "put":
            return argument.isEmpty ? nil : .drop(argument)
        case "eat":
            return argument.isEmpty ? nil : .eat(argument)
        case "open":
            return .open(argument.isEmpty ? "chest" : argument)
        case "fight", "attack":
            return .fight
        case "look":
            return .look
        case "inventory", "i", "bag":
            return .inventory
        case "help", "?":
            return .help
        case "quit", "exit":
            return .quit
        default:
            return nil
        }
    }
}
