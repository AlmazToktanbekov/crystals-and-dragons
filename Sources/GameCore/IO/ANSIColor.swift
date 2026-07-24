import Foundation

/// Цвета консоли через ANSI-последовательности (доп. задание «цветной текст»).
///
/// Никаких сторонних библиотек: это просто управляющие символы,
/// которые терминал понимает как «дальше пиши таким цветом».
enum ANSIColor: String {
    case reset   = "\u{1B}[0m"
    case bold    = "\u{1B}[1m"
    case red     = "\u{1B}[31m"
    case green   = "\u{1B}[32m"
    case yellow  = "\u{1B}[33m"
    case blue    = "\u{1B}[34m"
    case magenta = "\u{1B}[35m"
    case cyan    = "\u{1B}[36m"
    case gray    = "\u{1B}[90m"
}

extension String {
    /// Обернуть текст в цвет. Если цвета выключены — вернуть как есть.
    func colored(_ color: ANSIColor, enabled: Bool = true) -> String {
        guard enabled else { return self }
        return color.rawValue + self + ANSIColor.reset.rawValue
    }
}
