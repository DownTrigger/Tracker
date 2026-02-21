import Foundation

enum TrackerEmojis {

    // MARK: - Data
    static let all: [String] = [
        "❤️", "🙂", "😀", "🌺", "🐶", "🐱", "🌶️", "💪", "🏃", "🧘",
        "📚", "🎯", "⭐", "🔥", "💧", "🍎", "☕", "🌙", "🎵", "✏️"
    ]

    // MARK: - Public
    static var random: String {
        all.randomElement() ?? "⭐"
    }
}
