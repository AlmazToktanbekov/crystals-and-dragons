import Foundation

/// Верхний уровень игры: поздороваться, спросить размер лабиринта,
/// построить мир и запустить партию.
///
/// Все зависимости приходят снаружи (Dependency Injection) — контроллер
/// не знает, что вывод идёт в консоль, а лабиринт генерируется случайно.
final class GameController {

    /// Меньше четырёх комнат делать бессмысленно.
    private static let minimumRoomCount = 4

    private let view: GameView
    private let input: InputReading
    private let parser: CommandParsing
    private let generator: MazeGenerating
    private let populator: WorldPopulating
    private let encounterResolver: EncounterResolving

    init(
        view: GameView,
        input: InputReading,
        parser: CommandParsing,
        generator: MazeGenerating,
        populator: WorldPopulating,
        encounterResolver: EncounterResolving = RandomEncounterResolver()
    ) {
        self.view = view
        self.input = input
        self.parser = parser
        self.generator = generator
        self.populator = populator
        self.encounterResolver = encounterResolver
    }

    func start() {
        view.showWelcome()

        guard let roomCount = askRoomCount() else {
            view.showGoodbye()
            return
        }

        let maze = generator.generate(roomCount: roomCount)
        let world = populator.populate(maze: maze)

        view.showMazeCreated(
            width: maze.width,
            height: maze.height,
            stepLimit: world.player.maxSteps
        )

        let session = GameSession(
            world: world,
            view: view,
            input: input,
            parser: parser,
            encounterResolver: encounterResolver
        )
        session.run()
    }

    /// Спрашиваем количество комнат, пока не введут корректное число.
    private func askRoomCount() -> Int? {
        while true {
            view.showRoomCountPrompt()

            guard let text = input.read(prompt: "> ") else { return nil }

            guard let count = Int(text.trimmingCharacters(in: .whitespaces)),
                  count >= Self.minimumRoomCount else {
                view.showInvalidRoomCount(minimum: Self.minimumRoomCount)
                continue
            }
            return count
        }
    }
}
