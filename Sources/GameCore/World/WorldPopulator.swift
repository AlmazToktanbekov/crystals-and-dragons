import Foundation

/// Готовый к игре мир: лабиринт + игрок, стоящий в стартовой комнате.
struct GameWorld {
    let maze: Maze
    let player: Player
    /// Минимальное число шагов «старт -> ключ -> сундук».
    /// Хранится, чтобы можно было проверить в тестах: лимит шагов не меньше этого числа.
    let requiredSteps: Int
}

protocol WorldPopulating {
    func populate(maze: Maze) -> GameWorld
}

/// Расставляет по лабиринту предметы, монстров и темноту.
///
/// Самое важное здесь — честность игры (требование задания):
/// ключ и сундук всегда достижимы, а лимит шагов заведомо больше,
/// чем кратчайший путь «старт -> ключ -> сундук».
struct WorldPopulator: WorldPopulating {

    private let monsterNames = ["dragon", "goblin", "spider", "troll", "skeleton"]
    private let foodNames = ["apple", "bread", "cheese", "mushroom"]

    /// Доля комнат, которые станут тёмными / получат монстра / золото.
    private let darkRoomShare = 0.25
    private let monsterShare = 0.2
    private let goldShare = 0.25

    func populate(maze: Maze) -> GameWorld {
        let rooms = maze.allRooms

        // 1. Стартовая комната.
        let startRoom = rooms.randomElement() ?? rooms[0]

        // 2. Ключ и сундук: выбираем среди дальних комнат, чтобы игра не была скучной.
        let fromStart = maze.distances(from: startRoom.position)
        let keyRoom = pickFarRoom(from: rooms, distances: fromStart, excluding: [startRoom.position])

        let fromKey = maze.distances(from: keyRoom.position)
        let chestRoom = pickFarRoom(
            from: rooms,
            distances: fromKey,
            excluding: [startRoom.position, keyRoom.position]
        )

        keyRoom.addItem(Key())
        chestRoom.addItem(Chest())

        // 3. Лимит шагов = кратчайший путь + запас. Проиграть можно, но не «нечестно».
        let requiredSteps = (fromStart[keyRoom.position] ?? 0) + (fromKey[chestRoom.position] ?? 0)
        let stepLimit = requiredSteps + max(10, maze.roomCount / 2)

        // 4. Комнаты, которые нельзя трогать: в них уже лежит важное.
        var reserved: Set<Position> = [startRoom.position, keyRoom.position, chestRoom.position]

        // 5. Факел и меч — в обычных (не тёмных) комнатах, иначе их не найти.
        let torchRoom = randomRoom(rooms, excluding: reserved) ?? startRoom
        torchRoom.addItem(Torchlight())
        reserved.insert(torchRoom.position)

        let swordRoom = randomRoom(rooms, excluding: reserved) ?? startRoom
        swordRoom.addItem(Sword())
        reserved.insert(swordRoom.position)

        placeFood(in: rooms, maze: maze)
        placeGold(in: rooms)
        placeDarkRooms(in: rooms, reserved: reserved)
        placeMonsters(in: rooms, reserved: reserved)

        let player = Player(position: startRoom.position, stepLimit: stepLimit)
        return GameWorld(maze: maze, player: player, requiredSteps: requiredSteps)
    }

    // MARK: - Вспомогательные шаги

    /// Комната из «дальней половины» — так ключ не окажется под носом у игрока.
    private func pickFarRoom(
        from rooms: [Room],
        distances: [Position: Int],
        excluding excluded: Set<Position>
    ) -> Room {
        let candidates = rooms
            .filter { !excluded.contains($0.position) && distances[$0.position] != nil }
            .sorted { (distances[$0.position] ?? 0) > (distances[$1.position] ?? 0) }

        guard !candidates.isEmpty else {
            return rooms.first { !excluded.contains($0.position) } ?? rooms[0]
        }
        let farHalf = candidates.prefix(max(1, candidates.count / 2))
        return farHalf.randomElement() ?? candidates[0]
    }

    private func randomRoom(_ rooms: [Room], excluding excluded: Set<Position>) -> Room? {
        rooms.filter { !excluded.contains($0.position) }.randomElement()
    }

    private func placeFood(in rooms: [Room], maze: Maze) {
        let count = max(1, maze.roomCount / 6)
        for room in rooms.shuffled().prefix(count) {
            let name = foodNames.randomElement() ?? "bread"
            room.addItem(Food(name: name, nutrition: Int.random(in: 3...8)))
        }
    }

    private func placeGold(in rooms: [Room]) {
        for room in rooms where Double.random(in: 0...1) < goldShare {
            room.addItem(Gold(amount: Int.random(in: 1...40) * 10))
        }
    }

    /// Тёмные комнаты не ставим туда, где лежит что-то критичное:
    /// иначе игрок без факела просто не сможет забрать ключ.
    private func placeDarkRooms(in rooms: [Room], reserved: Set<Position>) {
        for room in rooms where !reserved.contains(room.position) {
            if Double.random(in: 0...1) < darkRoomShare {
                room.isDark = true
            }
        }
    }

    /// Монстров не ставим в тёмные комнаты (игрок бы их не увидел)
    /// и в зарезервированные (старт, ключ, сундук, факел, меч).
    private func placeMonsters(in rooms: [Room], reserved: Set<Position>) {
        for room in rooms where !reserved.contains(room.position) && !room.isDark {
            if Double.random(in: 0...1) < monsterShare {
                room.monster = Monster(name: monsterNames.randomElement() ?? "goblin")
            }
        }
    }
}
