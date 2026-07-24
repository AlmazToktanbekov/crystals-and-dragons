import Foundation

/// Монстр, который сторожит комнату.
///
/// Это `class` (ссылочный тип), потому что состояние монстра меняется
/// (его можно убить), и мы хотим, чтобы изменение видели все, кто на него ссылается.
final class Monster {
    let name: String
    private(set) var isAlive: Bool = true

    init(name: String) {
        self.name = name
    }

    func kill() {
        isAlive = false
    }
}
