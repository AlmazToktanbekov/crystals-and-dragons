import Foundation

/// Фасад (Facade) — единственная публичная точка входа в библиотеку.
///
/// Здесь мы «собираем» игру из отдельных деталей: генератор лабиринта,
/// заполнитель мира, парсер команд, ввод и вывод. Это называется
/// Dependency Injection: контроллер не создаёт свои зависимости сам,
/// а получает их снаружи. Благодаря этому в тестах можно подсунуть
/// другие реализации (например, ввод из массива строк вместо клавиатуры).
public enum CrystalsAndDragons {

    public static func run() {
        let controller = GameController(
            view: ConsoleView(useColors: true),
            input: ConsoleInputReader(),
            parser: CommandParser(),
            generator: RandomMazeGenerator(),
            populator: WorldPopulator()
        )
        controller.start()
    }
}
