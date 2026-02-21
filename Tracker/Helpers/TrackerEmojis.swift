import Foundation

enum TrackerEmojis {
    static let all: [String] = [
        "❤️", "🙂", "😀", "🌺", "🐶", "🐱", "🌶️", "💪", "🏃", "🧘",
        "📚", "🎯", "⭐", "🔥", "💧", "🍎", "☕", "🌙", "🎵", "✏️"
    ]

    static var random: String {
        all.randomElement() ?? "⭐"
    }
}
