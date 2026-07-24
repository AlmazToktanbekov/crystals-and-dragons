import Foundation
#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

/// Источник ввода. Протокол нужен, чтобы в тестах подменить клавиатуру
/// на заранее подготовленный список строк.
protocol InputReading {
    /// Обычное чтение строки: ждём столько, сколько нужно.
    func read(prompt: String) -> String?
    /// Чтение с ограничением по времени (для боя с монстром).
    /// Возвращает nil, если игрок не успел.
    func read(prompt: String, timeout: TimeInterval) -> String?
}

/// Чтение с клавиатуры.
final class ConsoleInputReader: InputReading {

    func read(prompt: String) -> String? {
        show(prompt)
        return Swift.readLine()
    }

    func read(prompt: String, timeout: TimeInterval) -> String? {
        show(prompt)
        // Ждём, пока в stdin что-нибудь появится, но не дольше timeout.
        guard waitForInput(timeout: timeout) else {
            print("")
            return nil
        }
        return Swift.readLine()
    }

    private func show(_ prompt: String) {
        print(prompt, terminator: "")
        fflush(stdout)   // без этого приглашение может не появиться на экране
    }

    /// Системный вызов poll() спрашивает у ОС: «есть ли данные в stdin?».
    /// Это простой способ сделать ввод с таймаутом без потоков и гонок.
    private func waitForInput(timeout: TimeInterval) -> Bool {
        var descriptor = pollfd(fd: STDIN_FILENO, events: Int16(POLLIN), revents: 0)
        let milliseconds = Int32(timeout * 1000)
        return poll(&descriptor, 1, milliseconds) > 0
    }
}
