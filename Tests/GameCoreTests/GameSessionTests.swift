import XCTest
@testable import GameCore

/// Тесты правил игры на маленьком «ручном» лабиринте из двух комнат:
///
///   [0,0] -- [1,0]
///    ключ     сундук
final class GameSessionTests: XCTestCase {

    private func makeWorld(stepLimit: Int = 10) -> GameWorld {
        let maze = Maze(width: 2, height: 1)
        maze.openDoor(from: Position(x: 0, y: 0), to: .east)

        maze.room(at: Position(x: 0, y: 0))?.addItem(Key())
        maze.room(at: Position(x: 1, y: 0))?.addItem(Chest())

        let player = Player(position: Position(x: 0, y: 0), stepLimit: stepLimit)
        return GameWorld(maze: maze, player: player, requiredSteps: 1)
    }

    private func makeSession(
        world: GameWorld,
        view: SpyView,
        commands: [String],
        outcome: EncounterOutcome = .unharmed
    ) -> GameSession {
        GameSession(
            world: world,
            view: view,
            input: ScriptedInput(commands),
            parser: CommandParser(),
            encounterResolver: FixedEncounterResolver(outcome: outcome),
            reactionTime: 0.01
        )
    }

    func testPlayerWinsWithKey() {
        let view = SpyView()
        let session = makeSession(
            world: makeWorld(),
            view: view,
            commands: ["get key", "E", "open chest"]
        )

        session.run()

        XCTAssertTrue(view.didWin)
    }

    func testChestCannotBeOpenedWithoutKey() {
        let view = SpyView()
        let session = makeSession(
            world: makeWorld(),
            view: view,
            commands: ["E", "open chest"]
        )

        session.run()

        XCTAssertFalse(view.didWin)
        XCTAssertTrue(view.messages.contains { $0.contains("need the key") })
    }

    func testChestCannotBePickedUp() {
        let view = SpyView()
        let session = makeSession(
            world: makeWorld(),
            view: view,
            commands: ["E", "get chest"]
        )

        session.run()

        XCTAssertTrue(view.messages.contains { $0.contains("too heavy") })
    }

    func testPlayerDiesWhenStepsRunOut() {
        let view = SpyView()
        let world = makeWorld(stepLimit: 1)
        let session = makeSession(world: world, view: view, commands: ["E", "look"])

        session.run()

        XCTAssertTrue(view.didLose)
        XCTAssertEqual(world.player.stepsLeft, 0)
    }

    func testGoldGoesToPurseInsteadOfInventory() {
        let view = SpyView()
        let world = makeWorld()
        world.maze.room(at: Position(x: 0, y: 0))?.addItem(Gold(amount: 320))

        let session = makeSession(world: world, view: view, commands: ["get gold", "quit"])
        session.run()

        XCTAssertEqual(world.player.coins, 320)
        XCTAssertFalse(world.player.hasItem(named: "gold"))
    }

    func testDarkRoomBlocksEverythingExceptMovement() {
        let view = SpyView()
        let world = makeWorld()
        world.maze.room(at: Position(x: 1, y: 0))?.isDark = true

        let session = makeSession(world: world, view: view, commands: ["get key", "E", "open chest"])
        session.run()

        XCTAssertFalse(view.didWin)
        // Тьма показана дважды: при входе в комнату и в ответ на запрещённую команду.
        XCTAssertEqual(view.darknessShown, 2)
    }

    func testTorchlightLightsTheDarkRoom() {
        let view = SpyView()
        let world = makeWorld()
        world.maze.room(at: Position(x: 0, y: 0))?.addItem(Torchlight())
        world.maze.room(at: Position(x: 1, y: 0))?.isDark = true

        let session = makeSession(
            world: world,
            view: view,
            commands: ["get key", "get torchlight", "E", "open chest"]
        )
        session.run()

        XCTAssertTrue(view.didWin)
        XCTAssertEqual(view.darknessShown, 0)
    }

    func testDroppedTorchlightKeepsRoomLitForever() {
        let world = makeWorld()
        let darkRoom = world.maze.room(at: Position(x: 1, y: 0))
        darkRoom?.isDark = true
        world.maze.room(at: Position(x: 0, y: 0))?.addItem(Torchlight())

        let session = makeSession(
            world: world,
            view: SpyView(),
            commands: ["get torchlight", "E", "drop torchlight", "W", "quit"]
        )
        session.run()

        XCTAssertEqual(darkRoom?.isPermanentlyLit, true)
    }

    func testEatingIncreasesStepLimit() {
        let world = makeWorld(stepLimit: 5)
        world.maze.room(at: Position(x: 0, y: 0))?.addItem(Food(name: "apple", nutrition: 4))

        let session = makeSession(world: world, view: SpyView(), commands: ["eat apple", "quit"])
        session.run()

        XCTAssertEqual(world.player.stepsLeft, 9)
        XCTAssertEqual(world.player.maxSteps, 9)
    }

    func testMonsterThrowsPlayerBackWhenPlayerIsTooSlow() {
        let world = makeWorld(stepLimit: 20)
        let monsterRoom = world.maze.room(at: Position(x: 1, y: 0))
        monsterRoom?.monster = Monster(name: "dragon")

        // Первая команда — переход к монстру, потом ввод заканчивается: игрок «не успел».
        let session = makeSession(world: world, view: SpyView(), commands: ["E"])
        session.run()

        XCTAssertEqual(world.player.position, Position(x: 0, y: 0))  // отброшен назад
        XCTAssertEqual(world.player.maxSteps, 18)                    // −10% от 20
    }

    func testSwordKillsMonster() {
        let world = makeWorld(stepLimit: 20)
        let monsterRoom = world.maze.room(at: Position(x: 1, y: 0))
        let monster = Monster(name: "goblin")
        monsterRoom?.monster = monster
        world.maze.room(at: Position(x: 0, y: 0))?.addItem(Sword())

        let session = makeSession(
            world: world,
            view: SpyView(),
            commands: ["get sword", "E", "fight", "quit"],
            outcome: .unharmed
        )
        session.run()

        XCTAssertFalse(monster.isAlive)
    }
}
