import Foundation

/// Одна партия игры: хранит мир и крутит главный цикл
/// «показать комнату -> спросить команду -> выполнить её».
///
/// Это «Controller» из MVC: он не печатает текст сам (за это отвечает View)
/// и не хранит правила расстановки предметов (за это отвечает World).
/// Его задача — связывать модель и представление.
final class GameSession {

    private let maze: Maze
    private let player: Player
    private let view: GameView
    private let input: InputReading
    private let parser: CommandParsing
    private let encounterResolver: EncounterResolving

    /// Сколько секунд даётся на команду в комнате с монстром.
    private let reactionTime: TimeInterval
    /// Сколько процентов жизненной силы отнимает монстр.
    private let monsterDamagePercent = 10

    private var isFinished = false

    init(
        world: GameWorld,
        view: GameView,
        input: InputReading,
        parser: CommandParsing,
        encounterResolver: EncounterResolving,
        reactionTime: TimeInterval = 5
    ) {
        self.maze = world.maze
        self.player = world.player
        self.view = view
        self.input = input
        self.parser = parser
        self.encounterResolver = encounterResolver
        self.reactionTime = reactionTime
    }

    // MARK: - Главный цикл

    func run() {
        describeCurrentRoom()

        while !isFinished {
            guard player.isAlive else {
                view.showDefeat(player)
                return
            }

            view.showStatus(player)

            // Если рядом живой монстр и его видно — ход идёт по особым правилам.
            if let monster = currentRoom.livingMonster, !isDark(currentRoom) {
                handleEncounter(with: monster)
            } else {
                handleNormalTurn()
            }
        }
    }

    private func handleNormalTurn() {
        guard let text = input.read(prompt: "> ") else {
            // Ввод закончился (например, нажали Ctrl+D) — тихо выходим.
            isFinished = true
            return
        }
        guard let command = parser.parse(text) else {
            view.showError("I don't understand that. Type 'help' to see the commands.")
            return
        }
        perform(command)
    }

    // MARK: - Встреча с монстром

    private func handleEncounter(with monster: Monster) {
        view.showMonsterTimer(seconds: Int(reactionTime), canFight: player.carriesWeapon)

        let text = input.read(prompt: "> ", timeout: reactionTime)
        let command = text.flatMap { parser.parse($0) }

        if text != nil && command == nil {
            view.showError("You shout something meaningless — that is not a command.")
        }

        switch encounterResolver.resolve(playerActedInTime: command != nil) {
        case .tooSlow:
            view.showError("Too slow! The \(monster.name) wounds you and throws you back.")
            hurtAndThrowBack()

        case .punished:
            view.showError("The \(monster.name) is faster than you: you lose strength and get thrown back.")
            hurtAndThrowBack()

        case .hurtButActed:
            view.showWarning("The \(monster.name) wounds you, but you manage to act.")
            player.loseHealth(percent: monsterDamagePercent)
            if let command { perform(command) }

        case .unharmed:
            view.showSuccess("You are quick enough — the \(monster.name) misses you.")
            if let command { perform(command) }
        }
    }

    private func hurtAndThrowBack() {
        player.loseHealth(percent: monsterDamagePercent)
        player.throwBack()
        guard player.isAlive else { return }
        describeCurrentRoom()
    }

    // MARK: - Выполнение команд

    private func perform(_ command: Command) {
        // В тёмной комнате разрешено только движение и служебные команды.
        if isDark(currentRoom) && !command.isAllowedInDarkness {
            view.showDarkness()
            return
        }

        switch command {
        case .move(let direction): move(direction)
        case .get(let name):       pickUp(name)
        case .drop(let name):      drop(name)
        case .eat(let name):       eat(name)
        case .open(let target):    open(target)
        case .fight:               fight()
        case .look:                describeCurrentRoom()
        case .inventory:           view.showInventory(player)
        case .help:                view.showHelp()
        case .quit:
            view.showGoodbye()
            isFinished = true
        }
    }

    private func move(_ direction: Direction) {
        guard currentRoom.doors.contains(direction) else {
            view.showWarning("There is no door to the \(direction.title).")
            return
        }

        player.move(to: player.position.moved(direction))
        guard player.isAlive else { return }   // цикл покажет проигрыш
        describeCurrentRoom()
    }

    private func pickUp(_ name: String) {
        let room = currentRoom
        guard let item = room.item(named: name) else {
            view.showWarning("There is no \(name) in this room.")
            return
        }
        guard item.isPortable else {
            view.showWarning("The \(item.name) is too heavy to carry.")
            return
        }

        room.removeItem(named: item.name)

        // Золото — особый случай: оно сразу превращается в монеты.
        if let gold = item as? Gold {
            player.addCoins(gold.amount)
            view.showSuccess("You take \(gold.amount) coins. Total: \(player.coins).")
        } else {
            player.take(item)
            view.showSuccess("You take the \(item.name).")
        }
    }

    private func drop(_ name: String) {
        guard let item = player.removeItem(named: name) else {
            view.showWarning("You don't have the \(name).")
            return
        }

        let room = currentRoom
        room.addItem(item)

        // Доп. задание: брошенный факел освещает тёмную комнату навсегда.
        if item is LightSource && room.isDark {
            room.isPermanentlyLit = true
            view.showSuccess("You drop the \(item.name). This room will stay lit forever.")
        } else {
            view.showSuccess("You drop the \(item.name).")
        }
    }

    private func eat(_ name: String) {
        // Еду можно взять и из рюкзака, и прямо с пола.
        if let food = player.item(named: name) as? Edible {
            player.removeItem(named: name)
            player.eat(food)
        } else if let food = currentRoom.item(named: name) as? Edible {
            currentRoom.removeItem(named: name)
            player.eat(food)
        } else {
            view.showWarning("There is nothing edible called \(name).")
            return
        }
        view.showSuccess("You eat the \(name) and feel stronger. Steps left: \(player.stepsLeft).")
    }

    private func open(_ target: String) {
        guard target.lowercased() == "chest" else {
            view.showWarning("You can only open the chest.")
            return
        }
        guard currentRoom.item(named: "chest") != nil else {
            view.showWarning("There is no chest here.")
            return
        }
        guard player.hasItem(named: "key") else {
            view.showWarning("The chest is locked. You need the key.")
            return
        }

        view.showVictory(player)
        isFinished = true
    }

    private func fight() {
        guard let monster = currentRoom.livingMonster else {
            view.showWarning("There is nobody to fight here.")
            return
        }
        guard player.carriesWeapon else {
            view.showWarning("You need a sword to fight the \(monster.name).")
            return
        }

        monster.kill()
        view.showSuccess("You destroy the \(monster.name) with your sword!")
    }

    // MARK: - Помощники

    /// Комната, в которой сейчас игрок.
    /// Если её нет — это ошибка генерации мира, а не игровая ситуация.
    private var currentRoom: Room {
        guard let room = maze.room(at: player.position) else {
            preconditionFailure("Player is outside the maze: \(player.position.description)")
        }
        return room
    }

    /// Темно ли в комнате прямо сейчас.
    /// Свет дают: факел в руках, факел на полу и «вечный свет» от брошенного факела.
    private func isDark(_ room: Room) -> Bool {
        guard room.isDark else { return false }
        if room.isPermanentlyLit { return false }
        if room.containsLightSource { return false }
        return !player.carriesLight
    }

    private func describeCurrentRoom() {
        let room = currentRoom

        guard !isDark(room) else {
            view.showDarkness()
            return
        }

        view.showRoom(room)
        if let monster = room.livingMonster {
            view.showMonster(monster)
        }
    }
}
