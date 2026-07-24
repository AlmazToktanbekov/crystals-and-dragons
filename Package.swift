// swift-tools-version:5.9
import PackageDescription

// Проект разделён на две цели (target):
// 1. GameCore — библиотека со всей логикой игры (её можно покрыть тестами);
// 2. crystals — крошечное консольное приложение, которое просто запускает игру.
// Так делают, чтобы логика не зависела от способа запуска и была тестируемой.
let package = Package(
    name: "CrystalsAndDragons",
    targets: [
        .target(
            name: "GameCore",
            path: "Sources/GameCore"
        ),
        .executableTarget(
            name: "crystals",
            dependencies: ["GameCore"],
            path: "Sources/crystals"
        ),
        .testTarget(
            name: "GameCoreTests",
            dependencies: ["GameCore"],
            path: "Tests/GameCoreTests"
        )
    ]
)
